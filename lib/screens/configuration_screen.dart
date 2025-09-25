import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dataset_type.dart';
import '../models/dataset_configuration.dart';
import '../services/configuration_manager.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  ConfigurationManager? _configManager;
  DatasetType _selectedDatasetType = DatasetType.final9x9Area;
  DatasetConfiguration? _currentConfiguration;
  bool _loading = true;

  late TextEditingController _thresholdGoodController;
  late TextEditingController _thresholdCloseController;
  late TextEditingController _timeProblemController;
  late TextEditingController _markDisplayController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadConfigurationManager();
  }

  void _initializeControllers() {
    _thresholdGoodController = TextEditingController();
    _thresholdCloseController = TextEditingController();
    _timeProblemController = TextEditingController();
    _markDisplayController = TextEditingController();
  }

  @override
  void dispose() {
    _thresholdGoodController.dispose();
    _thresholdCloseController.dispose();
    _timeProblemController.dispose();
    _markDisplayController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigurationManager() async {
    try {
      final manager = await ConfigurationManager.getInstance();
      setState(() {
        _configManager = manager;
        _loading = false;
      });
      _loadConfigurationForType(_selectedDatasetType);
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading configuration: $e')),
        );
      }
    }
  }

  void _loadConfigurationForType(DatasetType type) {
    if (_configManager == null) return;

    final config = _configManager!.getConfiguration(type);
    setState(() {
      _currentConfiguration = config;
      _thresholdGoodController.text = config.thresholdGood.toString();
      _thresholdCloseController.text = config.thresholdClose.toString();
      _timeProblemController.text = config.timePerProblemSeconds.toString();
      _markDisplayController.text = config.markDisplayTimeSeconds.toString();
    });
  }

  Future<void> _saveConfiguration() async {
    if (_configManager == null || _currentConfiguration == null) return;

    try {
      final thresholdGood = double.tryParse(_thresholdGoodController.text);
      final thresholdClose = double.tryParse(_thresholdCloseController.text);
      final timeProblem = int.tryParse(_timeProblemController.text);
      final markDisplay = double.tryParse(_markDisplayController.text);

      if (thresholdGood == null ||
          thresholdClose == null ||
          timeProblem == null ||
          markDisplay == null) {
        _showError('Please enter valid numeric values');
        return;
      }

      if (thresholdClose < thresholdGood) {
        _showError('Close threshold must be greater than or equal to good threshold');
        return;
      }

      if (timeProblem <= 0) {
        _showError('Time per problem must be greater than 0');
        return;
      }

      if (markDisplay < 0) {
        _showError('Mark display time must be non-negative');
        return;
      }

      final newConfiguration = DatasetConfiguration(
        thresholdGood: thresholdGood,
        thresholdClose: thresholdClose,
        timePerProblemSeconds: timeProblem,
        markDisplayTimeSeconds: markDisplay,
      );

      await _configManager!.setConfiguration(_selectedDatasetType, newConfiguration);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved successfully')),
        );
      }
    } catch (e) {
      _showError('Error saving configuration: $e');
    }
  }

  Future<void> _resetConfiguration() async {
    if (_configManager == null) return;

    try {
      await _configManager!.resetConfiguration(_selectedDatasetType);
      _loadConfigurationForType(_selectedDatasetType);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration reset to defaults')),
        );
      }
    } catch (e) {
      _showError('Error resetting configuration: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  String _getDatasetDisplayName(DatasetType type) {
    switch (type) {
      case DatasetType.final9x9Area:
        return 'Final 9x9 Area';
      case DatasetType.final19x19Area:
        return 'Final 19x19 Area';
      case DatasetType.midgame19x19Estimation:
        return 'Midgame 19x19 Estimation';
      case DatasetType.final9x9AreaVars:
        return 'Final 9x9 Area Variations';
      case DatasetType.partialArea:
        return 'Partial Area';
    }
  }

  String _getDatasetDescription(DatasetType type) {
    switch (type) {
      case DatasetType.final9x9Area:
        return 'Final positions on 9x9 boards evaluated using KataGo\'s ownership map';
      case DatasetType.final19x19Area:
        return 'Final positions on 19x19 boards evaluated using KataGo\'s ownership map';
      case DatasetType.midgame19x19Estimation:
        return 'Midgame positions on 19x19 boards with territory estimation';
      case DatasetType.final9x9AreaVars:
        return 'Final positions on 9x9 boards with variations (not yet implemented)';
      case DatasetType.partialArea:
        return 'Partial area analysis (not yet implemented)';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dataset Configuration'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataset Configuration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetConfiguration,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dataset Type Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dataset Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DatasetType>(
                      value: _selectedDatasetType,
                      decoration: const InputDecoration(
                        labelText: 'Select Dataset Type',
                        border: OutlineInputBorder(),
                      ),
                      items: DatasetType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getDatasetDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (DatasetType? newType) {
                        if (newType != null) {
                          setState(() {
                            _selectedDatasetType = newType;
                          });
                          _loadConfigurationForType(newType);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getDatasetDescription(_selectedDatasetType),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Configuration Form
            if (_currentConfiguration != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuration Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Threshold Good
                      TextFormField(
                        controller: _thresholdGoodController,
                        decoration: const InputDecoration(
                          labelText: 'Threshold for Good Position',
                          helperText: 'Score difference to consider position as good for one color',
                          border: OutlineInputBorder(),
                          suffix: Text('points'),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Threshold Close
                      TextFormField(
                        controller: _thresholdCloseController,
                        decoration: const InputDecoration(
                          labelText: 'Threshold for Close Position',
                          helperText: 'Score difference to consider position as close (must be ≥ good threshold)',
                          border: OutlineInputBorder(),
                          suffix: Text('points'),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Time per Problem
                      TextFormField(
                        controller: _timeProblemController,
                        decoration: const InputDecoration(
                          labelText: 'Time per Problem',
                          helperText: 'Time allowed to solve one problem',
                          border: OutlineInputBorder(),
                          suffix: Text('seconds'),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mark Display Time
                      TextFormField(
                        controller: _markDisplayController,
                        decoration: const InputDecoration(
                          labelText: 'Mark Display Time',
                          helperText: 'Time to show result before next problem',
                          border: OutlineInputBorder(),
                          suffix: Text('seconds'),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveConfiguration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Configuration'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetConfiguration,
                              child: const Text('Reset to Defaults'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Help Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Configuration Help',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Good Threshold: Score difference needed for position to favor one color'),
                    const Text('• Close Threshold: Score difference for position to be considered close'),
                    const Text('• Time per Problem: How long you have to make your guess'),
                    const Text('• Mark Display Time: How long result is shown before next position'),
                    const SizedBox(height: 12),
                    Text(
                      'Note: Close threshold must be greater than or equal to good threshold.',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}