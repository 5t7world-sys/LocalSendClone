import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../providers/settings_provider.dart';
import '../utils/device_info.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // General section
          _buildSectionHeader(context, 'General'),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Device Name'),
            subtitle: Text(settings.deviceAlias),
            trailing: const Icon(Icons.edit),
            onTap: () => _showEditDeviceNameDialog(context, ref, settings.deviceAlias),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeText(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Custom Color'),
            subtitle: const Text('Choose your accent color'),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: settings.customColor ?? Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
            onTap: () => _showColorPicker(context, ref, settings.customColor),
          ),

          const Divider(),

          // Network section
          _buildSectionHeader(context, 'Network'),
          ListTile(
            leading: const Icon(Icons.router),
            title: const Text('Port'),
            subtitle: Text('${settings.port}'),
            trailing: const Icon(Icons.edit),
            onTap: () => _showEditPortDialog(context, ref, settings.port),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.security),
            title: const Text('HTTPS'),
            subtitle: const Text('Use encrypted connection'),
            value: settings.httpsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateHttpsEnabled(value);
            },
          ),

          const Divider(),

          // Security section
          _buildSectionHeader(context, 'Security'),
          SwitchListTile(
            secondary: const Icon(Icons.verified_user),
            title: const Text('Checksum Verification'),
            subtitle: const Text('Verify file integrity with SHA256'),
            value: settings.checksumEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateChecksumEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.download),
            title: const Text('Auto Accept'),
            subtitle: const Text('Automatically accept all incoming files'),
            value: settings.autoAccept,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateAutoAccept(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.pin),
            title: const Text('PIN Protection'),
            subtitle: Text(settings.pinCode != null ? 'PIN set' : 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPinDialog(context, ref, settings.pinCode),
          ),

          const Divider(),

          // About section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(context: context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: const Text('View on GitHub'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open GitHub link
            },
          ),

          const SizedBox(height: 16),

          // Reset button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context, ref),
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Defaults'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showEditDeviceNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(settingsProvider.notifier).updateDeviceAlias(controller.text);
                DeviceInfoHelper.clearCache();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: ref.read(settingsProvider).themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(mode);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: ref.read(settingsProvider).themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(mode);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: ref.read(settingsProvider).themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(mode);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, Color? currentColor) {
    Color selectedColor = currentColor ?? Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            pickersEnabled: const {
              ColorPickerType.both: true,
              ColorPickerType.primary: true,
              ColorPickerType.accent: true,
              ColorPickerType.wheel: true,
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateCustomColor(selectedColor);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showEditPortDialog(BuildContext context, WidgetRef ref, int currentPort) {
    final controller = TextEditingController(text: currentPort.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Port Number'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Port',
            border: OutlineInputBorder(),
            helperText: 'Range: 1024-65535',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final port = int.tryParse(controller.text);
              if (port != null && port >= 1024 && port <= 65535) {
                ref.read(settingsProvider.notifier).updatePort(port);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context, WidgetRef ref, String? currentPin) {
    final controller = TextEditingController(text: currentPin);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN Protection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'PIN (leave empty to disable)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updatePinCode(
                controller.text.isEmpty ? null : controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset settings
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
