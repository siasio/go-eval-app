import 'package:flutter/material.dart';
import '../models/go_position.dart';
import '../services/position_manager.dart';
import '../widgets/timer_bar.dart';
import '../widgets/go_board.dart';
import '../widgets/result_buttons.dart';
import '../widgets/game_status_bar.dart';

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
  String _feedback = '';
  bool _showFeedbackOverlay = false;
  bool _isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadInitialPosition();
  }

  Future<void> _loadInitialPosition() async {
    try {
      final position = await _positionManager.loadRandomPosition();
      setState(() {
        _currentPosition = position;
        _loading = false;
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

    String resultText;
    switch (result) {
      case GameResult.whiteWins:
        resultText = 'White';
        break;
      case GameResult.draw:
        resultText = 'Draw';
        break;
      case GameResult.blackWins:
        resultText = 'Black';
        break;
    }

    final isCorrect = _positionManager.checkResult(resultText);

    setState(() {
      _showFeedbackOverlay = true;
      _isCorrectAnswer = isCorrect;
    });

    // Load next position after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _loadNextPosition();
    });
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
      _feedback = '';
      _showFeedbackOverlay = false;
    });

    try {
      final position = await _positionManager.loadRandomPosition();
      setState(() {
        _currentPosition = position;
        _timerRunning = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _currentPosition = GoPosition.demo();
        _timerRunning = true;
        _loading = false;
      });
    }
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
      ),
      body: SafeArea(
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
                          child: Container(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNextPosition,
        backgroundColor: const Color(0xFF8B4513),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}