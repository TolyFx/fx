import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fx_media/fx_media.dart';
import 'package:image_picker/image_picker.dart';

/// fx_media 的默认实现，基于 [image_picker]。
///
/// 支持 Android / iOS / Web 的图片和视频选择/拍摄。
/// 文件选择和音频选择需要额外实现或返回空结果。
///
/// ```dart
/// FxMedia().register(FxMediaPickerImpl());
/// ```
class FxMediaPickerImpl implements MediaPicker {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<List<ImageAsset>> pickImages({
    int maxCount = 9,
    ImagePickConfig config = const ImagePickConfig(),
  }) async {
    if (maxCount == 1) {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: config.maxWidth?.toDouble(),
        maxHeight: config.maxHeight?.toDouble(),
        imageQuality: config.quality,
      );
      if (file == null) return [];
      return [await _toImageAsset(file)];
    }

    final List<XFile> files = await _picker.pickMultiImage(
      maxWidth: config.maxWidth?.toDouble(),
      maxHeight: config.maxHeight?.toDouble(),
      imageQuality: config.quality,
      limit: maxCount,
    );
    final List<ImageAsset> result = [];
    for (final XFile file in files) {
      result.add(await _toImageAsset(file));
    }
    return result;
  }

  @override
  Future<VideoAsset?> pickVideo({
    VideoPickConfig config = const VideoPickConfig(),
  }) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: config.maxDuration,
    );
    if (file == null) return null;
    return _toVideoAsset(file);
  }

  @override
  Future<ImageAsset?> takePhoto({
    CameraConfig config = const CameraConfig(),
  }) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: config.maxWidth?.toDouble(),
      maxHeight: config.maxHeight?.toDouble(),
      preferredCameraDevice:
          config.preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
    );
    if (file == null) return null;
    return _toImageAsset(file);
  }

  @override
  Future<VideoAsset?> takeVideo({
    CameraConfig config = const CameraConfig(),
  }) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: config.maxDuration,
      preferredCameraDevice:
          config.preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
    );
    if (file == null) return null;
    return _toVideoAsset(file);
  }

  @override
  Future<List<FileAsset>> pickFiles({
    List<String>? allowedExtensions,
    int maxCount = 1,
  }) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: maxCount > 1,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    if (result == null) return [];
    return result.files
        .where((PlatformFile f) => f.path != null)
        .map((PlatformFile f) => FileAsset(
              path: f.path!,
              size: f.size,
              fileName: f.name,
              mimeType: f.extension != null ? 'application/${f.extension}' : null,
            ))
        .toList();
  }

  @override
  Future<AudioAsset?> pickAudio() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result == null || result.files.isEmpty) return null;
    final PlatformFile file = result.files.first;
    if (file.path == null) return null;
    return AudioAsset(path: file.path!, size: file.size);
  }

  Future<ImageAsset> _toImageAsset(XFile file) async {
    final int size = kIsWeb ? 0 : await File(file.path).length();
    return ImageAsset(path: file.path, size: size);
  }

  Future<VideoAsset> _toVideoAsset(XFile file) async {
    final int size = kIsWeb ? 0 : await File(file.path).length();
    return VideoAsset(path: file.path, size: size);
  }
}
