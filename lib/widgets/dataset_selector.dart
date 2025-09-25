import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/position_loader.dart';

class DatasetSelector extends StatefulWidget {
  final VoidCallback? onDatasetChanged;

  const DatasetSelector({super.key, this.onDatasetChanged});

  @override
  State<DatasetSelector> createState() => _DatasetSelectorState();
}

class _DatasetSelectorState extends State<DatasetSelector> {
  String _currentDataset = 'Default';
  bool _loading = false;

  final List<String> _presetDatasets = [
    '19x19_midgame_positions.json',
    '19x19_final_positions.json',
    '9x9_final_positions.json',
    '9x9_sequences.json',
    'complete_dataset2.json',
  ];

  @override
  void initState() {
    super.initState();
    _updateCurrentDataset();
  }

  void _updateCurrentDataset() {
    final currentFile = PositionLoader.datasetFile;
    if (currentFile.startsWith('assets/')) {
      final filename = currentFile.substring(7);
      if (_presetDatasets.contains(filename)) {
        setState(() {
          _currentDataset = filename;
        });
        return;
      }
    }
    setState(() {
      _currentDataset = currentFile.contains('/')
          ? currentFile.split('/').last
          : currentFile;
    });
  }

  Future<void> _selectPresetDataset(String filename) async {
    setState(() {
      _loading = true;
    });

    try {
      PositionLoader.setDatasetFile(filename);
      await PositionLoader.preloadDataset();
      setState(() {
        _currentDataset = filename;
        _loading = false;
      });
      widget.onDatasetChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to $filename'),
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
          if (kIsWeb) {
            // Web: Load from bytes
            if (file.bytes != null) {
              await PositionLoader.loadFromBytes(file.bytes!, file.name);
            } else {
              throw Exception('Failed to read file data');
            }
          } else {
            // Mobile/Desktop: Load from path
            if (file.path != null) {
              await PositionLoader.loadFromFile(file.path!);
            } else {
              throw Exception('Failed to get file path');
            }
          }

          setState(() {
            _currentDataset = file.name;
            _loading = false;
          });
          widget.onDatasetChanged?.call();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Loaded custom dataset: ${file.name}'),
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
            const Text('Preset Datasets:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _presetDatasets.map((dataset) {
                final isSelected = _currentDataset == dataset;
                return ChoiceChip(
                  label: Text(
                    dataset.replaceAll('_', ' ').replaceAll('.json', ''),
                    style: TextStyle(fontSize: 11),
                  ),
                  selected: isSelected,
                  onSelected: _loading ? null : (selected) {
                    if (selected && !isSelected) {
                      _selectPresetDataset(dataset);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _pickCustomFile,
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Load Custom JSON File'),
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