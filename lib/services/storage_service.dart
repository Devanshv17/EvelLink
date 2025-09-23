import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import '../utils/b2_config.dart';  // Import B2Config from utils

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // B2 API URLs (populated dynamically)
  String? _apiUrl;
  String? _authorizationToken;
  String? _downloadUrl;
  String? _bucketId;
  String? _accountId;

  /// Authorize with Backblaze B2 and get access token using B2Config
  Future<bool> _authorize() async {
    try {
      final credentials = base64Encode(utf8.encode('${B2Config.keyId}:${B2Config.applicationKey}'));

      final response = await http.get(
        Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authorizationToken = data['authorizationToken'];
        _apiUrl = data['apiUrl'];
        _downloadUrl = data['downloadUrl'];
        _accountId = data['accountId'];

        await _getBucketId();
        return true;
      } else {
        print('B2 Authorization failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('B2 Authorization error: $e');
      return false;
    }
  }

  Future<void> _getBucketId() async {
    if (_authorizationToken == null || _apiUrl == null) return;

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_list_buckets'),
        headers: {
          'Authorization': _authorizationToken!,
          'Content-Type': 'application/json',
        },
        body: json.encode({'accountId': _accountId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final buckets = data['buckets'] as List;
        for (var bucket in buckets) {
          if (bucket['bucketName'] == B2Config.bucketName) {
            _bucketId = bucket['bucketId'];
            break;
          }
        }
        if (_bucketId == null) {
          print('Bucket "${B2Config.bucketName}" not found');
        }
      }
    } catch (e) {
      print('Get bucket ID error: $e');
    }
  }

  Future<Map<String, String>?> _getUploadUrl() async {
    if (_authorizationToken == null || _bucketId == null) {
      final authSuccess = await _authorize();
      if (!authSuccess) return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/b2api/v2/b2_get_upload_url'),
        headers: {
          'Authorization': _authorizationToken!,
          'Content-Type': 'application/json',
        },
        body: json.encode({'bucketId': _bucketId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'uploadUrl': data['uploadUrl'],
          'authorizationToken': data['authorizationToken'],
        };
      } else {
        print('Get upload URL failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Get upload URL error: $e');
    }
    return null;
  }

  Future<String?> _uploadFile(File file, String fileName) async {
    if (_authorizationToken == null || _bucketId == null) {
      bool authorized = await _authorize();
      if (!authorized) return null;
    }

    final uploadInfo = await _getUploadUrl();
    if (uploadInfo == null) return null;

    try {
      final fileBytes = await file.readAsBytes();
      final contentType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final sha1Hash = sha1.convert(fileBytes).toString();

      final response = await http.post(
        Uri.parse(uploadInfo['uploadUrl']!),
        headers: {
          'Authorization': uploadInfo['authorizationToken']!,
          'X-Bz-File-Name': Uri.encodeComponent(fileName),
          'Content-Type': contentType,
          'X-Bz-Content-Sha1': sha1Hash,
          'Content-Length': fileBytes.length.toString(),
        },
        body: fileBytes,
      );

      if (response.statusCode == 200) {
        if (B2Config.customDomain != null) {
          return '${B2Config.customDomain}/$fileName';
        } else {
          return '$_downloadUrl/file/${B2Config.bucketName}/$fileName';
        }
      } else {
        print('Upload failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Upload file error: $e');
    }
    return null;
  }

  Future<List<String>> uploadUserPhotos(String userId, List<XFile> images) async {
    final photoUrls = <String>[];

    for (var i = 0; i < images.length; i++) {
      final file = File(images[i].path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.extension(images[i].path).toLowerCase();
      // Validate format
      final formatName = ext.replaceFirst('.', '');
      if (!B2Config.supportedFormats.contains(formatName)) {
        print('Unsupported image format: $ext');
        continue;
      }

      final fileName = '${B2Config.userPhotosPrefix}$userId/image_${timestamp}_$i$ext';

      final url = await _uploadFile(file, fileName);
      if (url != null) {
        photoUrls.add(url);
      }
    }

    return photoUrls;
  }

  Future<List<XFile>> pickImages({int maxImages = 4}) async {
    try {
      final images = await _picker.pickMultiImage();
      if (images.length > maxImages) {
        return images.take(maxImages).toList();
      }
      return images;
    } catch (e) {
      print('Error picking images: $e');
      return [];
    }
  }

  Future<XFile?> pickSingleImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
