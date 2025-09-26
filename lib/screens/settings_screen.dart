import 'package:flutter/material.dart';
import '../widgets/dataset_selector.dart';
import '../services/position_loader.dart';
import 'configuration_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _sourceInfo;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() {
      _loading = true;
    });

    try {
      final stats = await PositionLoader.getStatistics();
      final source = PositionLoader.getSourceInfo();
      setState(() {
        _statistics = stats;
        _sourceInfo = source;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onDatasetChanged() {
    _loadInfo(); // Refresh info when dataset changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DatasetSelector(onDatasetChanged: _onDatasetChanged),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.library_books, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Dataset Types Explained',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDatasetExplanation(
                      '🎯 Final 9x9 Positions',
                      'Game-ending positions on 9x9 boards analyzed with KataGo\'s AI ownership maps. '
                      'These positions show clear territorial outcomes where stones are mostly settled. '
                      'Good for beginners to learn basic territory evaluation.',
                    ),
                    const SizedBox(height: 12),
                    _buildDatasetExplanation(
                      '🏟️ Final 19x19 Positions',
                      'Game-ending positions on full 19x19 boards with AI-based territory analysis. '
                      'More complex than 9x9 with larger-scale territorial judgments. '
                      'Ideal for intermediate players.',
                    ),
                    const SizedBox(height: 12),
                    _buildDatasetExplanation(
                      '⚡ Midgame 19x19 Estimation',
                      'Mid-game positions where the outcome is not yet decided. '
                      'Requires evaluating potential territory, influence, and fighting outcomes. '
                      'Challenging positions for advanced players to test territorial intuition.',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Start with 9x9 Final positions if you\'re new to territory counting, '
                              'then progress to 19x19 positions as you improve.',
                              style: TextStyle(fontSize: 13, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Dataset Configuration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Configure thresholds, timing, and display settings for each dataset type.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConfigurationScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('Open Configuration'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'How to Use the App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🎯 App Functionality',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• View Go positions from actual games and predict the winner\n'
                      '• Choose from different datasets (9x9 final, 19x19 midgame, etc.)\n'
                      '• Get immediate feedback on your predictions\n'
                      '• Track your accuracy with built-in scoring',
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '⌨️ Keyboard Shortcuts',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ← Left Arrow: Select White Wins\n'
                      '• ↓ Down Arrow: Select Draw\n'
                      '• → Right Arrow: Select Black Wins\n'
                      '• Look for arrow icons on the buttons for quick reference',
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '⚙️ Configuration Options',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Use the "Dataset Configuration" section above to customize:\n'
                      '  - Scoring thresholds for each dataset type\n'
                      '  - Timer settings and display preferences\n'
                      '  - Advanced training parameters',
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_statistics != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Dataset Statistics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Positions', _statistics!['total_positions'].toString()),
                      _buildStatRow('Version', _statistics!['version'].toString()),
                      _buildStatRow('Created', _formatDate(_statistics!['created_at'])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_sourceInfo != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Source Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('Source Type', _sourceInfo!['source']),
                        _buildStatRow('File', _sourceInfo!['file']),
                        if (_sourceInfo!['path'] != null)
                          _buildStatRow('Path', _sourceInfo!['path']),
                        if (_sourceInfo!['has_bytes'] == true)
                          _buildStatRow('Loaded from', 'Memory (Web)'),
                      ],
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 32),
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
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Go Territory Counting Training App',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This app helps you practice predicting game outcomes from Go positions. '
                      'You can load different datasets containing positions from actual games '
                      'and test your ability to determine who is winning.',
                      style: TextStyle(color: Colors.grey),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDatasetExplanation(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }


  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}