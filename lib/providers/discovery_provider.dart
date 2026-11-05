import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../services/discovery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Discovery provider for managing device discovery
final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  final service = DiscoveryService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for discovered devices
final devicesStreamProvider = StreamProvider<List<Device>>((ref) {
  final service = ref.watch(discoveryServiceProvider);
  return service.devicesStream;
});

/// Favorites provider
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites') ?? [];
      state = favorites.toSet();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> addFavorite(String fingerprint) async {
    state = {...state, fingerprint};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', state.toList());
  }

  Future<void> removeFavorite(String fingerprint) async {
    state = {...state}..remove(fingerprint);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', state.toList());
  }

  bool isFavorite(String fingerprint) {
    return state.contains(fingerprint);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});
