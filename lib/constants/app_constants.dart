/// App constants and configuration
class AppConstants {
  // App Info
  static const String appName = 'LocalSend';
  static const String appVersion = '1.18.2';
  static const String appDescription = 'Share files to nearby devices';
  
  // Network Configuration
  static const int defaultPort = 53317;
  static const String multicastGroup = '224.0.0.167';
  static const int multicastPort = 53317;
  static const String serviceType = '_localsend._tcp';
  static const String serviceDomain = 'local';
  
  // Protocol Configuration
  static const String protocolVersion = 'v2';
  static const String apiPrefix = '/api/v2';
  
  // Transfer Configuration
  static const int maxFileSize = 10 * 1024 * 1024 * 1024; // 10GB
  static const int chunkSize = 1024 * 1024; // 1MB
  static const int maxConcurrentTransfers = 5;
  static const Duration transferTimeout = Duration(minutes: 30);
  static const Duration deviceTimeout = Duration(seconds: 30);
  static const Duration announcementInterval = Duration(seconds: 5);
  
  // Storage Configuration
  static const String defaultSaveFolder = 'LocalSend';
  static const int maxHistoryItems = 30;
  
  // UI Configuration
  static const String defaultDeviceIcon = '📱';
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  
  // Color Configuration (LocalSend brand color)
  static const int primaryColorValue = 0xFF4CAF50; // Green
  static const int accentColorValue = 0xFF81C784; // Light Green
  
  // Feature Flags
  static const bool enableHttps = false; // Default: HTTP
  static const bool enableChecksum = true;
  static const bool enableCompression = false;
  static const bool enableMulticast = true;
  
  // API Endpoints
  static const String endpointInfo = '/info';
  static const String endpointPrepare = '/prepare';
  static const String endpointUpload = '/upload';
  static const String endpointCancel = '/cancel';
  static const String endpointDownload = '/download';
  
  // Permissions
  static const List<String> requiredPermissions = [
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.ACCESS_WIFI_STATE',
    'android.permission.CHANGE_WIFI_MULTICAST_STATE',
  ];
  
  // GitHub
  static const String githubRepo = 'https://github.com/localsend/localsend';
  static const String githubIssues = 'https://github.com/localsend/localsend/issues';
  
  // Support
  static const String websiteUrl = 'https://localsend.org';
  static const String discordUrl = 'https://discord.gg/GSRWmQNP87';
}

/// Device types
enum DeviceType {
  mobile,
  desktop,
  web,
  headless;
  
  String get icon {
    switch (this) {
      case DeviceType.mobile:
        return '📱';
      case DeviceType.desktop:
        return '💻';
      case DeviceType.web:
        return '🌐';
      case DeviceType.headless:
        return '🤖';
    }
  }
}

/// Transfer status
enum TransferStatus {
  idle,
  preparing,
  sending,
  receiving,
  completed,
  failed,
  cancelled;
  
  bool get isActive => this == TransferStatus.sending || this == TransferStatus.receiving;
  bool get isFinished => this == TransferStatus.completed || this == TransferStatus.failed || this == TransferStatus.cancelled;
}

/// File categories for UI grouping
enum FileCategory {
  document,
  image,
  video,
  audio,
  archive,
  other;
  
  String get icon {
    switch (this) {
      case FileCategory.document:
        return '📄';
      case FileCategory.image:
        return '🖼️';
      case FileCategory.video:
        return '🎬';
      case FileCategory.audio:
        return '🎵';
      case FileCategory.archive:
        return '📦';
      case FileCategory.other:
        return '📎';
    }
  }
  
  static FileCategory fromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return FileCategory.image;
    if (mimeType.startsWith('video/')) return FileCategory.video;
    if (mimeType.startsWith('audio/')) return FileCategory.audio;
    if (mimeType.startsWith('application/pdf') || 
        mimeType.startsWith('application/msword') ||
        mimeType.startsWith('text/')) return FileCategory.document;
    if (mimeType.contains('zip') || 
        mimeType.contains('rar') || 
        mimeType.contains('7z')) return FileCategory.archive;
    return FileCategory.other;
  }
}
