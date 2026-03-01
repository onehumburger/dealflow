import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uu/config/supabase_config.dart';

/// Service for media operations: picking, local storage, and Supabase upload.
///
/// Pure logic methods (filename generation, path building) are unit-testable.
/// File I/O and platform calls (image picker, Supabase upload) are called
/// from the UI layer via convenience methods that require real device context.
class MediaService {
  /// Supabase Storage bucket name.
  static const storageBucket = 'media';

  /// Supported media types.
  static const supportedTypes = ['photo', 'video'];

  /// Check if a type string represents a photo.
  static bool isPhoto(String type) => type == 'photo';

  /// Check if a type string represents a video.
  static bool isVideo(String type) => type == 'video';

  /// Generate a unique file name for a media entry.
  String generateFileName(String type) {
    final ext = getExtensionForType(type);
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '${type}_$timestamp.$ext';
  }

  /// Get the file extension for a media type.
  String getExtensionForType(String type) {
    switch (type) {
      case 'photo':
        return 'jpg';
      case 'video':
        return 'mp4';
      default:
        return 'dat';
    }
  }

  /// Build the remote storage path for Supabase: `<babyId>/<fileName>`.
  String getRemotePath({required int babyId, required String fileName}) {
    return '$babyId/$fileName';
  }

  /// Get the local media directory path under a given base directory.
  String getLocalMediaDir(String baseDir) {
    return p.join(baseDir, 'media');
  }

  /// Build the full local file path.
  String getLocalPath({required String baseDir, required String fileName}) {
    return p.join(baseDir, 'media', fileName);
  }

  /// Pick an image from the gallery or camera.
  ///
  /// Returns the picked [XFile] or null if cancelled.
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    return picker.pickImage(source: source, imageQuality: 85);
  }

  /// Pick a video from the gallery or camera.
  ///
  /// Returns the picked [XFile] or null if cancelled.
  Future<XFile?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    return picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );
  }

  /// Save a picked file to the local app media directory.
  ///
  /// Returns the local file path where the file was saved.
  Future<String> saveLocally({
    required String sourceFilePath,
    required String baseDir,
    required String fileName,
  }) async {
    final mediaDir = Directory(getLocalMediaDir(baseDir));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final destinationPath = getLocalPath(baseDir: baseDir, fileName: fileName);
    final sourceFile = File(sourceFilePath);
    await sourceFile.copy(destinationPath);

    return destinationPath;
  }

  /// Upload a local file to Supabase Storage.
  ///
  /// Returns the remote path on success, or null if Supabase is not
  /// configured or the user is not authenticated.
  Future<String?> uploadToSupabase({
    required String localPath,
    required int babyId,
    required String fileName,
  }) async {
    final client = SupabaseConfig.clientOrNull;
    if (client == null) return null;

    // Check if user is authenticated
    if (client.auth.currentUser == null) return null;

    final remotePath = getRemotePath(babyId: babyId, fileName: fileName);
    final file = File(localPath);

    try {
      await client.storage
          .from(storageBucket)
          .upload(remotePath, file);
      return remotePath;
    } on StorageException {
      // Upload failed — media stays local, can be retried later.
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Generate a thumbnail for a video.
  ///
  /// Currently a placeholder — returns null. A real implementation would use
  /// a package like `video_thumbnail` to extract a frame.
  Future<String?> generateThumbnail(String videoPath) async {
    // Placeholder: thumbnail generation not yet implemented.
    return null;
  }

  /// Get a public URL for a remote file path in Supabase Storage.
  ///
  /// Returns null if Supabase is not configured.
  String? getPublicUrl(String remotePath) {
    final client = SupabaseConfig.clientOrNull;
    if (client == null) return null;

    return client.storage.from(storageBucket).getPublicUrl(remotePath);
  }
}
