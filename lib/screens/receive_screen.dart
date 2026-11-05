import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/http_server_service.dart';

/// Receive screen for accepting incoming files
class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  bool _quickSave = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.router,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Listening for incoming files',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Port: ${settings.port}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: const Text('Online'),
                      backgroundColor: Colors.green.withOpacity(0.2),
                      avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick save toggle
            SwitchListTile(
              title: const Text('Quick Save'),
              subtitle: const Text('Automatically accept and save files'),
              value: _quickSave,
              onChanged: (value) {
                setState(() {
                  _quickSave = value;
                });
              },
              secondary: const Icon(Icons.flash_on),
            ),

            const SizedBox(height: 8),

            // Auto accept from favorites
            SwitchListTile(
              title: const Text('Auto Accept from Favorites'),
              subtitle: const Text('Automatically accept files from favorite devices'),
              value: settings.autoAcceptFavorites,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateAutoAcceptFavorites(value);
              },
              secondary: const Icon(Icons.star),
            ),

            const SizedBox(height: 24),

            // Save location
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Save Location'),
              subtitle: Text(settings.savePath),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showSaveLocationDialog();
              },
            ),

            const Divider(),

            const SizedBox(height: 16),

            // Receive via link button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showReceiveViaLinkDialog();
                },
                icon: const Icon(Icons.link),
                label: const Text('Receive via Link'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Center(
              child: Text(
                'Other devices on the same network can send you files',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Download'),
              subtitle: const Text('/storage/emulated/0/Download'),
              onTap: () {
                ref.read(settingsProvider.notifier).updateSavePath('/storage/emulated/0/Download');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Documents'),
              subtitle: const Text('/storage/emulated/0/Documents'),
              onTap: () {
                ref.read(settingsProvider.notifier).updateSavePath('/storage/emulated/0/Documents');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Custom'),
              onTap: () {
                Navigator.pop(context);
                // Show custom path input
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReceiveViaLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receive via Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code, size: 120),
            const SizedBox(height: 16),
            const Text('Scan this QR code from another device to send files'),
            const SizedBox(height: 16),
            Text(
              'http://192.168.1.100:53317',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Copy to clipboard
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }
}
