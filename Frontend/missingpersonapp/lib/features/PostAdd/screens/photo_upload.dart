import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );
  return image;
}

Future<CroppedFile?> captureAndCropImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.camera,
  );
  if (image != null) {
    return await cropImage(image.path);
  }
  return null;
}

Future<CroppedFile?> cropImage(String imagePath) async {
  final ImageCropper imageCropper = ImageCropper();
  final CroppedFile? croppedImage =
      await imageCropper.cropImage(sourcePath: imagePath, aspectRatioPresets: [
    CropAspectRatioPreset.square,
    CropAspectRatioPreset.ratio3x2,
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.ratio4x3,
    CropAspectRatioPreset.ratio16x9
  ], uiSettings: [
    AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false),
    IOSUiSettings(
      minimumAspectRatio: 1.0,
    ),
  ]);
  return croppedImage;
}

Future<List<XFile>> pickImages() async {
  final picker = ImagePicker();
  List<XFile> pickedImages = await picker.pickMultiImage();
  return pickedImages;
}
