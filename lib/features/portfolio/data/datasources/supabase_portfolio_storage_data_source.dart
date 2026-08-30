// Implements project media uploads and deletes inside the public Supabase portfolio bucket.
import 'dart:developer';

import 'package:abdelrhman_protfolio/core/config/supabase_config.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/portfolio_storage_data_source.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/project_media_file.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePortfolioStorageDataSource implements PortfolioStorageDataSource {
  static const _bucket = 'portfolio';

  SupabaseClient get _client {
    if (!SupabaseConfig.hasCredentials) {
      throw StateError('SUPABASE_ANON_KEY is required for media uploads.');
    }
    return Supabase.instance.client;
  }

  @override
  Future<List<String>> uploadImages(
    String folderId,
    List<ProjectMediaFile> files,
  ) async {
    final uploadedUrls = <String>[];
    try {
      for (final file in files) {
        final path = 'images/$folderId/${_uniqueName(file.name)}';
        debugPrint('Uploading portfolio image to $path');
        await _client.storage.from(_bucket).uploadBinary(path, file.bytes);
        uploadedUrls.add(_client.storage.from(_bucket).getPublicUrl(path));
      }
      return uploadedUrls;
    } catch (error, stackTrace) {
      debugPrint('Portfolio image upload failed.\n error : $error \n stackTrace : $stackTrace ');


      await deleteUrls(uploadedUrls);
      rethrow;
    }
  }

  @override
  Future<String> uploadVideo(String folderId, ProjectMediaFile file) async {
    final path = 'videos/$folderId/${_uniqueName(file.name)}';
     debugPrint('Uploading portfolio video to $path');
    await _client.storage.from(_bucket).uploadBinary(path, file.bytes);
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  @override
  Future<void> deleteUrls(Iterable<String> urls) async {
    final paths = urls.map(_pathFromPublicUrl).whereType<String>().toList();
    if (paths.isNotEmpty) await _client.storage.from(_bucket).remove(paths);
  }

  String _uniqueName(String fileName) {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return '${DateTime.now().microsecondsSinceEpoch}_$safeName';
  }

  String? _pathFromPublicUrl(String url) {
    final segments = Uri.parse(url).pathSegments;
    final bucketIndex = segments.indexOf(_bucket);
    if (bucketIndex < 0 || bucketIndex == segments.length - 1) return null;
    return segments.skip(bucketIndex + 1).join('/');
  }
}
