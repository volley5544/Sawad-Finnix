/// A file that has been uploaded to Firebase Storage.
///
/// [path] is the storage object path (used for deletion), [url] is the public
/// download URL persisted with the loan request.
class UploadedFile {
  const UploadedFile({
    required this.name,
    required this.path,
    required this.url,
    required this.size,
    this.contentType,
    this.uploadedAt,
  });

  final String name;
  final String path;
  final String url;
  final int size;
  final String? contentType;
  final DateTime? uploadedAt;

  /// Human-friendly size, e.g. "1.2 MB".
  String get readableSize {
    const kb = 1024;
    const mb = kb * 1024;
    if (size >= mb) return '${(size / mb).toStringAsFixed(1)} MB';
    if (size >= kb) return '${(size / kb).toStringAsFixed(0)} KB';
    return '$size B';
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'path': path,
        'url': url,
        'size': size,
        'contentType': contentType,
        'uploadedAt': (uploadedAt ?? DateTime.now()).toIso8601String(),
      };

  factory UploadedFile.fromMap(Map<String, dynamic> map) => UploadedFile(
        name: map['name'] as String? ?? '',
        path: map['path'] as String? ?? '',
        url: map['url'] as String? ?? '',
        size: (map['size'] as num?)?.toInt() ?? 0,
        contentType: map['contentType'] as String?,
        uploadedAt: map['uploadedAt'] != null
            ? DateTime.tryParse(map['uploadedAt'] as String)
            : null,
      );
}
