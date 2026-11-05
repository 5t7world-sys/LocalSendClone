import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'services/discovery_service.dart';
import 'services/http_server_service.dart';
import 'utils/app_theme.dart';
import 'providers/settings_provider.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: LocalSendApp(),
    ),
  );
}

class LocalSendApp extends ConsumerStatefulWidget {
  const LocalSendApp({super.key});

  @override
  ConsumerState<LocalSendApp> createState() => _LocalSendAppState();
}

class _LocalSendAppState extends ConsumerState<LocalSendApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize HTTP server
    final httpService = HttpServerService();
    await httpService.start();
    
    // Initialize device discovery
    final discoveryService = DiscoveryService();
    await discoveryService.startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider).themeMode;
    final customColor = ref.watch(settingsProvider).customColor;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(customColor),
      darkTheme: AppTheme.darkTheme(customColor),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
