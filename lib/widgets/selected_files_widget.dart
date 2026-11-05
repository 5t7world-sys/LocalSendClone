import 'package:flutter/material.dart';
import '../models/file_info.dart';

/// Widget to display selected files
class SelectedFilesWidget extends StatelessWidget {
  final List<FileInfo> files;
  final Function(FileInfo) onRemove;

  const SelectedFilesWidget({
    super.key,
    required this.files,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final totalSize = files.fold<int>(0, (sum, file) => sum + file.size);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${files.length} file${files.length != 1 ? 's' : ''} selected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  _formatSize(totalSize),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  dense: true,
                  leading: Icon(_getFileIcon(file.fileType)),
                  title: Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(file.sizeString),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => onRemove(file),
                    tooltip: 'Remove',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? type) {
    if (type == null) return Icons.insert_drive_file;
    
    switch (type.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
        return Icons.audio_file;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
      case 'txt':
        return Icons.description;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'apk':
        return Icons.android;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1000) return '$bytes B';
    if (bytes < 1000000) return '${(bytes / 1000).toStringAsFixed(1)} KB';
    if (bytes < 1000000000) return '${(bytes / 1000000).toStringAsFixed(1)} MB';
    return '${(bytes / 1000000000).toStringAsFixed(2)} GB';
  }
}
