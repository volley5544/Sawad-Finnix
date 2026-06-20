import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/thai_id.dart';
import '../models/uploaded_file.dart';

/// Uploads loan-statement attachments to Firebase Storage.
///
/// Files are stored under the owning user, keyed by `sha256(thaiId)` to mirror
/// the Firestore layout:
///   `loan_statements/{sha256(thaiId)}/{timestamp}_{fileName}`
///
/// The Storage rules require `request.auth != null`, so an (anonymous) Firebase
/// Auth session is ensured before any upload/delete.
class StorageRepository {
  StorageRepository({
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  /// Uploads [bytes] as a loan statement for [thaiId], reporting progress in the
  /// range 0.0–1.0 via [onProgress]. Returns the stored file's metadata.
  Future<UploadedFile> uploadStatement({
    required String thaiId,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
    void Function(double progress)? onProgress,
  }) async {
    if (thaiId.isEmpty) {
      throw StateError('ไม่พบเลขบัตรประชาชนของผู้ใช้');
    }
    await _ensureSignedIn();

    final docId = ThaiId.hash(thaiId);
    final safeName = _sanitize(fileName);
    final objectName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref('loan_statements/$docId/$objectName');

    final task = ref.putData(
      bytes,
      SettableMetadata(contentType: contentType ?? _guessContentType(safeName)),
    );

    task.snapshotEvents.listen(
      (snapshot) {
        if (onProgress != null && snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      },
      onError: (Object e) => debugPrint('[storage] upload progress error: $e'),
    );

    final snapshot = await task;
    final url = await snapshot.ref.getDownloadURL();
    debugPrint('[storage] uploaded ${ref.fullPath} (${bytes.length} bytes)');

    return UploadedFile(
      name: fileName,
      path: ref.fullPath,
      url: url,
      size: bytes.length,
      contentType: contentType ?? _guessContentType(safeName),
      uploadedAt: DateTime.now(),
    );
  }

  /// Deletes a previously uploaded object by its storage [path].
  Future<void> delete(String path) async {
    if (path.isEmpty) return;
    await _ensureSignedIn();
    try {
      await _storage.ref(path).delete();
      debugPrint('[storage] deleted $path');
    } on FirebaseException catch (e) {
      // Already gone is fine; rethrow anything else.
      if (e.code != 'object-not-found') rethrow;
    }
  }

  String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[^\w.\-]+'), '_');

  String _guessContentType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}
