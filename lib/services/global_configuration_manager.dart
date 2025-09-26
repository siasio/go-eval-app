import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/global_configuration.dart';

class GlobalConfigurationManager {
  static const String _globalConfigKey = 'global_configuration';
  static GlobalConfigurationManager? _instance;
  static SharedPreferences? _prefs;

  GlobalConfiguration _configuration = GlobalConfiguration.defaultConfig;

  GlobalConfigurationManager._();

  static Future<GlobalConfigurationManager> getInstance() async {
    _instance ??= GlobalConfigurationManager._();
    _prefs ??= await SharedPreferences.getInstance();
    await _instance!._loadConfiguration();
    return _instance!;
  }

  Future<void> _loadConfiguration() async {
    final configString = _prefs?.getString(_globalConfigKey);

    if (configString != null) {
      try {
        final configMap = jsonDecode(configString) as Map<String, dynamic>;
        _configuration = GlobalConfiguration.fromJson(configMap);
      } catch (e) {
        print('Error loading global configuration: $e');
        _configuration = GlobalConfiguration.defaultConfig;
      }
    } else {
      _configuration = GlobalConfiguration.defaultConfig;
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      await _prefs?.setString(_globalConfigKey, jsonEncode(_configuration.toJson()));
    } catch (e) {
      print('Error saving global configuration: $e');
    }
  }

  GlobalConfiguration getConfiguration() {
    return _configuration;
  }

  Future<void> setConfiguration(GlobalConfiguration configuration) async {
    if (configuration.isValidConfiguration()) {
      _configuration = configuration;
      await _saveConfiguration();
    } else {
      throw ArgumentError('Invalid global configuration');
    }
  }

  Future<void> resetConfiguration() async {
    _configuration = GlobalConfiguration.defaultConfig;
    await _saveConfiguration();
  }
}