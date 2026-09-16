import 'dart:async';
import 'dart:io';
import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:screen_brightness/screen_brightness.dart';

class FaceDetectionMetrics {
  final bool detected;
  final bool positioned;
  final bool lightingOkay;
  final int qualityPercent;
  final double yaw;
  final double pitch;
  final double roll;

  const FaceDetectionMetrics({
    required this.detected,
    required this.positioned,
    required this.lightingOkay,
    required this.qualityPercent,
    required this.yaw,
    required this.pitch,
    required this.roll,
  });
}

class CameraPreviewWidget extends StatefulWidget {
  final Function(bool isFaceDetected, bool isProperlyPositioned, double angleY,
      bool isTooDark) onFaceValidationChanged;
  final Function(XFile? file)? onPhotoCaptured;
  final Function(List<double> embedding)? onFaceEmbeddingGenerated;
  final ValueChanged<FaceDetectionMetrics>? onDetectionMetricsChanged;

  const CameraPreviewWidget({
    super.key,
    required this.onFaceValidationChanged,
    this.onPhotoCaptured,
    this.onFaceEmbeddingGenerated,
    this.onDetectionMetricsChanged,
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
      // Accurate mode is important here because the descriptor below depends
      // on all five landmarks. Fast mode omits one or more landmarks on a
      // number of Android devices, leaving the similarity stuck at 0%.
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _isDisposed = false;
  int _cameraGeneration = 0;
  bool _brightnessBoosted = false;
  DateTime _lastBrightnessChange = DateTime.fromMillisecondsSinceEpoch(0);
  Rect? _normalizedFaceBox;
  FaceDetectionMetrics _metrics = const FaceDetectionMetrics(
    detected: false,
    positioned: false,
    lightingOkay: false,
    qualityPercent: 0,
    yaw: 0,
    pitch: 0,
    roll: 0,
  );

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

      await _startImageStream(controller, frontCamera, generation);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      await _releaseCamera(closeDetector: false);
    }
  }

  Future<void> _startImageStream(CameraController controller,
      CameraDescription camera, int generation) async {
    if (_isDisposed ||
        generation != _cameraGeneration ||
        controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream((CameraImage image) {
      if (_isDisposed || _isDetecting) return;
      _isDetecting = true;
      _processCameraImage(image, camera, generation);
    });
  }

  Future<void> _processCameraImage(
      CameraImage image, CameraDescription camera, int generation) async {
    try {
      if (_isDisposed || image.planes.isEmpty) return;
      final imageData = _imageDataForMlKit(image);

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final imageRotation = InputImageRotationValue.fromRawValue(
            _rotationFor(camera),
          ) ??
          InputImageRotation.rotation0deg;
      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: imageData.format,
        bytesPerRow: imageData.bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: imageData.bytes,
        metadata: metadata,
      );

      final faces = await _faceDetector.processImage(inputImage);
      if (_isDisposed || !mounted || generation != _cameraGeneration) return;

      bool isTooDark = false;
      if (image.planes.isNotEmpty) {
        final plane = image.planes[0];
        final bytes = plane.bytes;
        int sum = 0;
        int sampleCount = 0;
        // Measure the central face area instead of the whole frame. A bright
        // window behind the employee must not make a dark face pass.
        final rowStride = plane.bytesPerRow;
        final startX = (image.width * .20).round();
        final endX = (image.width * .80).round();
        final startY = (image.height * .15).round();
        final endY = (image.height * .85).round();
        for (int y = startY; y < endY; y += 8) {
          for (int x = startX; x < endX; x += 8) {
            final index = y * rowStride + x;
            if (index < bytes.length) {
              sum += bytes[index];
              sampleCount++;
            }
          }
        }
        if (sampleCount > 0) {
          double avgLuma = sum / sampleCount;
          isTooDark = avgLuma < 78;
        }
      }

      if (faces.length == 1) {
        final face = faces.first;
        // Simple positioning check: face is reasonably large in the frame
        final faceArea = face.boundingBox.width * face.boundingBox.height;
        final imageArea = image.width * image.height;

        bool isProper = false;
        final angleY = face.headEulerAngleY ?? 0.0;
        final angleX = face.headEulerAngleX ?? 0.0;
        final angleZ = face.headEulerAngleZ ?? 0.0;
        final rotated = imageRotation == InputImageRotation.rotation90deg ||
            imageRotation == InputImageRotation.rotation270deg;
        final displayWidth =
            rotated ? image.height.toDouble() : image.width.toDouble();
        final displayHeight =
            rotated ? image.width.toDouble() : image.height.toDouble();
        final centerX = face.boundingBox.center.dx / displayWidth;
        final centerY = face.boundingBox.center.dy / displayHeight;
        final centered =
            (centerX - .5).abs() < .22 && (centerY - .5).abs() < .25;
        final areaRatio = faceArea / (displayWidth * displayHeight);
        final sizeOkay = areaRatio > .07 && areaRatio < .58;

        // Ensure the face takes up a reasonable percentage of the screen
        if (faceArea / imageArea > 0.05 && centered && sizeOkay) {
          isProper = true;

          if (widget.onFaceEmbeddingGenerated != null) {
            final embedding = _orderedLandmarkVector(face);
            if (embedding != null) {
              widget.onFaceEmbeddingGenerated!(embedding);
            }
          }
        }

        final landmarkCount =
            face.landmarks.values.where((point) => point != null).length;
        final sizeScore = (1 - ((areaRatio - .22).abs() / .22)).clamp(0.0, 1.0);
        final centerScore =
            (1 - (((centerX - .5).abs() + (centerY - .5).abs()) / .55))
                .clamp(0.0, 1.0);
        final poseScore = (1 -
                ((angleY.abs() / 55) +
                        (angleX.abs() / 40) +
                        (angleZ.abs() / 35)) /
                    3)
            .clamp(0.0, 1.0);
        final quality = ((.30 +
                    .18 * sizeScore +
                    .18 * centerScore +
                    .14 * (landmarkCount / 5).clamp(0.0, 1.0) +
                    .10 * (isTooDark ? 0 : 1) +
                    .10 * poseScore) *
                100)
            .round()
            .clamp(0, 100);
        final raw = face.boundingBox;
        final normalized = Rect.fromLTRB(
          (1 - raw.right / displayWidth).clamp(0.0, 1.0),
          (raw.top / displayHeight).clamp(0.0, 1.0),
          (1 - raw.left / displayWidth).clamp(0.0, 1.0),
          (raw.bottom / displayHeight).clamp(0.0, 1.0),
        );
        final metrics = FaceDetectionMetrics(
          detected: true,
          positioned: isProper,
          lightingOkay: !isTooDark,
          qualityPercent: quality,
          yaw: angleY,
          pitch: angleX,
          roll: angleZ,
        );
        if (mounted) {
          setState(() {
            _normalizedFaceBox = normalized;
            _metrics = metrics;
          });
        }
        widget.onDetectionMetricsChanged?.call(metrics);

        widget.onFaceValidationChanged(true, isProper, angleY, isTooDark);
      } else {
        const metrics = FaceDetectionMetrics(
            detected: false,
            positioned: false,
            lightingOkay: true,
            qualityPercent: 0,
            yaw: 0,
            pitch: 0,
            roll: 0);
        if (mounted) {
          setState(() {
            _normalizedFaceBox = null;
            _metrics = metrics;
          });
        }
        widget.onDetectionMetricsChanged?.call(metrics);
        widget.onFaceValidationChanged(faces.isNotEmpty, false, 0.0, isTooDark);
      }
      _updateBrightnessForLighting(isTooDark);
    } catch (e) {
      debugPrint('Face detection error: $e');
      if (!_isDisposed && mounted && generation == _cameraGeneration) {
        setState(() => _normalizedFaceBox = null);
        widget.onFaceValidationChanged(false, false, 0.0, false);
      }
    } finally {
      _isDetecting = false;
    }
  }

  void _updateBrightnessForLighting(bool isTooDark) {
    final now = DateTime.now();
    if (now.difference(_lastBrightnessChange) < const Duration(seconds: 1)) {
      return;
    }
    if (isTooDark && !_brightnessBoosted) {
      _lastBrightnessChange = now;
      _brightnessBoosted = true;
      unawaited(_setBiometricBrightness(1.0));
    }
  }

  Future<void> _setBiometricBrightness(double value) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } catch (e) {
      debugPrint('Unable to raise application brightness: $e');
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (e) {
      debugPrint('Unable to restore application brightness: $e');
    }
  }

  ({Uint8List bytes, InputImageFormat format, int bytesPerRow})
      _imageDataForMlKit(CameraImage image) {
    if (!Platform.isAndroid || image.planes.length == 1) {
      return (
        bytes: image.planes.first.bytes,
        format:
            Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      );
    }

    // camera_android 0.10 can return YUV_420_888 even when NV21 is requested.
    // ML Kit's Flutter bridge accepts a single NV21 buffer, so convert the
    // three camera planes (Y, U, V) instead of passing only the Y plane.
    if (image.planes.length < 3) {
      throw StateError('Format frame kamera Android tidak didukung');
    }
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final bytes = Uint8List(image.width * image.height * 3 ~/ 2);
    var offset = 0;

    for (var row = 0; row < image.height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      for (var column = 0; column < image.width; column++) {
        bytes[offset++] = yPlane.bytes[rowStart + column];
      }
    }

    final chromaWidth = image.width ~/ 2;
    final chromaHeight = image.height ~/ 2;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;
    for (var row = 0; row < chromaHeight; row++) {
      final uRowStart = row * uPlane.bytesPerRow;
      final vRowStart = row * vPlane.bytesPerRow;
      for (var column = 0; column < chromaWidth; column++) {
        bytes[offset++] = vPlane.bytes[vRowStart + column * vPixelStride];
        bytes[offset++] = uPlane.bytes[uRowStart + column * uPixelStride];
      }
    }

    return (
      bytes: bytes,
      format: InputImageFormat.nv21,
      bytesPerRow: image.width,
    );
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
      final point = _landmarkOrContourPoint(face, type);
      if (point == null) return null;
      result
        ..add((point.x - face.boundingBox.left) / face.boundingBox.width)
        ..add((point.y - face.boundingBox.top) / face.boundingBox.height);
    }
    return result;
  }

  ({double x, double y})? _landmarkOrContourPoint(
      Face face, FaceLandmarkType type) {
    final landmark = face.landmarks[type];
    if (landmark != null) {
      return (
        x: landmark.position.x.toDouble(),
        y: landmark.position.y.toDouble(),
      );
    }

    // ML Kit can detect a face while omitting an individual landmark,
    // especially on iOS when the face is slightly tilted. Contours are still
    // available in those frames, so derive the same semantic feature point
    // from them instead of dropping the complete descriptor.
    return switch (type) {
      FaceLandmarkType.leftEye => _contourCenter(face, FaceContourType.leftEye),
      FaceLandmarkType.rightEye =>
        _contourCenter(face, FaceContourType.rightEye),
      FaceLandmarkType.noseBase =>
        _contourCenter(face, FaceContourType.noseBottom),
      FaceLandmarkType.leftMouth => _mouthCorner(face, takeLeft: true),
      FaceLandmarkType.rightMouth => _mouthCorner(face, takeLeft: false),
      _ => null,
    };
  }

  ({double x, double y})? _contourCenter(Face face, FaceContourType type) {
    final points = face.contours[type]?.points;
    if (points == null || points.isEmpty) return null;
    var x = 0.0;
    var y = 0.0;
    for (final point in points) {
      x += point.x;
      y += point.y;
    }
    return (x: x / points.length, y: y / points.length);
  }

  ({double x, double y})? _mouthCorner(Face face, {required bool takeLeft}) {
    final points = <Point<int>>[
      ...?face.contours[FaceContourType.upperLipTop]?.points,
      ...?face.contours[FaceContourType.lowerLipBottom]?.points,
    ];
    if (points.isEmpty) return null;
    final point = points.reduce(
        (a, b) => takeLeft ? (a.x <= b.x ? a : b) : (a.x >= b.x ? a : b));
    return (x: point.x.toDouble(), y: point.y.toDouble());
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
    XFile? capturedFile;
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
      capturedFile = await controller.takePicture();
    } catch (e) {
      debugPrint('Error taking photo: $e');
    } finally {
      // Taking a still photo stops ML Kit's image stream. Start it again here
      // so the next pose does not depend on pausing/resuming the whole app.
      if (!_isDisposed &&
          controller == _cameraController &&
          controller.value.isInitialized) {
        try {
          final camera = controller.description;
          await _startImageStream(controller, camera, _cameraGeneration);
        } catch (e) {
          debugPrint('Error restarting camera analysis: $e');
        }
      }
      _isTakingPicture = false;
      widget.onPhotoCaptured?.call(capturedFile);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cameraGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_restoreBrightness());
    unawaited(_releaseCamera(closeDetector: true));
    super.dispose();
  }

  Future<void> _releaseCamera({required bool closeDetector}) async {
    _cameraGeneration++;
    final controller = _cameraController;
    _cameraController = null;
    if (_brightnessBoosted) {
      _brightnessBoosted = false;
      await _restoreBrightness();
    }
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

    return Stack(fit: StackFit.expand, children: [
      CameraPreview(_cameraController!),
      if (_normalizedFaceBox != null)
        CustomPaint(
          painter: _FaceBoxPainter(
            normalizedBox: _normalizedFaceBox!,
            valid: _metrics.positioned && _metrics.lightingOkay,
            qualityPercent: _metrics.qualityPercent,
          ),
        ),
    ]);
  }
}

class _FaceBoxPainter extends CustomPainter {
  final Rect normalizedBox;
  final bool valid;
  final int qualityPercent;
  const _FaceBoxPainter(
      {required this.normalizedBox,
      required this.valid,
      required this.qualityPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
        normalizedBox.left * size.width,
        normalizedBox.top * size.height,
        normalizedBox.right * size.width,
        normalizedBox.bottom * size.height);
    final color = valid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)), paint);
    final label = TextPainter(
      text: TextSpan(
          text: '$qualityPercent% • wajah terdeteksi',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelRect = Rect.fromLTWH(rect.left,
        (rect.top - 28).clamp(4.0, size.height - 26), label.width + 16, 24);
    canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(7)),
        Paint()..color = color);
    label.paint(canvas, Offset(labelRect.left + 8, labelRect.top + 5));
  }

  @override
  bool shouldRepaint(covariant _FaceBoxPainter old) =>
      old.normalizedBox != normalizedBox ||
      old.valid != valid ||
      old.qualityPercent != qualityPercent;
}
