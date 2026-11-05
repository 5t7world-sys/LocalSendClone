import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/discovery_provider.dart';
import '../providers/transfer_provider.dart';
import '../models/file_info.dart';
import '../widgets/device_list_tile.dart';
import '../widgets/selected_files_widget.dart';
import 'package:uuid/uuid.dart';

/// Send screen for selecting files and sending to devices
class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final List<FileInfo> _selectedFiles = [];
  String _textMessage = '';

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesStreamProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Scan for devices',
            onPressed: () {
              ref.read(discoveryServiceProvider).scanDevices();
            },
          ),
          if (_selectedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all',
              onPressed: () {
                setState(() {
                  _selectedFiles.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Selected files preview
          if (_selectedFiles.isNotEmpty)
            SelectedFilesWidget(
              files: _selectedFiles,
              onRemove: (file) {
                setState(() {
                  _selectedFiles.remove(file);
                });
              },
            ),

          // File selection buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.file_present,
                    label: 'Files',
                    onPressed: _pickFiles,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.image,
                    label: 'Photos',
                    onPressed: _pickImages,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.folder,
                    label: 'Folder',
                    onPressed: _pickFolder,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.message,
                    label: 'Text',
                    onPressed: _showTextDialog,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.content_paste,
                    label: 'Clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // Nearby devices list
          Expanded(
            child: devicesAsync.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No devices found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Make sure devices are on the same network',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(discoveryServiceProvider).scanDevices();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Scan Again'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: devices.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isFavorite = favorites.contains(device.fingerprint);

                    return DeviceListTile(
                      device: device,
                      isFavorite: isFavorite,
                      onTap: () {
                        if (_selectedFiles.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select files to send'),
                            ),
                          );
                          return;
                        }
                        _sendToDevice(device);
                      },
                      onFavoriteToggle: () {
                        if (isFavorite) {
                          ref.read(favoritesProvider.notifier).removeFavorite(device.fingerprint);
                        } else {
                          ref.read(favoritesProvider.notifier).addFavorite(device.fingerprint);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        for (final file in result.files) {
          if (file.path != null) {
            _selectedFiles.add(FileInfo(
              id: const Uuid().v4(),
              fileName: file.name,
              size: file.size,
              fileType: file.extension,
            ));
          }
        }
      });
    }
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        for (final file in result.files) {
          if (file.path != null) {
            _selectedFiles.add(FileInfo(
              id: const Uuid().v4(),
              fileName: file.name,
              size: file.size,
              fileType: file.extension,
            ));
          }
        }
      });
    }
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected folder: $result')),
      );
    }
  }

  void _showTextDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Text Message'),
        content: TextField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your message...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _textMessage = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_textMessage.isNotEmpty) {
                setState(() {
                  _selectedFiles.add(FileInfo(
                    id: const Uuid().v4(),
                    fileName: 'message.txt',
                    size: _textMessage.length,
                    fileType: 'text',
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _pasteFromClipboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clipboard feature coming soon')),
    );
  }

  void _sendToDevice(device) {
    final transferService = ref.read(transferServiceProvider);
    transferService.sendFiles(device: device, files: _selectedFiles);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending to ${device.alias}...')),
    );

    setState(() {
      _selectedFiles.clear();
    });
  }
}
