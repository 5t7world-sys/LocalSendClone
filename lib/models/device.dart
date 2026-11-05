/// Device model representing a discovered device on the network
class Device {
  final String id;
  final String alias;
  final String? deviceModel;
  final String? deviceType;
  final String fingerprint;
  final String ip;
  final int port;
  final bool https;
  final String? version;
  final bool announcement;
  final int? download;
  final DateTime discoveredAt;
  
  Device({
    required this.id,
    required this.alias,
    this.deviceModel,
    this.deviceType,
    required this.fingerprint,
    required this.ip,
    required this.port,
    this.https = false,
    this.version,
    this.announcement = false,
    this.download,
    required this.discoveredAt,
  });

  String get baseUrl => '${https ? 'https' : 'http'}://$ip:$port';

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      alias: json['alias'] as String,
      deviceModel: json['deviceModel'] as String?,
      deviceType: json['deviceType'] as String?,
      fingerprint: json['fingerprint'] as String,
      ip: json['ip'] as String,
      port: json['port'] as int,
      https: json['https'] as bool? ?? false,
      version: json['version'] as String?,
      announcement: json['announcement'] as bool? ?? false,
      download: json['download'] as int?,
      discoveredAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alias': alias,
      'deviceModel': deviceModel,
      'deviceType': deviceType,
      'fingerprint': fingerprint,
      'ip': ip,
      'port': port,
      'https': https,
      'version': version,
      'announcement': announcement,
      'download': download,
    };
  }

  Device copyWith({
    String? id,
    String? alias,
    String? deviceModel,
    String? deviceType,
    String? fingerprint,
    String? ip,
    int? port,
    bool? https,
    String? version,
    bool? announcement,
    int? download,
    DateTime? discoveredAt,
  }) {
    return Device(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceType: deviceType ?? this.deviceType,
      fingerprint: fingerprint ?? this.fingerprint,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      https: https ?? this.https,
      version: version ?? this.version,
      announcement: announcement ?? this.announcement,
      download: download ?? this.download,
      discoveredAt: discoveredAt ?? this.discoveredAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device && other.fingerprint == fingerprint;
  }

  @override
  int get hashCode => fingerprint.hashCode;
}
