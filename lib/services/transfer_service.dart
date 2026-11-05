import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/device.dart';
import '../models/file_info.dart';
import '../models/transfer_state.dart';
import 'package:uuid/uuid.dart';

/// Service for handling file transfers (send and receive)
class TransferService {
  final _transferStateController = StreamController<TransferState>.broadcast();
  final _activeTransfers = <String, TransferState>{};
  
  Stream<TransferState> get transferStateStream => _transferStateController.stream;
  
  /// Send files to a device
  Future<void> sendFiles({
    required Device device,
    required List<FileInfo> files,
  }) async {
    final transferId = const Uuid().v4();
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.size);
    
    var transferState = TransferState(
      id: transferId,
      device: device,
      files: files,
      status: TransferStatus.preparing,
      direction: TransferDirection.send,
      totalBytes: totalBytes,
      startTime: DateTime.now(),
    );
    
    _activeTransfers[transferId] = transferState;
    _transferStateController.add(transferState);
    
    try {
      // Step 1: Prepare transfer (send metadata)
      final sessionId = await _prepareTransfer(device, files);
      
      transferState = transferState.copyWith(
        status: TransferStatus.sending,
      );
      _transferStateController.add(transferState);
      
      // Step 2: Upload files
      int bytesTransferred = 0;
      final startTime = DateTime.now();
      
      for (final file in files) {
        if (file.file == null) continue;
        
        await _uploadFile(
          device: device,
          sessionId: sessionId,
          fileInfo: file,
          onProgress: (bytes) {
            bytesTransferred += bytes;
            final elapsed = DateTime.now().difference(startTime);
            final speed = elapsed.inSeconds > 0 
                ? (bytesTransferred / elapsed.inSeconds).round()
                : 0;
            
            final remaining = speed > 0
                ? Duration(seconds: ((totalBytes - bytesTransferred) / speed).round())
                : null;
            
            transferState = transferState.copyWith(
              bytesTransferred: bytesTransferred,
              progress: bytesTransferred / totalBytes,
              speed: speed,
              remainingTime: remaining,
            );
            _transferStateController.add(transferState);
          },
        );
      }
      
      // Transfer complete
      transferState = transferState.copyWith(
        status: TransferStatus.finished,
        progress: 1.0,
        endTime: DateTime.now(),
      );
      _transferStateController.add(transferState);
      
      print('✅ Transfer complete: $transferId');
      
    } catch (e) {
      transferState = transferState.copyWith(
        status: TransferStatus.failed,
        errorMessage: e.toString(),
        endTime: DateTime.now(),
      );
      _transferStateController.add(transferState);
      print('❌ Transfer failed: $e');
    }
  }
  
  /// Prepare transfer by sending metadata to receiver
  Future<String> _prepareTransfer(Device device, List<FileInfo> files) async {
    final deviceInfo = await _getLocalDeviceInfo();
    
    final filesMap = <String, dynamic>{};
    for (final file in files) {
      filesMap[file.id] = file.toJson();
    }
    
    final body = {
      'info': deviceInfo,
      'files': filesMap,
    };
    
    final response = await http.post(
      Uri.parse('${device.baseUrl}/api/v2/prepare'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['sessionId'] as String;
    } else {
      throw Exception('Failed to prepare transfer: ${response.statusCode}');
    }
  }
  
  /// Upload a single file
  Future<void> _uploadFile({
    required Device device,
    required String sessionId,
    required FileInfo fileInfo,
    required Function(int bytes) onProgress,
  }) async {
    final file = fileInfo.file!;
    final fileBytes = await file.readAsBytes();
    
    // Calculate checksum if needed
    String? checksum;
    if (fileInfo.sha256 != null) {
      checksum = sha256.convert(fileBytes).toString();
    }
    
    final uri = Uri.parse('${device.baseUrl}/api/v2/upload');
    final request = http.MultipartRequest('POST', uri);
    
    request.fields['sessionId'] = sessionId;
    request.fields['fileId'] = fileInfo.id;
    if (checksum != null) {
      request.fields['sha256'] = checksum;
    }
    
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileInfo.fileName,
    );
    
    request.files.add(multipartFile);
    
    final response = await request.send();
    
    if (response.statusCode == 200) {
      onProgress(fileInfo.size);
    } else {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }
  
  /// Receive files from a device
  Future<void> receiveFiles({
    required String sessionId,
    required Device device,
    required List<FileInfo> files,
    required String savePath,
  }) async {
    final transferId = const Uuid().v4();
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.size);
    
    var transferState = TransferState(
      id: transferId,
      device: device,
      files: files,
      status: TransferStatus.receiving,
      direction: TransferDirection.receive,
      totalBytes: totalBytes,
      startTime: DateTime.now(),
    );
    
    _activeTransfers[transferId] = transferState;
    _transferStateController.add(transferState);
    
    try {
      int bytesTransferred = 0;
      final startTime = DateTime.now();
      
      // Download each file
      for (final file in files) {
        final filePath = path.join(savePath, file.fileName);
        
        // This would be implemented to actually receive the file
        // For now, simulate progress
        await Future.delayed(const Duration(milliseconds: 100));
        
        bytesTransferred += file.size;
        final elapsed = DateTime.now().difference(startTime);
        final speed = elapsed.inSeconds > 0 
            ? (bytesTransferred / elapsed.inSeconds).round()
            : 0;
        
        transferState = transferState.copyWith(
          bytesTransferred: bytesTransferred,
          progress: bytesTransferred / totalBytes,
          speed: speed,
        );
        _transferStateController.add(transferState);
      }
      
      transferState = transferState.copyWith(
        status: TransferStatus.finished,
        progress: 1.0,
        endTime: DateTime.now(),
      );
      _transferStateController.add(transferState);
      
    } catch (e) {
      transferState = transferState.copyWith(
        status: TransferStatus.failed,
        errorMessage: e.toString(),
        endTime: DateTime.now(),
      );
      _transferStateController.add(transferState);
    }
  }
  
  /// Cancel an active transfer
  Future<void> cancelTransfer(String transferId) async {
    final transfer = _activeTransfers[transferId];
    if (transfer == null) return;
    
    final updatedTransfer = transfer.copyWith(
      status: TransferStatus.cancelled,
      endTime: DateTime.now(),
    );
    
    _activeTransfers[transferId] = updatedTransfer;
    _transferStateController.add(updatedTransfer);
  }
  
  /// Get local device info for sending in requests
  Future<Map<String, dynamic>> _getLocalDeviceInfo() async {
    // This would get actual device info
    return {
      'id': 'device-id-123',
      'alias': 'My Device',
      'fingerprint': 'fingerprint-123',
      'port': 53317,
      'protocol': 'http',
    };
  }
  
  void dispose() {
    _transferStateController.close();
  }
}
