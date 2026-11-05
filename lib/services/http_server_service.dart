import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../models/device.dart';
import '../models/file_info.dart';
import '../utils/device_info.dart';

/// HTTP server service for receiving files and handling requests
class HttpServerService {
  static const int defaultPort = 53317;
  
  HttpServer? _server;
  int _port = defaultPort;
  bool _isRunning = false;
  
  final _transferRequestController = StreamController<TransferRequest>.broadcast();
  
  Stream<TransferRequest> get transferRequests => _transferRequestController.stream;
  bool get isRunning => _isRunning;
  int get port => _port;

  /// Start HTTP server
  Future<bool> start({int? port}) async {
    if (_isRunning) return true;
    
    _port = port ?? defaultPort;
    
    try {
      final app = Router();
      
      // API endpoints
      app.get('/api/v2/info', _handleInfo);
      app.post('/api/v2/prepare', _handlePrepare);
      app.post('/api/v2/upload', _handleUpload);
      app.post('/api/v2/cancel', _handleCancel);
      
      // Catch all handler
      app.all('/<ignored|.*>', (Request request) {
        return Response.notFound('Route not found');
      });

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(_corsMiddleware())
          .addHandler(app);

      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        _port,
      );
      
      _isRunning = true;
      print('✅ HTTP Server started on port $_port');
      return true;
    } catch (e) {
      print('❌ Failed to start HTTP server: $e');
      
      // Try with random port if default fails
      if (port == null) {
        return start(port: 0); // 0 means system assigns random port
      }
      return false;
    }
  }

  /// Stop HTTP server
  Future<void> stop() async {
    if (!_isRunning || _server == null) return;
    
    await _server!.close(force: true);
    _isRunning = false;
    print('🛑 HTTP Server stopped');
  }

  /// Handle /api/v2/info request
  Future<Response> _handleInfo(Request request) async {
    final deviceInfo = await DeviceInfoHelper.getDeviceInfo();
    final fingerprint = await DeviceInfoHelper.getFingerprint();
    
    final response = {
      'id': deviceInfo['id'],
      'alias': deviceInfo['alias'],
      'version': '1.0.0',
      'deviceModel': deviceInfo['deviceModel'],
      'deviceType': deviceInfo['deviceType'],
      'fingerprint': fingerprint,
      'port': _port,
      'protocol': 'http',
      'download': false,
      'announcement': true,
    };
    
    return Response.ok(
      jsonEncode(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Handle /api/v2/prepare request (incoming transfer request)
  Future<Response> _handlePrepare(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      final files = (data['files'] as Map<String, dynamic>).entries.map((entry) {
        return FileInfo.fromJson({
          'id': entry.key,
          ...entry.value as Map<String, dynamic>,
        });
      }).toList();
      
      final device = Device(
        id: data['info']['id'] as String,
        alias: data['info']['alias'] as String,
        fingerprint: data['info']['fingerprint'] as String,
        ip: request.context['shelf.io.connection_info'].remoteAddress.address,
        port: data['info']['port'] as int,
        discoveredAt: DateTime.now(),
      );
      
      // Emit transfer request for UI to handle
      final transferReq = TransferRequest(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        device: device,
        files: files,
      );
      
      _transferRequestController.add(transferReq);
      
      return Response.ok(
        jsonEncode({
          'sessionId': transferReq.sessionId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('❌ Error handling prepare: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to prepare transfer'}),
      );
    }
  }

  /// Handle /api/v2/upload request
  Future<Response> _handleUpload(Request request) async {
    try {
      // Handle file upload
      // This would save the file to designated location
      // For now, return success
      
      return Response.ok(
        jsonEncode({'status': 'success'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('❌ Error handling upload: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Upload failed'}),
      );
    }
  }

  /// Handle /api/v2/cancel request
  Future<Response> _handleCancel(Request request) async {
    return Response.ok(
      jsonEncode({'status': 'cancelled'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// CORS middleware
  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        
        final response = await handler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  Map<String, String> get _corsHeaders => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
  };

  void dispose() {
    stop();
    _transferRequestController.close();
  }
}

/// Transfer request model
class TransferRequest {
  final String sessionId;
  final Device device;
  final List<FileInfo> files;
  
  TransferRequest({
    required this.sessionId,
    required this.device,
    required this.files,
  });
}
