import 'device.dart';
import 'file_info.dart';

enum TransferStatus {
  pending,
  preparing,
  sending,
  receiving,
  finished,
  failed,
  cancelled,
  declined,
}

enum TransferDirection {
  send,
  receive,
}

class TransferState {
  final String id;
  final Device device;
  final List<FileInfo> files;
  final TransferStatus status;
  final TransferDirection direction;
  final double progress;
  final int? bytesTransferred;
  final int? totalBytes;
  final DateTime startTime;
  final DateTime? endTime;
  final String? errorMessage;
  final int? speed; // bytes per second
  final Duration? remainingTime;

  TransferState({
    required this.id,
    required this.device,
    required this.files,
    required this.status,
    required this.direction,
    this.progress = 0.0,
    this.bytesTransferred,
    this.totalBytes,
    required this.startTime,
    this.endTime,
    this.errorMessage,
    this.speed,
    this.remainingTime,
  });

  String get speedString {
    if (speed == null) return '0 B/s';
    if (speed! < 1000) return '$speed B/s';
    if (speed! < 1000000) return '${(speed! / 1000).toStringAsFixed(1)} KB/s';
    if (speed! < 1000000000) return '${(speed! / 1000000).toStringAsFixed(1)} MB/s';
    return '${(speed! / 1000000000).toStringAsFixed(2)} GB/s';
  }

  String get remainingTimeString {
    if (remainingTime == null) return 'Calculating...';
    final seconds = remainingTime!.inSeconds;
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m ${seconds % 60}s';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }

  TransferState copyWith({
    String? id,
    Device? device,
    List<FileInfo>? files,
    TransferStatus? status,
    TransferDirection? direction,
    double? progress,
    int? bytesTransferred,
    int? totalBytes,
    DateTime? startTime,
    DateTime? endTime,
    String? errorMessage,
    int? speed,
    Duration? remainingTime,
  }) {
    return TransferState(
      id: id ?? this.id,
      device: device ?? this.device,
      files: files ?? this.files,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      progress: progress ?? this.progress,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
      speed: speed ?? this.speed,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  factory TransferState.fromJson(Map<String, dynamic> json) {
    return TransferState(
      id: json['id'] as String,
      device: Device.fromJson(json['device'] as Map<String, dynamic>),
      files: (json['files'] as List)
          .map((f) => FileInfo.fromJson(f as Map<String, dynamic>))
          .toList(),
      status: TransferStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      direction: TransferDirection.values.firstWhere(
        (d) => d.toString() == json['direction'],
        orElse: () => TransferDirection.send,
      ),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      bytesTransferred: json['bytesTransferred'] as int?,
      totalBytes: json['totalBytes'] as int?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device': device.toJson(),
      'files': files.map((f) => f.toJson()).toList(),
      'status': status.toString(),
      'direction': direction.toString(),
      'progress': progress,
      'bytesTransferred': bytesTransferred,
      'totalBytes': totalBytes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }
}
