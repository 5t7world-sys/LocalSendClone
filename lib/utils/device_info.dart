import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Helper class for device information
class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _cachedFingerprint;
  static Map<String, dynamic>? _cachedDeviceInfo;

  /// Get device fingerprint (unique identifier)
  static Future<String> getFingerprint() async {
    if (_cachedFingerprint != null) return _cachedFingerprint!;
    
    try {
      String identifier = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        identifier = androidInfo.id ?? androidInfo.fingerprint ?? '';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        identifier = iosInfo.identifierForVendor ?? '';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        identifier = linuxInfo.machineId ?? '';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        identifier = windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        identifier = macInfo.systemGUID ?? '';
      }
      
      // Generate SHA256 hash of identifier
      final bytes = utf8.encode(identifier);
      final digest = sha256.convert(bytes);
      _cachedFingerprint = digest.toString();
      
      return _cachedFingerprint!;
    } catch (e) {
      print('Error getting fingerprint: $e');
      return 'unknown-fingerprint';
    }
  }

  /// Get device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) return _cachedDeviceInfo!;
    
    try {
      String alias = '';
      String deviceModel = '';
      String deviceType = 'mobile';
      String id = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        alias = androidInfo.model ?? 'Android Device';
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        deviceType = androidInfo.isPhysicalDevice ? 'mobile' : 'emulator';
        id = androidInfo.id ?? '';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        alias = iosInfo.name ?? 'iOS Device';
        deviceModel = iosInfo.model ?? '';
        deviceType = 'mobile';
        id = iosInfo.identifierForVendor ?? '';
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        alias = linuxInfo.prettyName ?? 'Linux PC';
        deviceModel = linuxInfo.name ?? '';
        deviceType = 'desktop';
        id = linuxInfo.machineId ?? '';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        alias = windowsInfo.computerName;
        deviceModel = 'Windows PC';
        deviceType = 'desktop';
        id = windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        alias = macInfo.computerName;
        deviceModel = macInfo.model ?? '';
        deviceType = 'desktop';
        id = macInfo.systemGUID ?? '';
      }
      
      _cachedDeviceInfo = {
        'id': id.isNotEmpty ? id : await getFingerprint(),
        'alias': alias,
        'deviceModel': deviceModel,
        'deviceType': deviceType,
      };
      
      return _cachedDeviceInfo!;
    } catch (e) {
      print('Error getting device info: $e');
      return {
        'id': 'unknown',
        'alias': 'Unknown Device',
        'deviceModel': 'Unknown',
        'deviceType': 'mobile',
      };
    }
  }

  /// Clear cached values
  static void clearCache() {
    _cachedFingerprint = null;
    _cachedDeviceInfo = null;
  }
}
