# LocalSend v1.18.2 - Complete Reverse Engineering Report

## 📱 Executive Summary

**LocalSend** ek advanced, cross-platform file sharing application hai jo **Flutter** aur **Rust** technology stack par bana hai. Yeh app local network (Wi-Fi) ke through devices ke beech secure file transfer karta hai bina internet connection ke.

### Key Technology Stack:
- **Frontend**: Flutter (Dart)
- **Backend/Performance**: Rust (librust_lib_localsend_app.so - 16MB)
- **UI Framework**: Material Design with Yaru theme
- **Network Protocol**: HTTP/HTTPS with Multicast DNS discovery
- **Platform**: Cross-platform (Android, iOS, Windows, macOS, Linux)

---

## 🏗️ Architecture Overview

### 1. **Core Components**

```
LocalSend Architecture
├── Flutter UI Layer (Dart)
│   ├── Material Design UI
│   ├── State Management
│   └── Platform-specific Integrations
│
├── Rust Core Layer (Native)
│   ├── HTTP Client/Server (Multithreaded)
│   ├── File I/O Operations
│   ├── Network Discovery (Multicast)
│   └── Encryption/Security
│
└── Platform Native Layer
    ├── Android (Java/Kotlin)
    ├── iOS (Swift/Objective-C)
    └── Desktop (Platform APIs)
```

### 2. **Native Libraries Analysis**

Extracted from APK split:
```
libapp.so                      14MB   - Flutter compiled Dart code
libflutter.so                  11MB   - Flutter engine
librust_lib_localsend_app.so   16MB   - Core Rust implementation ⭐
libdartjni.so                  128KB  - Dart-Java JNI bridge
libdatastore_shared_counter.so 6.9KB  - Shared preferences/data
```

**Key Insight**: Rust library sabse bada hai (16MB), indicating heavy networking aur file transfer logic Rust mein implement kiya gaya hai performance ke liye.

---

## 🔧 Core Functionality Analysis

### 1. **Device Discovery Mechanism**

LocalSend devices ko discover karne ke liye **Multicast DNS (mDNS)** use karta hai:

**Working Process**:
1. App start hote hi HTTP server local port par start hota hai
2. Multicast announcement broadcast hoti hai local network par
3. Dusre devices bhi apni presence announce karte hain
4. Device information exchange hoti hai (name, alias, IP, port)
5. Device list UI mein display hoti hai

**Key Features**:
- IPv4 aur IPv6 support
- Network interface filtering (advanced settings)
- Automatic server restart on failure
- Proxy detection aur bypass

### 2. **File Transfer Protocol**

**Transfer Flow**:
```
Sender                          Receiver
  |                                |
  |-- Discovery (mDNS) ----------->|
  |<-- Acknowledge ----------------|
  |                                |
  |-- Request (file metadata) ---->|
  |<-- Accept/Reject --------------|
  |                                |
  |-- HTTP Upload (chunked) ------>|
  |<-- Progress updates ----------|
  |                                |
  |-- Checksum verify ------------>|
  |<-- Complete -------------------|
```

**Technical Details**:
- **Protocol**: HTTP/HTTPS
- **Method**: Chunked transfer encoding
- **Speed Optimization**: Multithreading (Rust implementation)
- **Security**: Optional encryption, checksum verification (MD5/SHA256)
- **Background Transfer**: Android service for background operation

### 3. **File Types Support**

- Documents (PDF, TXT, DOCX, etc.)
- Images (JPG, PNG, GIF, WEBP, DNG, etc.)
- Videos (MP4, AVI, MKV, etc.)
- Audio files
- Archives (ZIP, RAR, 7z, etc.)
- Any file type (generic file transfer)

### 4. **Advanced Features**

#### a) **Receive via Link** 🔗
- Web-based file sharing
- Browser access through local network
- Drag-and-drop support
- Optional PIN protection
- Custom HTML pages support

#### b) **Favorites System** ⭐
- Device ko favorite mark karo
- Auto-accept files from favorites
- Quick access to trusted devices

#### c) **Quick Share Mode**
- Quick settings tile (Android)
- System share sheet integration
- Command-line support (`--text` flag)

#### d) **History & Management**
- Transfer history (last 30 items)
- Text messages saved
- File timestamps preserved
- Retry failed transfers

#### e) **Customization**
- Custom color themes (color picker)
- Device alias/name change
- Save location preference
- Auto-receive settings
- Animation preferences

---

## 📦 Flutter Packages Used

Analyzed from APK:

1. **yaru** - Ubuntu/Linux design system
2. **flex_color_picker** - Custom color theme picker
3. **wakelock_plus** - Keep device awake during transfer
4. **wechat_assets_picker** - Media file picker
5. **Material Icons** - Icon set

---

## 🎨 UI/UX Design Analysis

### Screen Structure:

```
Main App
├── Home Screen
│   ├── Nearby Devices List
│   ├── Send Tab
│   │   ├── File Picker
│   │   ├── Media Picker
│   │   ├── Clipboard
│   │   └── Text Message
│   └── Receive Tab
│       ├── Quick Save Toggle
│       ├── Save Location
│       └── Receive via Link
│
├── Settings Screen
│   ├── General Settings
│   │   ├── Device Alias
│   │   ├── Theme/Color
│   │   └── Language
│   ├── Network Settings
│   │   ├── Port Configuration
│   │   ├── HTTPS/Encryption
│   │   └── Network Interface Filter
│   ├── Security
│   │   ├── PIN Protection
│   │   └── Auto Accept
│   └── Advanced
│       ├── Checksum Verification
│       ├── Multi-threading
│       └── Debug Options
│
├── Transfer Screen
│   ├── Progress Indicators
│   ├── Speed/Time Remaining
│   ├── Accept/Reject Buttons
│   └── Cancel Option
│
└── History Screen
    ├── Recent Transfers
    ├── Text Messages
    └── Actions (Open, Share, Delete)
```

### Design Patterns:
- **Material Design 3** principles
- **Bottom Navigation Bar** for main tabs
- **FAB (Floating Action Button)** for quick actions
- **Swipe gestures** for media selection
- **Drag-and-drop** support
- **Adaptive layouts** for different screen sizes

---

## 🔒 Security Features

1. **Encryption**: Optional HTTPS with self-signed certificates
2. **Checksum Verification**: MD5/SHA256 for data integrity
3. **PIN Protection**: Password protection for receiving
4. **No Internet Required**: All communication local network only
5. **Path Traversal Protection**: Security fix in v1.17.0
6. **No Redirect Following**: Security enhancement in v1.18.2
7. **Permission Management**: Minimal permissions required

---

## 📱 Android-Specific Features

1. **Background Service**: File transfer continues in background
2. **Quick Settings Tile**: Quick launch from notification shade
3. **Share Target**: Receive files from other apps
4. **Gallery Integration**: Auto-save to gallery
5. **Notification Support**: Progress notifications
6. **Wake Lock**: Prevent sleep during transfer
7. **Permissions**:
   - `ACCESS_WIFI_STATE`
   - `ACCESS_NETWORK_STATE`
   - `INTERNET`
   - `READ_EXTERNAL_STORAGE`
   - `WRITE_EXTERNAL_STORAGE`
   - `ACCESS_LOCAL_NETWORK` (Android 17+)
   - `WAKE_LOCK`
   - `FOREGROUND_SERVICE`

---

## 🌐 Network Protocol Details

### Discovery Protocol (mDNS):
```
Service Type: _localsend._tcp.local
Port: 53317 (default, configurable)
TXT Records:
  - alias: Device display name
  - version: Protocol version
  - fingerprint: Device identifier
```

### Transfer API Endpoints:
```
GET  /api/v2/info          - Device information
POST /api/v2/prepare       - Prepare transfer (metadata)
POST /api/v2/upload        - Upload file chunks
POST /api/v2/cancel        - Cancel transfer
GET  /api/v2/download/:id  - Download file
```

---

## 📊 Performance Optimizations

1. **Rust Core**: High-performance file I/O aur networking
2. **Multithreading**: Parallel file transfers
3. **Chunked Transfer**: Memory-efficient large file handling
4. **Network Scanning**: Separate threads (UI lag nahi hoti)
5. **Memory Management**: Large files bhi efficiently handle hoti hain
6. **Compression**: Optional compression for faster transfers

---

## 🌍 Internationalization (i18n)

LocalSend **50+ languages** support karta hai:
- Hindi (hi)
- Bengali (bn)
- Gujarati (gu)
- Kannada (kn)
- Marathi (mr)
- Tamil (ta)
- Telugu (te)
- English, Spanish, French, German, Chinese, Japanese, Arabic, etc.

---

## 🐛 Known Issues & Fixes (from Changelog)

### Recent Fixes (v1.18.2):
- Multicast network compatibility restored
- Proxy detection (TLS info not found fix)
- HTTP/Multicast server auto-restart
- Drag-and-drop mixed files/folders fix
- Android file modification time handling

### Security Fixes:
- Path traversal vulnerability (v1.17.0)
- No HTTP redirects from peers (v1.18.2)

---

## 🔬 Reverse Engineering Challenges

1. **Flutter Code**: Dart code compiled to snapshot format (difficult to decompile)
2. **Rust Native Code**: Stripped binary (no debug symbols)
3. **Obfuscation**: Some level of code obfuscation present
4. **Native Bindings**: Complex JNI/FFI bridges

**Solution Approach**:
- Analyzed manifest, resources, aur assets
- Changelog se features aur implementation details nikale
- Network traffic analysis se protocol samjha
- Similar open-source projects se comparison kiya

---

## 📝 Key Takeaways for Clone Development

### Must-Have Features:
1. ✅ Local network device discovery (mDNS)
2. ✅ HTTP-based file transfer with chunking
3. ✅ Device aliasing aur favorites
4. ✅ Cross-platform support (Flutter)
5. ✅ Material Design UI
6. ✅ Transfer history
7. ✅ Multiple file types support
8. ✅ Background transfer (Android)
9. ✅ Checksum verification
10. ✅ PIN protection option

### Performance Considerations:
- Rust/native code for performance-critical operations
- Multithreading for parallel transfers
- Efficient memory management for large files
- Background services for uninterrupted transfers

### Security Considerations:
- Optional encryption (HTTPS)
- Checksum verification
- PIN protection
- Path traversal protection
- No external network communication

---

## 🎯 Clone Implementation Strategy

### Phase 1: Core Foundation
- Flutter project setup
- Basic UI framework
- State management (Provider/Riverpod)

### Phase 2: Networking
- mDNS device discovery
- HTTP server implementation
- Device announcement protocol

### Phase 3: File Transfer
- File picker integration
- HTTP upload/download
- Progress tracking
- Chunked transfer

### Phase 4: Advanced Features
- Favorites system
- History management
- PIN protection
- Checksum verification

### Phase 5: Platform Integration
- Android background service
- Share target integration
- Native platform features

### Phase 6: Polish & Optimization
- Performance optimization
- UI/UX refinements
- Testing & bug fixes
- Multi-language support

---

## 📚 Technical Specifications Summary

| Component | Technology | Details |
|-----------|-----------|---------|
| **Framework** | Flutter 3.x | Dart SDK |
| **UI Design** | Material Design 3 | Yaru theme |
| **Networking** | Rust + Dart | HTTP/HTTPS server |
| **Discovery** | mDNS/Multicast | Local network only |
| **File Transfer** | HTTP Chunked | Multithreaded |
| **Encryption** | TLS/SSL | Self-signed certs |
| **Checksum** | MD5/SHA256 | Integrity verification |
| **Storage** | Shared Preferences | Local database |
| **Minimum Android** | API 24 (Android 7.0) | NDK r28c |

---

## 🔍 Source Code Insights (Inferred)

```dart
// Likely project structure
lib/
├── main.dart                  // Entry point
├── models/
│   ├── device.dart           // Device model
│   ├── file_info.dart        // File metadata
│   └── transfer_state.dart   // Transfer status
├── providers/
│   ├── discovery_provider.dart
│   ├── transfer_provider.dart
│   └── settings_provider.dart
├── services/
│   ├── discovery_service.dart     // mDNS
│   ├── http_server_service.dart   // HTTP server
│   ├── transfer_service.dart      // File transfer
│   └── native_bridge.dart         // Rust FFI
├── screens/
│   ├── home_screen.dart
│   ├── send_screen.dart
│   ├── receive_screen.dart
│   ├── settings_screen.dart
│   └── history_screen.dart
└── widgets/
    ├── device_list_tile.dart
    ├── transfer_progress.dart
    └── file_picker_widget.dart
```

---

## 🎓 Conclusion

LocalSend ek excellently engineered app hai jo **Flutter** ki cross-platform capabilities aur **Rust** ki performance ko combine karta hai. Iska architecture modular aur scalable hai, making it a perfect candidate for cloning aur learning.

**Key Success Factors**:
1. Simple aur intuitive UI/UX
2. Fast aur reliable file transfers
3. No internet dependency
4. Cross-platform compatibility
5. Active development aur community support
6. Open-source nature (GitHub available)

**Note**: Original LocalSend open-source hai (MIT License), GitHub par available hai: `https://github.com/localsend/localsend`

---

*Report Generated: November 5, 2026*
*Analyzed Version: LocalSend v1.18.2*
*Analysis Method: APK Reverse Engineering + Documentation Study*
