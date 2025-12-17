import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageChunkerService {
  // Firestore limit is 1,048,576 bytes. 
  // We use 800KB to be safe from metadata overhead.
  static const int _chunkSize = 800 * 1024; 

  /// 1. Compress and Convert File to Base64 String
  static Future<String> fileToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// 2. Split Base64 String into List of Strings
  static List<String> splitString(String bigString) {
    List<String> chunks = [];
    int len = bigString.length;
    for (int i = 0; i < len; i += _chunkSize) {
      int end = (i + _chunkSize < len) ? i + _chunkSize : len;
      chunks.add(bigString.substring(i, end));
    }
    return chunks;
  }

  /// 3. Reassemble List of Strings to Uint8List (for Image.memory)
  static Uint8List reassembleToBytes(List<String> chunks) {
    final buffer = StringBuffer();
    for (String chunk in chunks) {
      buffer.write(chunk);
    }
    return base64Decode(buffer.toString());
  }
}