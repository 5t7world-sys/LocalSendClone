import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings state
class SettingsState {
  final String deviceAlias;
  final ThemeMode themeMode;
  final Color? customColor;
  final int port;
  final bool httpsEnabled;
  final bool autoAccept;
  final bool autoAcceptFavorites;
  final bool checksumEnabled;
  final String savePath;
  final String? pinCode;
  final Locale? locale;

  const SettingsState({
    required this.deviceAlias,
    this.themeMode = ThemeMode.system,
    this.customColor,
    this.port = 53317,
    this.httpsEnabled = false,
    this.autoAccept = false,
    this.autoAcceptFavorites = true,
    this.checksumEnabled = true,
    required this.savePath,
    this.pinCode,
    this.locale,
  });

  SettingsState copyWith({
    String? deviceAlias,
    ThemeMode? themeMode,
    Color? customColor,
    int? port,
    bool? httpsEnabled,
    bool? autoAccept,
    bool? autoAcceptFavorites,
    bool? checksumEnabled,
    String? savePath,
    String? pinCode,
    Locale? locale,
  }) {
    return SettingsState(
      deviceAlias: deviceAlias ?? this.deviceAlias,
      themeMode: themeMode ?? this.themeMode,
      customColor: customColor ?? this.customColor,
      port: port ?? this.port,
      httpsEnabled: httpsEnabled ?? this.httpsEnabled,
      autoAccept: autoAccept ?? this.autoAccept,
      autoAcceptFavorites: autoAcceptFavorites ?? this.autoAcceptFavorites,
      checksumEnabled: checksumEnabled ?? this.checksumEnabled,
      savePath: savePath ?? this.savePath,
      pinCode: pinCode ?? this.pinCode,
      locale: locale ?? this.locale,
    );
  }
}

/// Settings provider
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(const SettingsState(
          deviceAlias: 'My Device',
          savePath: '/storage/emulated/0/Download',
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      state = SettingsState(
        deviceAlias: prefs.getString('device_alias') ?? 'My Device',
        themeMode: ThemeMode.values[prefs.getInt('theme_mode') ?? 0],
        port: prefs.getInt('port') ?? 53317,
        httpsEnabled: prefs.getBool('https_enabled') ?? false,
        autoAccept: prefs.getBool('auto_accept') ?? false,
        autoAcceptFavorites: prefs.getBool('auto_accept_favorites') ?? true,
        checksumEnabled: prefs.getBool('checksum_enabled') ?? true,
        savePath: prefs.getString('save_path') ?? '/storage/emulated/0/Download',
        pinCode: prefs.getString('pin_code'),
      );
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> updateDeviceAlias(String alias) async {
    state = state.copyWith(deviceAlias: alias);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_alias', alias);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> updateCustomColor(Color? color) async {
    state = state.copyWith(customColor: color);
    final prefs = await SharedPreferences.getInstance();
    if (color != null) {
      await prefs.setInt('custom_color', color.value);
    } else {
      await prefs.remove('custom_color');
    }
  }

  Future<void> updatePort(int port) async {
    state = state.copyWith(port: port);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('port', port);
  }

  Future<void> updateHttpsEnabled(bool enabled) async {
    state = state.copyWith(httpsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('https_enabled', enabled);
  }

  Future<void> updateAutoAccept(bool enabled) async {
    state = state.copyWith(autoAccept: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_accept', enabled);
  }

  Future<void> updateAutoAcceptFavorites(bool enabled) async {
    state = state.copyWith(autoAcceptFavorites: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_accept_favorites', enabled);
  }

  Future<void> updateChecksumEnabled(bool enabled) async {
    state = state.copyWith(checksumEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checksum_enabled', enabled);
  }

  Future<void> updateSavePath(String path) async {
    state = state.copyWith(savePath: path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('save_path', path);
  }

  Future<void> updatePinCode(String? pin) async {
    state = state.copyWith(pinCode: pin);
    final prefs = await SharedPreferences.getInstance();
    if (pin != null && pin.isNotEmpty) {
      await prefs.setString('pin_code', pin);
    } else {
      await prefs.remove('pin_code');
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
