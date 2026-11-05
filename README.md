# 🚀 LocalSend Clone - ShareDrop Pro

**ShareDrop Pro** - A complete clone of LocalSend v1.18.2 with all features

## 📱 About

ShareDrop Pro is a cross-platform file sharing application that allows seamless file transfer between devices over local network (Wi-Fi) without internet connection. Built with Flutter and designed for performance and security.

## ✨ Features

### Core Features
- 📡 **Local Network Discovery** - Automatic device discovery using mDNS
- 📁 **Fast File Transfer** - Multi-threaded HTTP-based transfer
- 🖼️ **Multiple File Types** - Documents, images, videos, any file type
- 💬 **Text Messages** - Share text and links instantly
- ⭐ **Favorites** - Save trusted devices for quick access
- 📊 **Transfer History** - Track all your transfers
- 🎨 **Custom Themes** - Personalize with color picker
- 🔒 **Secure Transfer** - Optional encryption and PIN protection

### Advanced Features
- 🌐 **Receive via Link** - Browser-based file sharing
- ✅ **Checksum Verification** - Ensure file integrity
- 🔄 **Background Transfer** - Continue transfers in background (Android)
- 📱 **Quick Share** - Share from other apps
- 🌍 **Multi-language** - 50+ languages support
- 🎯 **Auto Accept** - Automatically accept from favorites
- ⚡ **Resume Failed** - Retry failed transfers

## 🏗️ Architecture

```
Flutter (UI) + Dart (Logic) + Native (Performance)
├── Material Design UI
├── State Management (Riverpod)
├── HTTP Server/Client
├── mDNS Discovery
└── Native File I/O
```

## 📋 Requirements

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code
- Android SDK (for Android build)
- Minimum Android API 24 (Android 7.0)

## 🚀 Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/sharedrop-pro.git
cd sharedrop-pro
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📦 Dependencies

Main packages used:
- `riverpod` - State management
- `shelf` - HTTP server
- `http` - HTTP client
- `multicast_dns` - Device discovery
- `file_picker` - File selection
- `path_provider` - File system access
- `shared_preferences` - Local storage
- `crypto` - Checksum verification
- `permission_handler` - Permissions
- `wakelock_plus` - Prevent sleep
- `receive_sharing_intent` - Share target
- `flex_color_picker` - Color themes

## 🎯 How It Works

### Device Discovery
1. App starts HTTP server on local port (default: 53317)
2. Broadcasts mDNS announcement on local network
3. Listens for other devices' announcements
4. Displays discovered devices in UI

### File Transfer
1. User selects files and target device
2. App sends transfer request with file metadata
3. Receiver accepts or rejects
4. Files transferred via HTTP in chunks
5. Checksum verified (optional)
6. Transfer complete notification

## 🔒 Security

- **Local Network Only** - No internet communication
- **Optional Encryption** - HTTPS with self-signed certificates
- **PIN Protection** - Password protect receiving
- **Checksum Verification** - MD5/SHA256 integrity check
- **Path Traversal Protection** - Secure file handling
- **No Data Collection** - Privacy-first design

## 📱 Platform Support

- ✅ Android (7.0+)
- ✅ iOS (11.0+)
- ✅ Windows (10+)
- ✅ macOS (10.14+)
- ✅ Linux (Ubuntu 20.04+)

## 🌐 Network Protocol

### Discovery (mDNS)
- Service: `_sharedrop._tcp.local`
- Port: 53317 (configurable)
- TXT Records: alias, version, fingerprint

### Transfer API
- `GET /api/v2/info` - Device info
- `POST /api/v2/prepare` - Transfer request
- `POST /api/v2/upload` - Upload files
- `POST /api/v2/cancel` - Cancel transfer

## 🎨 Customization

### Change Device Name
Settings → General → Device Alias

### Custom Theme
Settings → Appearance → Color Theme

### Network Settings
Settings → Network → Port / HTTPS / Interface Filter

### Security Settings
Settings → Security → PIN Protection / Auto Accept

## 📸 Screenshots

(Screenshots will be added here)

## 🐛 Known Issues

- Large files (>2GB) may require additional testing
- Background transfer on iOS has limitations
- Some Android devices may need manual network permission

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Original LocalSend project for inspiration
- Flutter team for the amazing framework
- All open-source contributors

## 📞 Support

For issues and questions:
- GitHub Issues: [Project Issues](https://github.com/yourusername/sharedrop-pro/issues)
- Email: support@sharedrop.com

## 🔗 Links

- [Documentation](./docs/)
- [API Reference](./docs/API.md)
- [Reverse Engineering Report](./REVERSE_ENGINEERING_REPORT.md)

---

**Built with ❤️ using Flutter**

*Version: 1.0.0 (based on LocalSend v1.18.2)*
*Last Updated: November 5, 2026*
