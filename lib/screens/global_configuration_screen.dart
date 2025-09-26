import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/global_configuration.dart';
import '../models/timer_type.dart';
import '../models/layout_type.dart';
import '../models/app_skin.dart';
import '../services/global_configuration_manager.dart';

class GlobalConfigurationScreen extends StatefulWidget {
  const GlobalConfigurationScreen({super.key});

  @override
  State<GlobalConfigurationScreen> createState() => _GlobalConfigurationScreenState();
}

class _GlobalConfigurationScreenState extends State<GlobalConfigurationScreen> {
  GlobalConfigurationManager? _configManager;
  GlobalConfiguration? _currentConfiguration;
  bool _loading = true;

  late TextEditingController _markDisplayController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadConfigurationManager();
  }

  void _initializeControllers() {
    _markDisplayController = TextEditingController();
    _markDisplayController.addListener(_onMarkDisplayTimeChanged);
  }

  void _onMarkDisplayTimeChanged() {
    if (_currentConfiguration == null) return;

    final value = double.tryParse(_markDisplayController.text);
    if (value != null && value >= 0) {
      final newConfig = _currentConfiguration!.copyWith(
        markDisplayTimeSeconds: value,
      );
      _autoSaveConfiguration(newConfig);
    }
  }

  @override
  void dispose() {
    _markDisplayController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigurationManager() async {
    try {
      final manager = await GlobalConfigurationManager.getInstance();
      setState(() {
        _configManager = manager;
        _currentConfiguration = manager.getConfiguration();
        _markDisplayController.text = _currentConfiguration!.markDisplayTimeSeconds.toString();
        _loading = false;
      });
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


  Future<void> _autoSaveConfiguration(GlobalConfiguration newConfig) async {
    if (_configManager == null) return;

    try {
      await _configManager!.setConfiguration(newConfig);
      setState(() {
        _currentConfiguration = newConfig;
      });
    } catch (e) {
      _showError('Error saving configuration: $e');
    }
  }

  Future<void> _resetConfiguration() async {
    if (_configManager == null) return;

    try {
      await _configManager!.resetConfiguration();
      final resetConfig = GlobalConfiguration.defaultConfig;
      setState(() {
        _currentConfiguration = resetConfig;
        _markDisplayController.text = resetConfig.markDisplayTimeSeconds.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Global configuration reset to defaults')),
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

  String _getTimerTypeDisplayName(TimerType type) {
    switch (type) {
      case TimerType.smooth:
        return 'Smooth Progress Bar';
      case TimerType.segmented:
        return 'Segmented Bar';
    }
  }

  String _getLayoutTypeDisplayName(LayoutType type) {
    switch (type) {
      case LayoutType.vertical:
        return 'Vertical Layout';
      case LayoutType.horizontal:
        return 'Horizontal Layout';
    }
  }

  String _getAppSkinDisplayName(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return 'Classic Wood';
      case AppSkin.modern:
        return 'Modern Dark';
      case AppSkin.ocean:
        return 'Ocean Blue';
      case AppSkin.eink:
        return 'E-ink Minimalist';
    }
  }

  String _getTimerTypeDescription(TimerType type) {
    switch (type) {
      case TimerType.smooth:
        return 'Traditional smooth progress bar that decreases continuously';
      case TimerType.segmented:
        return 'Segmented bar that removes one segment per second';
    }
  }

  String _getLayoutTypeDescription(LayoutType type) {
    switch (type) {
      case LayoutType.vertical:
        return 'Elements stacked vertically: menu - info - board - buttons';
      case LayoutType.horizontal:
        return 'Elements arranged horizontally: menu | info | board | buttons';
    }
  }

  String _getAppSkinDescription(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return 'Traditional brown wood theme with animations';
      case AppSkin.modern:
        return 'Dark theme with modern styling';
      case AppSkin.ocean:
        return 'Blue ocean-inspired theme';
      case AppSkin.eink:
        return 'Black and white theme optimized for e-ink displays (no animations)';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Global Settings'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Settings'),
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
            // Mark Display Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Result Display',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Timer Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timer Style',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TimerType>(
                      value: _currentConfiguration?.timerType,
                      decoration: const InputDecoration(
                        labelText: 'Timer Type',
                        border: OutlineInputBorder(),
                      ),
                      items: TimerType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTimerTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (TimerType? newType) {
                        if (newType != null && _currentConfiguration != null) {
                          final newConfig = _currentConfiguration!.copyWith(timerType: newType);
                          _autoSaveConfiguration(newConfig);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_currentConfiguration?.timerType != null)
                      Text(
                        _getTimerTypeDescription(_currentConfiguration!.timerType),
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

            // Layout Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Layout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LayoutType>(
                      value: _currentConfiguration?.layoutType,
                      decoration: const InputDecoration(
                        labelText: 'Layout Type',
                        border: OutlineInputBorder(),
                      ),
                      items: LayoutType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getLayoutTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (LayoutType? newType) {
                        if (newType != null && _currentConfiguration != null) {
                          final newConfig = _currentConfiguration!.copyWith(layoutType: newType);
                          _autoSaveConfiguration(newConfig);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_currentConfiguration?.layoutType != null)
                      Text(
                        _getLayoutTypeDescription(_currentConfiguration!.layoutType),
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

            // App Skin
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AppSkin>(
                      value: _currentConfiguration?.appSkin,
                      decoration: const InputDecoration(
                        labelText: 'App Skin',
                        border: OutlineInputBorder(),
                      ),
                      items: AppSkin.values.map((skin) {
                        return DropdownMenuItem(
                          value: skin,
                          child: Text(_getAppSkinDisplayName(skin)),
                        );
                      }).toList(),
                      onChanged: (AppSkin? newSkin) {
                        if (newSkin != null && _currentConfiguration != null) {
                          final newConfig = _currentConfiguration!.copyWith(appSkin: newSkin);
                          _autoSaveConfiguration(newConfig);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_currentConfiguration?.appSkin != null)
                      Text(
                        _getAppSkinDescription(_currentConfiguration!.appSkin),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
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
                          'Global Settings Help',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Mark Display Time: How long result is shown before next position'),
                    const Text('• Timer Type: Choose between smooth or segmented countdown'),
                    const Text('• Layout: Vertical stacks elements, horizontal arranges them side-by-side'),
                    const Text('• App Skin: Changes colors and styling - E-ink removes animations for e-readers'),
                    const SizedBox(height: 12),
                    Text(
                      'Note: These settings apply to all dataset types.',
                      style: TextStyle(
                        color: (_currentConfiguration?.appSkin == AppSkin.eink)
                            ? Colors.black
                            : Colors.orange[700],
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