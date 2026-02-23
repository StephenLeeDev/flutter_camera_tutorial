import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ImageConverter {
  static InputImage? fromCameraImage(CameraImage image, CameraController cameraController) {
    if (Platform.isIOS) {
      return _fromCameraImageForIos(image, cameraController);
    } else {
      return _fromCameraImageForAndroid(image, cameraController);
    }
  }

  static InputImage? _fromCameraImageForAndroid(CameraImage image, CameraController cameraController) {
    final camera = cameraController.description;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null || format != InputImageFormat.yuv_420_888) {
      return null;
    }

    final bytes = _concatenatePlanes(image.planes, image.width, image.height);
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  static InputImage? _fromCameraImageForIos(CameraImage image, CameraController cameraController) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      return null;
    }

    final camera = cameraController.description;
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) {
      return null;
    }

    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  static Uint8List _concatenatePlanes(List<Plane> planes, int width, int height) {
    final WriteBuffer allBytes = WriteBuffer();

    final Plane yPlane = planes[0];
    final int yRowStride = yPlane.bytesPerRow;
    final int yPixelStride = yPlane.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        allBytes.putUint8(yPlane.bytes[y * yRowStride + x * yPixelStride]);
      }
    }

    final Plane uPlane = planes[1];
    final Plane vPlane = planes[2];
    final int chromaRowStride = uPlane.bytesPerRow;
    final int chromaPixelStride = uPlane.bytesPerPixel ?? 1;
    final int chromaWidth = width ~/ 2;
    final int chromaHeight = height ~/ 2;

    for (int y = 0; y < chromaHeight; y++) {
      for (int x = 0; x < chromaWidth; x++) {
        final int uIndex = y * chromaRowStride + x * chromaPixelStride;
        final int vIndex = y * chromaRowStride + x * chromaPixelStride;

        if (vIndex < vPlane.bytes.length) {
          allBytes.putUint8(vPlane.bytes[vIndex]);
        }
        if (uIndex < uPlane.bytes.length) {
          allBytes.putUint8(uPlane.bytes[uIndex]);
        }
      }
    }

    return allBytes.done().buffer.asUint8List();
  }
}
