import 'dart:io';

/// File information model for transfer
class FileInfo {
  final String id;
  final String fileName;
  final int size;
  final String? fileType;
  final String? preview;
  final String? metadata;
  final String? sha256;
  final File? file;
  final DateTime? modified;

  FileInfo({
    required this.id,
    required this.fileName,
    required this.size,
    this.fileType,
    this.preview,
    this.metadata,
    this.sha256,
    this.file,
    this.modified,
  });

  String get sizeString {
    if (size < 1000) return '$size B';
    if (size < 1000000) return '${(size / 1000).toStringAsFixed(1)} KB';
    if (size < 1000000000) return '${(size / 1000000).toStringAsFixed(1)} MB';
    return '${(size / 1000000000).toStringAsFixed(2)} GB';
  }

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      size: json['size'] as int,
      fileType: json['fileType'] as String?,
      preview: json['preview'] as String?,
      metadata: json['metadata'] as String?,
      sha256: json['sha256'] as String?,
      modified: json['modified'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['modified'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'size': size,
      'fileType': fileType,
      'preview': preview,
      'metadata': metadata,
      'sha256': sha256,
      'modified': modified?.millisecondsSinceEpoch,
    };
  }
}
