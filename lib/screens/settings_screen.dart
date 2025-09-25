import 'package:flutter/material.dart';
import '../widgets/dataset_selector.dart';
import '../models/scoring_config.dart';
import '../services/position_loader.dart';

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
                        const Icon(Icons.tune, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Scoring Configuration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Current Settings:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Draw border: ±${ScoringConfig.defaultConfig.drawBorder} points',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      '• Color border: ±${ScoringConfig.defaultConfig.colorBorder} points',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Explanation:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Games within ±${ScoringConfig.defaultConfig.drawBorder} points: DRAW button gives ✓',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '• White wins by >${ScoringConfig.defaultConfig.colorBorder} points: WHITE button gives ✓',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '• Black wins by >${ScoringConfig.defaultConfig.colorBorder} points: BLACK button gives ✓',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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


  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}