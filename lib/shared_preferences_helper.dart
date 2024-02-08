import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  static String encodeMap(Map<DateTime, List<dynamic>> map) {
    // Convert DateTime keys to ISO8601 string format and encode the map
    Map<String, dynamic> serialized = {};
    map.forEach((key, value) {
      serialized[key.toIso8601String()] = value;
    });
    return jsonEncode(serialized);
  }

  static Map<DateTime, List<dynamic>> decodeMap(String mapString) {
    // Decode the map string and convert string keys back to DateTime objects
    Map<String, dynamic> decoded = jsonDecode(mapString);
    Map<DateTime, List<dynamic>> deserialized = {};
    decoded.forEach((key, value) {
      deserialized[DateTime.parse(key)] = List<dynamic>.from(value);
    });
    return deserialized;
  }


  static Future<void> saveMarkedDaysToPrefs(String key, Map<DateTime, List<dynamic>> markedDays) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encoded = encodeMap(markedDays);
    prefs.setString(key, encoded);
  }

  static Future<Map<DateTime, List<dynamic>>?> getMarkedDaysFromPrefs(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encoded = prefs.getString(key);
    if (encoded != null) {
      return decodeMap(encoded);
    }
    return null;
  }
}
