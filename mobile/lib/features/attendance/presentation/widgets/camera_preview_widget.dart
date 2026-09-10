import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Function(bool isFaceDetected, bool isProperlyPositioned, double angleY,
      bool isTooDark) onFaceValidationChanged;
  final Function(XFile? file)? onPhotoCaptured;
  final Function(List<double> embedding)? onFaceEmbeddingGenerated;

  const CameraPreviewWidget({
    super.key,
    required this.onFaceValidationChanged,
    this.onPhotoCaptured,
    this.onFaceEmbeddingGenerated,
  });

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _isDisposed = false;
  int _cameraGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_releaseCamera(closeDetector: false));
    }
  }

  Future<void> _initializeCamera() async {
    if (_isDisposed || _cameraController != null) return;
    final generation = ++_cameraGeneration;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('Kamera tidak tersedia');
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      _cameraController = controller;

      await controller.initialize();
      if (!mounted || _isDisposed || generation != _cameraGeneration) {
        await controller.dispose();
        return;
      }

      setState(() {
        _isCameraInitialized = true;
      });

      await controller.startImageStream((CameraImage image) {
        if (_isDisposed || _isDetecting) return;
        _isDetecting = true;
        _processCameraImage(image, frontCamera, generation);
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      await _releaseCamera(closeDetector: false);
    }
  }

  Future<void> _processCameraImage(
      CameraImage image, CameraDescription camera, int generation) async {
    try {
      if (_isDisposed || image.planes.isEmpty) return;
      // camera_android provides NV21/BGRA as a packed first plane. Appending
      // every plane corrupts the buffer expected by ML Kit.
      final bytes = image.planes.first.bytes;

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final imageRotation = InputImageRotationValue.fromRawValue(
            _rotationFor(camera),
          ) ??
          InputImageRotation.rotation0deg;
      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: metadata,
      );

      final faces = await _faceDetector.processImage(inputImage);
      if (_isDisposed || !mounted || generation != _cameraGeneration) return;

      bool isTooDark = false;
      if (image.planes.isNotEmpty) {
        final bytes = image.planes[0].bytes;
        int sum = 0;
        int sampleCount = 0;
        // Sample pixels to calculate average luma
        for (int i = 0; i < bytes.length; i += 100) {
          sum += bytes[i];
          sampleCount++;
        }
        if (sampleCount > 0) {
          double avgLuma = sum / sampleCount;
          isTooDark = avgLuma < 50; // Threshold for "too dark"
        }
      }

      if (faces.length == 1) {
        final face = faces.first;
        // Simple positioning check: face is reasonably large in the frame
        final faceArea = face.boundingBox.width * face.boundingBox.height;
        final imageArea = image.width * image.height;

        bool isProper = false;
        double angleY = face.headEulerAngleY ?? 0.0;

        // Ensure the face takes up a reasonable percentage of the screen
        if (faceArea / imageArea > 0.05) {
          isProper = true;

          if (widget.onFaceEmbeddingGenerated != null) {
            final embedding = _orderedLandmarkVector(face);
            if (embedding != null) {
              widget.onFaceEmbeddingGenerated!(embedding);
            }
          }
        }

        widget.onFaceValidationChanged(true, isProper, angleY, isTooDark);
      } else {
        widget.onFaceValidationChanged(faces.isNotEmpty, false, 0.0, isTooDark);
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  int _rotationFor(CameraDescription camera) {
    final controller = _cameraController;
    if (controller == null || !Platform.isAndroid) {
      return camera.sensorOrientation;
    }
    const rotations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    final deviceRotation = rotations[controller.value.deviceOrientation] ?? 0;
    return camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + deviceRotation) % 360
        : (camera.sensorOrientation - deviceRotation + 360) % 360;
  }

  List<double>? _orderedLandmarkVector(Face face) {
    const order = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
    ];
    final result = <double>[];
    for (final type in order) {
      final landmark = face.landmarks[type];
      if (landmark == null) return null;
      result
        ..add((landmark.position.x - face.boundingBox.left) /
            face.boundingBox.width)
        ..add((landmark.position.y - face.boundingBox.top) /
            face.boundingBox.height);
    }
    return result;
  }

  Future<void> takePhoto() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPicture) {
      widget.onPhotoCaptured?.call(null);
      return;
    }

    _isTakingPicture = true;
    try {
      // Let the current ML Kit frame finish before changing the camera session.
      // Several Android camera implementations fail when stopImageStream and
      // takePicture race with an image that is still being analysed.
      for (var attempt = 0; attempt < 10 && _isDetecting; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      if (_isDetecting) {
        throw StateError('Camera frame analysis did not finish in time');
      }
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
        await Future<void>.delayed(const Duration(milliseconds: 180));
      }
      final file = await controller.takePicture();
      widget.onPhotoCaptured?.call(file);
    } catch (e) {
      debugPrint('Error taking photo: $e');
      widget.onPhotoCaptured?.call(null);
    } finally {
      _isTakingPicture = false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cameraGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_releaseCamera(closeDetector: true));
    super.dispose();
  }

  Future<void> _releaseCamera({required bool closeDetector}) async {
    _cameraGeneration++;
    final controller = _cameraController;
    _cameraController = null;
    if (mounted && !_isDisposed) {
      setState(() => _isCameraInitialized = false);
    }
    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
      } catch (_) {}
      await controller.dispose();
    }
    if (closeDetector) {
      for (var attempt = 0; attempt < 20 && _isDetecting; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
      await _faceDetector.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(_cameraController!);
  }
}
