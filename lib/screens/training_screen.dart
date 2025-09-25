import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/go_position.dart';
import '../models/scoring_config.dart';
import '../services/position_manager.dart';
import '../widgets/timer_bar.dart';
import '../widgets/go_board.dart';
import '../widgets/result_buttons.dart';
import '../widgets/game_status_bar.dart';
import './settings_screen.dart';

class ResultDisplayColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color? shadowColor;

  const ResultDisplayColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.shadowColor,
  });
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late GoPosition _currentPosition;
  bool _timerRunning = true;
  final PositionManager _positionManager = PositionManager();
  bool _loading = true;
  bool _showFeedbackOverlay = false;
  bool _isCorrectAnswer = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadInitialPosition();
    // Ensure focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!_timerRunning || _showFeedbackOverlay) return;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _onResultSelected(GameResult.whiteWins);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _onResultSelected(GameResult.blackWins);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _onResultSelected(GameResult.draw);
      }
    }
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    // Reload position in case dataset changed
    _loadInitialPosition();
  }

  Future<void> _loadInitialPosition() async {
    try {
      final position = await _positionManager.loadRandomPosition();
      setState(() {
        _currentPosition = position;
        _loading = false;
      });
      // Request focus for keyboard input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    } catch (e) {
      setState(() {
        _currentPosition = GoPosition.demo();
        _loading = false;
      });
    }
  }

  void _onResultSelected(GameResult result) {
    setState(() {
      _timerRunning = false;
    });

    final isCorrect = _checkResultUsingNewSystem(result);

    setState(() {
      _showFeedbackOverlay = true;
      _isCorrectAnswer = isCorrect;
    });

    // Load next position after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _loadNextPosition();
    });
  }

  bool _checkResultUsingNewSystem(GameResult selectedResult) {
    final currentTrainingPosition = _positionManager.currentTrainingPosition;
    if (currentTrainingPosition == null) return false;

    // Parse the score from the result string
    final actualScore = ScoringConfig.parseScore(currentTrainingPosition.result);

    // Get all valid results for this score using default config
    final validResults = ScoringConfig.defaultConfig.getValidResults(actualScore);

    // Check if the selected result is among the valid ones
    return validResults.contains(selectedResult);
  }

  void _onTimerComplete() {
    setState(() {
      _timerRunning = false;
      _showFeedbackOverlay = true;
      _isCorrectAnswer = false; // Show red cross for timeout
    });

    Future.delayed(const Duration(seconds: 2), () {
      _loadNextPosition();
    });
  }

  Future<void> _loadNextPosition() async {
    setState(() {
      _loading = true;
      _showFeedbackOverlay = false;
    });

    try {
      final position = await _positionManager.loadRandomPosition();
      setState(() {
        _currentPosition = position;
        _timerRunning = true;
        _loading = false;
      });
      // Request focus for keyboard input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    } catch (e) {
      setState(() {
        _currentPosition = GoPosition.demo();
        _timerRunning = true;
        _loading = false;
      });
      // Request focus for keyboard input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  Widget _buildFeedbackWidget() {
    final result = _positionManager.currentTrainingPosition?.result ?? '';
    final displayResult = _formatResultText(result);
    final colors = _getResultDisplayColors(result);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: _isCorrectAnswer ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isCorrectAnswer ? Icons.check : Icons.close,
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.borderColor, width: 2),
          ),
          child: Text(
            displayResult,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
              shadows: colors.shadowColor != null ? [
                Shadow(
                  offset: const Offset(0, 0),
                  blurRadius: 3,
                  color: colors.shadowColor!,
                ),
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: colors.shadowColor!,
                ),
              ] : null,
            ),
          ),
        ),
      ],
    );
  }

  String _formatResultText(String result) {
    if (result.isEmpty) return 'UNKNOWN';

    // Handle resignation
    if (result.endsWith('+R')) {
      return result.startsWith('B') ? 'B+R' : 'W+R';
    }

    // Handle draws (0.5 point difference or exact draw)
    if (result.contains('+0.5') || result.contains('-0.5') || result == 'Draw') {
      return 'DRAW';
    }

    // Return result as-is for normal wins (B+7.5, W+2, etc.)
    return result;
  }

  ResultDisplayColors _getResultDisplayColors(String result) {
    if (result.isEmpty) {
      // Unknown result - use neutral colors
      return const ResultDisplayColors(
        backgroundColor: Color.fromRGBO(80, 80, 80, 0.9), // Dark gray
        textColor: Colors.white,
        borderColor: Colors.grey,
        shadowColor: Colors.black,
      );
    }

    final displayResult = _formatResultText(result);

    // Handle draws
    if (displayResult == 'DRAW') {
      return const ResultDisplayColors(
        backgroundColor: Color.fromRGBO(210, 180, 140, 0.9), // Tan/beige background
        textColor: Color(0xFF5D4037), // Dark brown text
        borderColor: Color(0xFF8D6E63), // Medium brown border
        shadowColor: Color.fromRGBO(255, 255, 255, 0.8), // Light shadow for contrast
      );
    }

    // Handle white wins
    if (result.startsWith('W+')) {
      return const ResultDisplayColors(
        backgroundColor: Color.fromRGBO(80, 80, 80, 0.9), // Dark gray background
        textColor: Colors.white, // White text for excellent contrast (representing white stones)
        borderColor: Color.fromRGBO(160, 160, 160, 0.8), // Light gray border
        shadowColor: Colors.black, // Dark shadow
      );
    }

    // Handle black wins
    if (result.startsWith('B+')) {
      return const ResultDisplayColors(
        backgroundColor: Color.fromRGBO(250, 250, 250, 0.92), // Very light gray background
        textColor: Color(0xFF2C2C2C), // Dark gray text for excellent contrast (representing black stones)
        borderColor: Color.fromRGBO(120, 120, 120, 0.7), // Medium gray border
        shadowColor: Color.fromRGBO(0, 0, 0, 0.3), // Subtle dark shadow
      );
    }

    // Default fallback
    return const ResultDisplayColors(
      backgroundColor: Color.fromRGBO(80, 80, 80, 0.9),
      textColor: Colors.white,
      borderColor: Colors.grey,
      shadowColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5DC),
        appBar: AppBar(
          title: const Text(
            'Go Territory Counting',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF8B4513),
          elevation: 4,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _navigateToSettings,
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8B4513),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige background
      appBar: AppBar(
        title: const Text(
          'Go Territory Counting',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513), // Saddle brown
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        autofocus: true,
        child: SafeArea(
          child: Column(
            children: [
              // Timer Bar
              if (_timerRunning)
                TimerBar(
                  duration: const Duration(seconds: 30),
                  onComplete: _onTimerComplete,
                )
              else
                Container(
                  height: 40,
                  margin: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      'Position Complete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),

              // Game Status Bar
              GameStatusBar(position: _positionManager.currentTrainingPosition),

              // Go Board with Overlay
              Expanded(
                child: Stack(
                  children: [
                    GoBoard(
                      position: _currentPosition,
                      trainingPosition: _positionManager.currentTrainingPosition,
                    ),
                    if (_showFeedbackOverlay)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: Center(
                            child: _buildFeedbackWidget(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Result Buttons
              ResultButtons(
                onResultSelected: _timerRunning ? _onResultSelected : (_) {},
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNextPosition,
        backgroundColor: const Color(0xFF8B4513),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}