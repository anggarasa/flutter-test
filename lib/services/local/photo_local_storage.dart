import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/history/domain/photo_location.dart';

class PhotoLocalStorage {
  static const String _keyPhotoLocations = 'photo_locations';

  static Future<void> savePhotoLocation(PhotoLocation photoLocation) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAllPhotoLocations();
    existing.add(photoLocation);
    final jsonList = existing.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList(_keyPhotoLocations, jsonList);
  }

  static Future<List<PhotoLocation>> getAllPhotoLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyPhotoLocations);
    if (jsonList == null) return [];
    return jsonList.map((e) => PhotoLocation.fromMap(json.decode(e))).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> deletePhotoLocation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAllPhotoLocations();
    existing.removeWhere((e) => e.id == id);
    final jsonList = existing.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList(_keyPhotoLocations, jsonList);
  }
}
