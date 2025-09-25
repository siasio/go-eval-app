import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dataset_type.dart';

class DatasetInfo {
  final String name;
  final String path;
  final DatasetType? datasetType;
  final bool isPreset;
  final String displayName;

  const DatasetInfo({
    required this.name,
    required this.path,
    required this.datasetType,
    required this.isPreset,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'datasetType': datasetType?.value,
      'isPreset': isPreset,
      'displayName': displayName,
    };
  }

  static DatasetInfo fromJson(Map<String, dynamic> json) {
    return DatasetInfo(
      name: json['name'] as String,
      path: json['path'] as String,
      datasetType: DatasetType.fromString(json['datasetType'] as String?),
      isPreset: json['isPreset'] as bool,
      displayName: json['displayName'] as String,
    );
  }
}

class DatasetPreferenceManager {
  static const String _userDatasetsKey = 'user_datasets';
  static const String _selectedDatasetKey = 'selected_dataset';
  static const String _lastSessionDatasetKey = 'last_session_dataset';

  static DatasetPreferenceManager? _instance;
  static SharedPreferences? _prefs;

  final List<DatasetInfo> _userDatasets = [];
  String? _selectedDataset;

  DatasetPreferenceManager._();

  static Future<DatasetPreferenceManager> getInstance() async {
    _instance ??= DatasetPreferenceManager._();
    _prefs ??= await SharedPreferences.getInstance();
    await _instance!._loadUserDatasets();
    await _instance!._loadSelectedDataset();
    return _instance!;
  }

  /// Load user-added datasets from persistent storage
  Future<void> _loadUserDatasets() async {
    final datasetsJson = _prefs?.getString(_userDatasetsKey);
    if (datasetsJson != null) {
      try {
        final List<dynamic> datasetsList = jsonDecode(datasetsJson);
        _userDatasets.clear();
        for (final datasetData in datasetsList) {
          if (datasetData is Map<String, dynamic>) {
            // Validate that the dataset file still exists (for non-web platforms)
            final datasetInfo = DatasetInfo.fromJson(datasetData);
            if (kIsWeb || datasetInfo.isPreset || _fileExists(datasetInfo.path)) {
              _userDatasets.add(datasetInfo);
            }
          }
        }
      } catch (e) {
        print('Error loading user datasets: $e');
        _userDatasets.clear();
      }
    }
  }

  /// Load the last selected dataset
  Future<void> _loadSelectedDataset() async {
    _selectedDataset = _prefs?.getString(_selectedDatasetKey);
  }

  /// Save user datasets to persistent storage
  Future<void> _saveUserDatasets() async {
    try {
      final datasetsJson = jsonEncode(_userDatasets.map((d) => d.toJson()).toList());
      await _prefs?.setString(_userDatasetsKey, datasetsJson);
    } catch (e) {
      print('Error saving user datasets: $e');
    }
  }

  /// Save the selected dataset
  Future<void> _saveSelectedDataset() async {
    if (_selectedDataset != null) {
      await _prefs?.setString(_selectedDatasetKey, _selectedDataset!);
      await _prefs?.setString(_lastSessionDatasetKey, _selectedDataset!);
    }
  }

  /// Check if a file exists (non-web platforms only)
  bool _fileExists(String path) {
    if (kIsWeb) return true; // Can't check on web
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Add a new user dataset
  Future<bool> addUserDataset({
    required String name,
    required String path,
    required DatasetType? datasetType,
    required String displayName,
  }) async {
    // Check if dataset already exists
    final existingIndex = _userDatasets.indexWhere((d) => d.path == path);

    final datasetInfo = DatasetInfo(
      name: name,
      path: path,
      datasetType: datasetType,
      isPreset: false,
      displayName: displayName,
    );

    if (existingIndex >= 0) {
      // Update existing dataset
      _userDatasets[existingIndex] = datasetInfo;
    } else {
      // Add new dataset
      _userDatasets.add(datasetInfo);
    }

    await _saveUserDatasets();
    return true;
  }

  /// Remove a user dataset
  Future<bool> removeUserDataset(String path) async {
    final initialLength = _userDatasets.length;
    _userDatasets.removeWhere((d) => d.path == path && !d.isPreset);
    final removed = initialLength - _userDatasets.length;
    if (removed > 0) {
      await _saveUserDatasets();
      return true;
    }
    return false;
  }

  /// Get all user-added datasets
  List<DatasetInfo> getUserDatasets() {
    return List.unmodifiable(_userDatasets);
  }

  /// Get datasets grouped by type
  Map<DatasetType, List<DatasetInfo>> getDatasetsByType(List<DatasetInfo> allDatasets) {
    final Map<DatasetType, List<DatasetInfo>> groupedDatasets = {};

    for (final dataset in allDatasets) {
      if (dataset.datasetType != null) {
        groupedDatasets.putIfAbsent(dataset.datasetType!, () => []).add(dataset);
      }
    }

    return groupedDatasets;
  }

  /// Set the currently selected dataset
  Future<void> setSelectedDataset(String datasetPath) async {
    _selectedDataset = datasetPath;
    await _saveSelectedDataset();
  }

  /// Get the currently selected dataset
  String? getSelectedDataset() {
    return _selectedDataset;
  }

  /// Get the last session's dataset for startup
  String? getLastSessionDataset() {
    return _prefs?.getString(_lastSessionDatasetKey);
  }

  /// Clear all user datasets (for testing/reset)
  Future<void> clearUserDatasets() async {
    _userDatasets.clear();
    await _prefs?.remove(_userDatasetsKey);
  }

  /// Get dataset type from dataset file by parsing metadata
  static Future<DatasetType?> getDatasetType(String path, {Uint8List? bytes}) async {
    try {
      String jsonString;

      if (bytes != null) {
        // Web: use provided bytes
        jsonString = String.fromCharCodes(bytes);
      } else if (path.startsWith('assets/')) {
        // Asset file - can't read here without Flutter context
        return null;
      } else {
        // File system
        if (kIsWeb) return null;
        final file = File(path);
        if (!file.existsSync()) return null;
        jsonString = await file.readAsString();
      }

      final jsonData = jsonDecode(jsonString);
      final metadata = jsonData['metadata'] as Map<String, dynamic>?;
      if (metadata != null) {
        final datasetTypeString = metadata['dataset_type'] as String?;
        return DatasetType.fromString(datasetTypeString);
      }
    } catch (e) {
      print('Error reading dataset type from $path: $e');
    }
    return null;
  }
}