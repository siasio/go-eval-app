import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/position_loader.dart';
import '../services/dataset_preference_manager.dart';
import '../models/dataset_type.dart';
import '../models/app_skin.dart';
import '../core/dataset_parser.dart' as parser;
import 'dart:convert';
import 'package:flutter/services.dart';

class DatasetSelector extends StatefulWidget {
  final VoidCallback? onDatasetChanged;
  final AppSkin appSkin;

  const DatasetSelector({
    super.key,
    this.onDatasetChanged,
    this.appSkin = AppSkin.classic,
  });

  @override
  State<DatasetSelector> createState() => _DatasetSelectorState();
}

class _DatasetSelectorState extends State<DatasetSelector> {
  String _currentDataset = 'Default';
  bool _loading = false;
  DatasetPreferenceManager? _preferenceManager;
  Map<DatasetType, List<DatasetInfo>> _groupedDatasets = {};
  List<DatasetInfo> _validPresetDatasets = [];
  List<DatasetInfo> _userDatasets = [];

  // Preset datasets with their expected types
  final List<Map<String, dynamic>> _presetDatasetConfigs = [
    // {
    //   'filename': 'dataset1_9x9_final.json',
    //   'displayName': '9x9 Final Positions',
    //   'expectedType': DatasetType.final9x9Area,
    // },
    // {
    //   'filename': 'dataset3_19x19_final.json',
    //   'displayName': '19x19 Final Positions',
    //   'expectedType': DatasetType.final19x19Area,
    // },
    {
      'filename': 'fox_mid150_19x19.json',
      'displayName': 'Fox Positions (move 150)',
      'expectedType': DatasetType.midgame19x19Estimation,
    },
    {
      'filename': 'final_9x9_katago.json',
      'displayName': '9x9 Final Positions',
      'expectedType': DatasetType.final9x9Area,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeDatasets();
  }

  Future<void> _initializeDatasets() async {
    _preferenceManager = await DatasetPreferenceManager.getInstance();
    await _loadAndValidateDatasets();
    await _loadLastSessionDataset();
    _updateCurrentDataset();
  }

  Future<void> _loadAndValidateDatasets() async {
    final List<DatasetInfo> allValidDatasets = [];

    // Load and validate preset datasets
    for (final config in _presetDatasetConfigs) {
      final filename = config['filename'] as String;
      final displayName = config['displayName'] as String;
      final expectedType = config['expectedType'] as DatasetType?;

      try {
        // Try to get the actual dataset type by parsing
        DatasetType? actualType = expectedType;
        if (actualType == null) {
          actualType = await _getDatasetTypeFromAsset('assets/$filename');
        }

        if (actualType != null) {
          final datasetInfo = DatasetInfo(
            name: filename,
            path: 'assets/$filename',
            datasetType: actualType,
            isPreset: true,
            displayName: displayName,
          );
          allValidDatasets.add(datasetInfo);
          _validPresetDatasets.add(datasetInfo);
        }
      } catch (e) {
        print('Preset dataset $filename is invalid: $e');
      }
    }

    // Load user datasets
    _userDatasets = _preferenceManager?.getUserDatasets() ?? [];
    allValidDatasets.addAll(_userDatasets);

    // Group datasets by type
    _groupedDatasets = _preferenceManager?.getDatasetsByType(allValidDatasets) ?? {};

    if (mounted) {
      setState(() {});
    }
  }

  Future<DatasetType?> _getDatasetTypeFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(jsonString);

      // Validate dataset structure first
      final validationErrors = parser.DatasetParser.validateDataset(jsonData);
      if (validationErrors.isNotEmpty) {
        return null; // Invalid dataset
      }

      final metadata = jsonData['metadata'] as Map<String, dynamic>?;
      if (metadata != null) {
        final datasetTypeString = metadata['dataset_type'] as String?;
        return DatasetType.fromString(datasetTypeString);
      }
    } catch (e) {
      print('Error parsing asset $assetPath: $e');
    }
    return null;
  }

  Future<void> _loadLastSessionDataset() async {
    final lastDataset = _preferenceManager?.getLastSessionDataset();
    if (lastDataset != null) {
      // Validate that the last dataset is still available
      final allDatasets = [..._validPresetDatasets, ..._userDatasets];
      final datasetExists = allDatasets.any((d) => d.path == lastDataset);
      if (datasetExists) {
        try {
          if (lastDataset.startsWith('assets/')) {
            PositionLoader.setDatasetFile(lastDataset.substring(7));
          } else {
            await PositionLoader.loadFromFile(lastDataset);
          }
          await _preferenceManager?.setSelectedDataset(lastDataset);
        } catch (e) {
          print('Failed to load last session dataset: $e');
        }
      }
    }
  }

  void _updateCurrentDataset() {
    final currentFile = PositionLoader.datasetFile;
    final allDatasets = [..._validPresetDatasets, ..._userDatasets];
    final currentDatasetInfo = allDatasets.firstWhere(
      (d) => d.path == currentFile || d.path == 'assets/$currentFile',
      orElse: () => DatasetInfo(
        name: currentFile.contains('/') ? currentFile.split('/').last : currentFile,
        path: currentFile,
        datasetType: null,
        isPreset: false,
        displayName: currentFile.contains('/') ? currentFile.split('/').last : currentFile,
      ),
    );

    setState(() {
      _currentDataset = currentDatasetInfo.displayName;
    });
  }

  Future<void> _selectDataset(DatasetInfo datasetInfo) async {
    setState(() {
      _loading = true;
    });

    try {
      if (datasetInfo.path.startsWith('assets/')) {
        PositionLoader.setDatasetFile(datasetInfo.path.substring(7));
      } else {
        await PositionLoader.loadFromFile(datasetInfo.path);
      }
      await PositionLoader.preloadDataset();
      await _preferenceManager?.setSelectedDataset(datasetInfo.path);

      setState(() {
        _currentDataset = datasetInfo.displayName;
        _loading = false;
      });
      widget.onDatasetChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${datasetInfo.displayName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dataset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickCustomFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result != null) {
        setState(() {
          _loading = true;
        });

        PlatformFile file = result.files.first;

        try {
          DatasetType? datasetType;

          // First, try to determine dataset type and validate
          if (kIsWeb) {
            // Web: Load from bytes
            if (file.bytes != null) {
              datasetType = await _validateAndGetDatasetType(file.bytes!, file.name);
              if (datasetType == null) {
                throw Exception('Invalid dataset: missing or invalid dataset_type');
              }
              await PositionLoader.loadFromBytes(file.bytes!, file.name);
            } else {
              throw Exception('Failed to read file data');
            }
          } else {
            // Mobile/Desktop: Load from path
            if (file.path != null) {
              datasetType = await DatasetPreferenceManager.getDatasetType(file.path!);
              if (datasetType == null) {
                throw Exception('Invalid dataset: missing or invalid dataset_type');
              }
              await PositionLoader.loadFromFile(file.path!);
            } else {
              throw Exception('Failed to get file path');
            }
          }

          // Add to user datasets
          await _preferenceManager?.addUserDataset(
            name: file.name,
            path: kIsWeb ? file.name : file.path!,
            datasetType: datasetType,
            displayName: file.name.replaceAll('.json', '').replaceAll('_', ' '),
          );

          // Reload datasets to include the new one
          await _loadAndValidateDatasets();
          await _preferenceManager?.setSelectedDataset(kIsWeb ? file.name : file.path!);

          setState(() {
            _currentDataset = file.name.replaceAll('.json', '').replaceAll('_', ' ');
            _loading = false;
          });
          widget.onDatasetChanged?.call();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added dataset: ${file.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          setState(() {
            _loading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading file: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<DatasetType?> _validateAndGetDatasetType(Uint8List bytes, String filename) async {
    try {
      final jsonString = String.fromCharCodes(bytes);
      final jsonData = jsonDecode(jsonString);

      // Validate dataset structure first
      final validationErrors = parser.DatasetParser.validateDataset(jsonData);
      if (validationErrors.isNotEmpty) {
        return null;
      }

      final metadata = jsonData['metadata'] as Map<String, dynamic>?;
      if (metadata != null) {
        final datasetTypeString = metadata['dataset_type'] as String?;
        return DatasetType.fromString(datasetTypeString);
      }
    } catch (e) {
      print('Error validating dataset $filename: $e');
    }
    return null;
  }

  String _getDatasetTypeDisplayName(DatasetType type) {
    switch (type) {
      case DatasetType.final9x9Area:
        return '9x9 Final Positions';
      case DatasetType.final19x19Area:
        return '19x19 Final Positions';
      case DatasetType.midgame19x19Estimation:
        return '19x19 Midgame Estimation';
      case DatasetType.final9x9AreaVars:
        return '9x9 Final Variations';
      case DatasetType.partialArea:
        return 'Partial Area Analysis';
    }
  }

  Color _getDatasetTypeColor(DatasetType type) {
    if (widget.appSkin == AppSkin.eink) {
      // E-ink theme uses only black/white/grays
      switch (type) {
        case DatasetType.final9x9Area:
        case DatasetType.final9x9AreaVars:
          return Colors.black;
        case DatasetType.final19x19Area:
          return Colors.grey.shade700;
        case DatasetType.midgame19x19Estimation:
          return Colors.grey.shade500;
        case DatasetType.partialArea:
          return Colors.grey.shade300;
      }
    }

    // Other themes use original colors
    switch (type) {
      case DatasetType.final9x9Area:
      case DatasetType.final9x9AreaVars:
        return Colors.green;
      case DatasetType.final19x19Area:
        return Colors.blue;
      case DatasetType.midgame19x19Estimation:
        return Colors.orange;
      case DatasetType.partialArea:
        return Colors.purple;
    }
  }

  Widget _buildDatasetGroup(DatasetType type, List<DatasetInfo> datasets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getDatasetTypeColor(type),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getDatasetTypeDisplayName(type),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: datasets.map((dataset) {
            final isSelected = _currentDataset == dataset.displayName;
            return ChoiceChip(
              label: Text(
                dataset.displayName,
                style: const TextStyle(fontSize: 11),
              ),
              selected: isSelected,
              selectedColor: widget.appSkin == AppSkin.eink
                  ? Colors.grey.shade200
                  : _getDatasetTypeColor(type).withOpacity(0.3),
              onSelected: _loading ? null : (selected) {
                if (selected && !isSelected) {
                  _selectDataset(dataset);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Dataset Selection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current: $_currentDataset',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            if (_groupedDatasets.isNotEmpty) ...
              _groupedDatasets.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildDatasetGroup(entry.key, entry.value),
                );
              }).toList()
            else
              const Text(
                'No valid datasets found',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _pickCustomFile,
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Add Custom JSON Dataset'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}