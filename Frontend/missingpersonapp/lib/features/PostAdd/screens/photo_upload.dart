import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Picks an image from the gallery (without cropping).
Future<XFile?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );
  return image;
}

/// Captures an image using the camera and dynamically crops it.
Future<XFile?> captureAndCropImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? capturedImage = await picker.pickImage(
    source: ImageSource.camera,
  );

  if (capturedImage != null) {
    // Crop the captured image dynamically
    final CroppedFile? croppedFile = await cropImage(capturedImage.path);

    if (croppedFile != null) {
      // Convert CroppedFile to XFile
      return XFile(croppedFile.path);
    }
  }
  return null;
}

/// Crops an image using the ImageCropper package.
Future<CroppedFile?> cropImage(String imagePath) async {
  final ImageCropper imageCropper = ImageCropper();
  final CroppedFile? croppedImage = await imageCropper.cropImage(
    sourcePath: imagePath,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    ],
  );
  return croppedImage;
}

/// Picks multiple images from the gallery (without cropping).
Future<List<XFile>> pickImages() async {
  final picker = ImagePicker();
  List<XFile> pickedImages = await picker.pickMultiImage();
  return pickedImages;
}
