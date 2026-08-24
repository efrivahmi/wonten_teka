import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Function(bool isFaceDetected, bool isProperlyPositioned) onFaceValidationChanged;
  final Function(XFile? file)? onPhotoCaptured;

  const CameraPreviewWidget({
    Key? key,
    required this.onFaceValidationChanged,
    this.onPhotoCaptured,
  }) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting) return;
        _isDetecting = true;
        _processCameraImage(image, frontCamera);
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image, CameraDescription camera) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      
      final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;
      
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
      
      if (faces.length == 1) {
        final face = faces.first;
        // Simple positioning check: face is reasonably large in the frame
        final faceArea = face.boundingBox.width * face.boundingBox.height;
        final imageArea = image.width * image.height;
        
        bool isProper = false;
        // Ensure the face takes up a reasonable percentage of the screen
        if (faceArea / imageArea > 0.05) {
            isProper = true;
        }

        widget.onFaceValidationChanged(true, isProper);
      } else {
        widget.onFaceValidationChanged(faces.isNotEmpty, false);
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> takePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        // Stop stream before taking picture to avoid crashes on some devices
        if (_cameraController!.value.isStreamingImages) {
            await _cameraController!.stopImageStream();
        }
        final XFile file = await _cameraController!.takePicture();
        if (widget.onPhotoCaptured != null) {
          widget.onPhotoCaptured!(file);
        }
      } catch (e) {
        debugPrint('Error taking photo: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(_cameraController!);
  }
}
