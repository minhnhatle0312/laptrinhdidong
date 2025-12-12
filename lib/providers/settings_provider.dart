import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kBaseUrl = 'api_base_url';
  final ApiService api;
  String baseUrl = '';

  SettingsProvider(this.api);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_kBaseUrl) ?? '';
    api.baseUrl = baseUrl;
    notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    baseUrl = url;
    api.baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, url);
    notifyListeners();
  }
}
