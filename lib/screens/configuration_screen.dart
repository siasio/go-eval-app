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

    // Add listeners for auto-saving
    _thresholdGoodController.addListener(_onConfigurationChanged);
    _thresholdCloseController.addListener(_onConfigurationChanged);
    _timeProblemController.addListener(_onConfigurationChanged);
  }

  void _onConfigurationChanged() {
    if (_currentConfiguration == null) return;

    final thresholdGood = double.tryParse(_thresholdGoodController.text);
    final thresholdClose = double.tryParse(_thresholdCloseController.text);
    final timeProblem = int.tryParse(_timeProblemController.text);

    if (thresholdGood != null &&
        thresholdClose != null &&
        timeProblem != null &&
        thresholdClose >= thresholdGood &&
        timeProblem > 0) {

      final newConfig = _currentConfiguration!.copyWith(
        thresholdGood: thresholdGood,
        thresholdClose: thresholdClose,
        timePerProblemSeconds: timeProblem,
      );

      _autoSaveConfiguration(newConfig);
    }
  }

  Future<void> _autoSaveConfiguration(DatasetConfiguration config) async {
    if (_configManager == null) return;

    try {
      await _configManager!.setConfiguration(_selectedDatasetType, config);
      setState(() {
        _currentConfiguration = config;
      });
    } catch (e) {
      // Silently handle validation errors during typing
    }
  }

  @override
  void dispose() {
    _thresholdGoodController.dispose();
    _thresholdCloseController.dispose();
    _timeProblemController.dispose();
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
    });
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

                      // Hide Game Info Bar
                      CheckboxListTile(
                        title: const Text('Hide Game Info Bar'),
                        subtitle: const Text(
                          'Hide the bar showing captured stones and komi',
                        ),
                        value: _currentConfiguration!.hideGameInfoBar,
                        onChanged: (bool? value) {
                          if (value != null && _currentConfiguration != null) {
                            final newConfig = _currentConfiguration!.copyWith(
                              hideGameInfoBar: value,
                            );
                            _autoSaveConfiguration(newConfig);
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),

                      // Reset Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _resetConfiguration,
                          child: const Text('Reset to Defaults'),
                        ),
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
                    const Text('• Hide Game Info Bar: Remove captured stones and komi display'),
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