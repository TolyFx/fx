import 'package:flutter_test/flutter_test.dart';
import 'package:fx_media/fx_media.dart';

class MockPicker implements MediaPicker {
  @override
  Future<List<ImageAsset>> pickImages({int maxCount = 9, ImagePickConfig config = const ImagePickConfig()}) async => [];
  @override
  Future<VideoAsset?> pickVideo({VideoPickConfig config = const VideoPickConfig()}) async => null;
  @override
  Future<ImageAsset?> takePhoto({CameraConfig config = const CameraConfig()}) async => null;
  @override
  Future<VideoAsset?> takeVideo({CameraConfig config = const CameraConfig()}) async => null;
  @override
  Future<List<FileAsset>> pickFiles({List<String>? allowedExtensions, int maxCount = 1}) async => [];
  @override
  Future<AudioAsset?> pickAudio() async => null;
}

void main() {
  group('FxMedia', () {
    test('注册后可获取 picker', () {
      FxMedia().register(MockPicker());
      expect(FxMedia().picker, isA<MediaPicker>());
    });

    test('MediaAsset sealed class switch 匹配', () {
      final MediaAsset asset = ImageAsset(path: '/test.jpg', size: 1024, width: 100, height: 200);

      final String result = switch (asset) {
        ImageAsset(:final width) => 'image:$width',
        VideoAsset(:final duration) => 'video:$duration',
        AudioAsset() => 'audio',
        FileAsset(:final fileName) => 'file:$fileName',
      };

      expect(result, 'image:100');
    });
  });
}
