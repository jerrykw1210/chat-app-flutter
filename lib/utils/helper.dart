import "dart:developer" as dev;
import "dart:io";

import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "dart:math";

import "package:uuid/uuid.dart";

/// A utility class that provides helper methods for various tasks.
class Helper {
  /// Generates a new UUID (Universally Unique Identifier) string.
  static String generateUUID() {
    const Uuid uuid = Uuid();
    return uuid.v4();
  }

  /// Generates a random 10 digit number.
  static int generateIntUUID({int? count}) {
    var random = Random();
    var number = StringBuffer();
    var noOfDigits = count ?? 10;

    for (var i = 0; i < noOfDigits; i++) {
      number.write(random.nextInt(10));
    }
    return int.parse(number.toString());
  }

  /// Formats a file size given in bytes into a human-readable string.
  /// The output is expressed in bytes (B), kilobytes (KB), megabytes (MB), or gigabytes (GB)
  /// depending on the size.
  static String formatFileSize(int bytes) {
    const int kb = 1024;
    const int mb = 1024 * kb;
    const int gb = 1024 * mb;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(2)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }

  static Directory? _directory;

  /// Initialize the directory in advance
  static Future<void> initializeDirectory() async {
    _directory ??= Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getDownloadsDirectory();
  }

  /// Synchronously get the directory after initialization
  static Directory? get directory {
    if (_directory == null) {
      throw Exception(
          "DirectoryHelper not initialized. Call initialize() first.");
    }
    return _directory;
  }

  static bool checkIfVideo(XFile file) {
    final mimeType = file.mimeType;
    final fileName = file.name;
    dev.log("mimi type is video $mimeType");

    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'webm'];
    final extension = fileName.split('.').last.toLowerCase();

    if ((mimeType != null && mimeType.startsWith('video/')) ||
        videoExtensions.contains(extension)) {
      return true;
    } else {
      return false;
    }
  }

  static bool checkNotMediaFileType(XFile file) {
    final mimeType = file.mimeType;
    final fileName = file.name;
    dev.log("mimi type $mimeType");
    // List of valid video extensions
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'webm'];

    // List of valid image extensions
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

    // Extract file extension from file name
    final extension = fileName.split('.').last.toLowerCase();

    // Check if mimeType is valid and if it is a video or image
    if ((mimeType != null && mimeType.startsWith('video/')) ||
        videoExtensions.contains(extension)) {
      return true; // It's a video
    } else if ((mimeType != null && mimeType.startsWith('image/')) ||
        imageExtensions.contains(extension)) {
      return true; // It's an image
    }

    return false; // Not a video or an image
  }
}
