import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dataset_type.dart';
import '../models/dataset_configuration.dart';

class ConfigurationManager {
  static const String _configurationKey = 'dataset_configurations';
  static ConfigurationManager? _instance;
  static SharedPreferences? _prefs;

  final Map<DatasetType, DatasetConfiguration> _configurations = {};

  ConfigurationManager._();

  static Future<ConfigurationManager> getInstance() async {
    _instance ??= ConfigurationManager._();
    _prefs ??= await SharedPreferences.getInstance();
    await _instance!._loadConfigurations();
    return _instance!;
  }

  Future<void> _loadConfigurations() async {
    final configString = _prefs?.getString(_configurationKey);

    if (configString != null) {
      try {
        final configMap = jsonDecode(configString) as Map<String, dynamic>;
        for (final type in DatasetType.values) {
          final typeConfig = configMap[type.value];
          if (typeConfig != null) {
            _configurations[type] = DatasetConfiguration.fromJson(
              typeConfig as Map<String, dynamic>
            );
          } else {
            _configurations[type] = DatasetConfiguration.getDefaultFor(type);
          }
        }
      } catch (e) {
        print('Error loading configurations: $e');
        _initializeDefaults();
      }
    } else {
      _initializeDefaults();
    }
  }

  void _initializeDefaults() {
    for (final type in DatasetType.values) {
      _configurations[type] = DatasetConfiguration.getDefaultFor(type);
    }
  }

  Future<void> _saveConfigurations() async {
    final configMap = <String, dynamic>{};
    for (final entry in _configurations.entries) {
      configMap[entry.key.value] = entry.value.toJson();
    }

    try {
      await _prefs?.setString(_configurationKey, jsonEncode(configMap));
    } catch (e) {
      print('Error saving configurations: $e');
    }
  }

  DatasetConfiguration getConfiguration(DatasetType datasetType) {
    return _configurations[datasetType] ??
           DatasetConfiguration.getDefaultFor(datasetType);
  }

  Future<void> setConfiguration(
    DatasetType datasetType,
    DatasetConfiguration configuration
  ) async {
    if (configuration.isValidConfiguration()) {
      _configurations[datasetType] = configuration;
      await _saveConfigurations();
    } else {
      throw ArgumentError('Invalid configuration: thresholdClose must be >= thresholdGood');
    }
  }

  Future<void> resetConfiguration(DatasetType datasetType) async {
    _configurations[datasetType] = DatasetConfiguration.getDefaultFor(datasetType);
    await _saveConfigurations();
  }

  Future<void> resetAllConfigurations() async {
    _initializeDefaults();
    await _saveConfigurations();
  }

  Map<DatasetType, DatasetConfiguration> getAllConfigurations() {
    return Map.unmodifiable(_configurations);
  }
}