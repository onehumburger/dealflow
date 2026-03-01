import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/media_service.dart';

void main() {
  group('MediaService', () {
    late MediaService service;

    setUp(() {
      service = MediaService();
    });

    group('getStorageBucketName', () {
      test('returns the expected bucket name', () {
        expect(MediaService.storageBucket, 'media');
      });
    });

    group('getRemotePath', () {
      test('builds correct remote path for photo', () {
        final path = service.getRemotePath(
          babyId: 1,
          fileName: 'photo_20260301.jpg',
        );
        expect(path, '1/photo_20260301.jpg');
      });

      test('builds correct remote path for different baby', () {
        final path = service.getRemotePath(
          babyId: 42,
          fileName: 'video_clip.mp4',
        );
        expect(path, '42/video_clip.mp4');
      });
    });

    group('generateFileName', () {
      test('generates photo filename with jpg extension', () {
        final name = service.generateFileName('photo');
        expect(name, endsWith('.jpg'));
        expect(name, startsWith('photo_'));
      });

      test('generates video filename with mp4 extension', () {
        final name = service.generateFileName('video');
        expect(name, endsWith('.mp4'));
        expect(name, startsWith('video_'));
      });

      test('generates unique filenames', () {
        final name1 = service.generateFileName('photo');
        final name2 = service.generateFileName('photo');
        expect(name1, isNot(equals(name2)));
      });
    });

    group('getExtensionForType', () {
      test('returns jpg for photo', () {
        expect(service.getExtensionForType('photo'), 'jpg');
      });

      test('returns mp4 for video', () {
        expect(service.getExtensionForType('video'), 'mp4');
      });

      test('returns dat for unknown type', () {
        expect(service.getExtensionForType('other'), 'dat');
      });
    });

    group('isPhoto', () {
      test('returns true for photo type', () {
        expect(MediaService.isPhoto('photo'), isTrue);
      });

      test('returns false for video type', () {
        expect(MediaService.isPhoto('video'), isFalse);
      });
    });

    group('isVideo', () {
      test('returns true for video type', () {
        expect(MediaService.isVideo('video'), isTrue);
      });

      test('returns false for photo type', () {
        expect(MediaService.isVideo('photo'), isFalse);
      });
    });

    group('supportedMediaTypes', () {
      test('includes photo and video', () {
        expect(MediaService.supportedTypes, containsAll(['photo', 'video']));
      });

      test('contains exactly two types', () {
        expect(MediaService.supportedTypes.length, 2);
      });
    });

    group('generateThumbnail', () {
      test('returns null (placeholder implementation)', () async {
        final result = await service.generateThumbnail('/path/to/video.mp4');
        expect(result, isNull);
      });
    });

    group('getLocalMediaDir', () {
      test('returns path under the given base directory', () {
        final dir = service.getLocalMediaDir('/app/data');
        expect(dir, '/app/data/media');
      });
    });

    group('getLocalPath', () {
      test('builds a full local file path', () {
        final path = service.getLocalPath(
          baseDir: '/app/data',
          fileName: 'photo_123.jpg',
        );
        expect(path, '/app/data/media/photo_123.jpg');
      });
    });
  });
}
