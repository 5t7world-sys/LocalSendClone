import 'dart:async';
import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';
import '../models/device.dart';
import '../utils/device_info.dart';

/// Service for discovering devices on local network using mDNS
class DiscoveryService {
  static const String serviceType = '_sharedrop._tcp';
  static const int defaultPort = 53317;
  
  final _discoveredDevices = <String, Device>{};
  final _deviceStreamController = StreamController<List<Device>>.broadcast();
  
  MDnsClient? _mdnsClient;
  Timer? _announceTimer;
  bool _isRunning = false;

  Stream<List<Device>> get devicesStream => _deviceStreamController.stream;
  List<Device> get devices => _discoveredDevices.values.toList();

  /// Start device discovery
  Future<void> startDiscovery() async {
    if (_isRunning) return;
    
    try {
      _isRunning = true;
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();
      
      // Start listening for devices
      _listenForDevices();
      
      // Announce this device periodically
      _startPeriodicAnnouncement();
      
      print('✅ Discovery service started');
    } catch (e) {
      print('❌ Failed to start discovery: $e');
      _isRunning = false;
    }
  }

  /// Stop device discovery
  Future<void> stopDiscovery() async {
    if (!_isRunning) return;
    
    _isRunning = false;
    _announceTimer?.cancel();
    _mdnsClient?.stop();
    _discoveredDevices.clear();
    _deviceStreamController.add([]);
    
    print('🛑 Discovery service stopped');
  }

  /// Listen for device announcements
  void _listenForDevices() {
    _mdnsClient!
        .lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(serviceType),
        )
        .listen((PtrResourceRecord ptr) async {
      // Get service details
      final srvRecords = await _mdnsClient!
          .lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName),
          )
          .toList();

      final txtRecords = await _mdnsClient!
          .lookup<TxtResourceRecord>(
            ResourceRecordQuery.text(ptr.domainName),
          )
          .toList();

      final ipRecords = await _mdnsClient!
          .lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(ptr.domainName),
          )
          .toList();

      if (srvRecords.isNotEmpty && ipRecords.isNotEmpty) {
        final srv = srvRecords.first;
        final ip = ipRecords.first;
        
        // Parse TXT records for device info
        final Map<String, String> txtData = {};
        for (final txt in txtRecords) {
          for (final data in txt.text.split('\n')) {
            final parts = data.split('=');
            if (parts.length == 2) {
              txtData[parts[0]] = parts[1];
            }
          }
        }

        final device = Device(
          id: txtData['id'] ?? '',
          alias: txtData['alias'] ?? 'Unknown Device',
          fingerprint: txtData['fingerprint'] ?? '',
          ip: ip.address.address,
          port: srv.port,
          https: txtData['https'] == 'true',
          version: txtData['version'],
          deviceType: txtData['deviceType'],
          deviceModel: txtData['deviceModel'],
          discoveredAt: DateTime.now(),
        );

        // Don't add self
        final selfFingerprint = await DeviceInfoHelper.getFingerprint();
        if (device.fingerprint != selfFingerprint) {
          _discoveredDevices[device.fingerprint] = device;
          _deviceStreamController.add(devices);
          print('📱 Discovered: ${device.alias} (${device.ip}:${device.port})');
        }
      }
    });
  }

  /// Announce this device on network
  void _startPeriodicAnnouncement() {
    _announceDevice(); // Announce immediately
    
    // Then announce every 5 seconds
    _announceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _announceDevice();
    });
  }

  /// Announce this device
  Future<void> _announceDevice() async {
    try {
      final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
      final fingerprint = await DeviceInfoHelper.getFingerprint();
      
      // Create TXT record with device info
      final txtData = [
        'id=${deviceInfo['id']}',
        'alias=${deviceInfo['alias']}',
        'fingerprint=$fingerprint',
        'version=1.0.0',
        'deviceType=${deviceInfo['deviceType']}',
        'deviceModel=${deviceInfo['deviceModel']}',
        'https=false',
      ].join('\n');

      // Announce service
      await _mdnsClient!.announce(
        ResourceRecordQuery.serverPointer(serviceType),
        [
          PtrResourceRecord(serviceType, DateTime.now().millisecondsSinceEpoch),
          TxtResourceRecord(serviceType, DateTime.now().millisecondsSinceEpoch, txtData),
        ],
      );
    } catch (e) {
      print('⚠️ Failed to announce device: $e');
    }
  }

  /// Manually scan for devices
  Future<void> scanDevices() async {
    if (!_isRunning) await startDiscovery();
    
    // Clear old devices (older than 30 seconds)
    final now = DateTime.now();
    _discoveredDevices.removeWhere((key, device) {
      return now.difference(device.discoveredAt).inSeconds > 30;
    });
    
    _deviceStreamController.add(devices);
    print('🔍 Manual scan initiated');
  }

  /// Remove a device from discovered list
  void removeDevice(String fingerprint) {
    _discoveredDevices.remove(fingerprint);
    _deviceStreamController.add(devices);
  }

  void dispose() {
    stopDiscovery();
    _deviceStreamController.close();
  }
}
