import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for saving / loading star counts.
class StorageService {
  static const String _prefix = 'pz_stars_';
  static const String _profileNameKey = 'pz_profile_name';
  static SharedPreferences? _prefs;

  /// Call once at app start to warm up the singleton.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await initProfile();
  }

  static Future<void> initProfile() async {
    final prefs = await _get();
    if (!prefs.containsKey(_profileNameKey)) {
      final rng = Random();
      final name = 'Puzzler#${rng.nextInt(9000) + 1000}';
      await prefs.setString(_profileNameKey, name);
    }
  }

  static Future<String> getUserName() async {
    final prefs = await _get();
    return prefs.getString(_profileNameKey) ?? 'Guest';
  }

  static Future<int> getTotalStars() async {
    final allStars = await getAllStars();
    return allStars.values.fold<int>(0, (sum, stars) => sum + stars);
  }

  static Future<SharedPreferences> _get() async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Persist [stars] for [levelKey], keeping the highest value seen so far.
  static Future<void> saveStars(String levelKey, int stars) async {
    final prefs = await _get();
    final existing = prefs.getInt('$_prefix$levelKey') ?? 0;
    if (stars > existing) {
      await prefs.setInt('$_prefix$levelKey', stars);
    }
  }

  /// Returns the best star count for [levelKey] (0 if never played).
  static Future<int> getStars(String levelKey) async {
    final prefs = await _get();
    return prefs.getInt('$_prefix$levelKey') ?? 0;
  }

  /// Returns a map of all saved levelKey → stars.
  static Future<Map<String, int>> getAllStars() async {
    final prefs = await _get();
    final result = <String, int>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_prefix)) {
        result[key.substring(_prefix.length)] = prefs.getInt(key) ?? 0;
      }
    }
    return result;
  }

  /// Wipe every saved star (used by a "reset all" option in settings).
  static Future<void> clearAll() async {
    final prefs = await _get();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
