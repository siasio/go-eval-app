import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/go_position.dart';
import '../models/scoring_config.dart';
import '../models/dataset_type.dart';
import '../models/dataset_configuration.dart';
import '../services/position_manager.dart';
import '../services/configuration_manager.dart';
import '../services/global_configuration_manager.dart';
import '../models/global_configuration.dart';
import '../models/app_skin.dart';
import '../models/layout_type.dart';
import '../models/timer_type.dart';
import '../widgets/adaptive_layout.dart';
import '../themes/app_theme.dart';
import '../widgets/timer_bar.dart';
import '../widgets/go_board.dart';
import '../widgets/result_buttons.dart';
import '../widgets/context_aware_result_buttons.dart';
import '../widgets/game_status_bar.dart';
import '../models/game_result_option.dart';
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
  final VoidCallback? onConfigurationChanged;

  const TrainingScreen({super.key, this.onConfigurationChanged});

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
  ConfigurationManager? _configManager;
  DatasetConfiguration? _currentConfig;
  GlobalConfigurationManager? _globalConfigManager;
  GlobalConfiguration? _globalConfig;

  @override
  void initState() {
    super.initState();
    _initializeConfiguration();
    // Ensure focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _initializeConfiguration() async {
    try {
      _configManager = await ConfigurationManager.getInstance();
      _globalConfigManager = await GlobalConfigurationManager.getInstance();
      _globalConfig = _globalConfigManager!.getConfiguration();
      _loadInitialPosition();
    } catch (e) {
      // Gracefully handle configuration manager errors
      debugPrint('Error initializing configuration manager: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Using default settings due to configuration error'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _loadInitialPosition();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!_timerRunning || _showFeedbackOverlay) return;

    if (event is KeyDownEvent) {
      if (_positionManager.currentDataset != null &&
          _positionManager.currentTrainingPosition != null) {
        final options = GameResultOption.generateOptions(
          _positionManager.currentDataset!.metadata.datasetType,
          ScoringConfig.parseScore(_positionManager.currentTrainingPosition!.result),
          _positionManager.currentTrainingPosition!.result,
        );

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft && options.isNotEmpty) {
          _onResultOptionSelected(options[0]);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && options.length > 2) {
          _onResultOptionSelected(options[2]);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && options.length > 1) {
          _onResultOptionSelected(options[1]);
        }
      } else {
        // Fallback to old system
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _onResultSelected(GameResult.whiteWins);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _onResultSelected(GameResult.blackWins);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _onResultSelected(GameResult.draw);
        }
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
    // Reload global configuration in case it changed
    if (_globalConfigManager != null) {
      _globalConfig = _globalConfigManager!.getConfiguration();
    }
    // Notify parent app of configuration changes
    widget.onConfigurationChanged?.call();
  }

  Future<void> _loadInitialPosition() async {
    try {
      final position = await _positionManager.loadRandomPosition();
      await _updateConfiguration();
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
      debugPrint('Error loading initial position: $e');
      setState(() {
        _currentPosition = GoPosition.demo();
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load position. Using demo position.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadNextPosition(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateConfiguration() async {
    if (_configManager == null || _positionManager.currentDataset == null) {
      _currentConfig = DatasetConfiguration.getDefaultFor(DatasetType.final9x9Area);
      return;
    }

    final datasetType = _positionManager.currentDataset!.metadata.datasetType;
    _currentConfig = _configManager!.getConfiguration(datasetType);
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

    // Load next position after configured time
    final markDisplayTime = _globalConfig?.markDisplayTimeSeconds ?? 1.5;
    Future.delayed(Duration(milliseconds: (markDisplayTime * 1000).round()), () {
      _loadNextPosition();
    });
  }

  void _onResultOptionSelected(GameResultOption option) {
    setState(() {
      _timerRunning = false;
    });

    setState(() {
      _showFeedbackOverlay = true;
      _isCorrectAnswer = option.isCorrect;
    });

    // Load next position after configured time
    final markDisplayTime = _globalConfig?.markDisplayTimeSeconds ?? 1.5;
    Future.delayed(Duration(milliseconds: (markDisplayTime * 1000).round()), () {
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

    final markDisplayTime = _globalConfig?.markDisplayTimeSeconds ?? 1.5;
    Future.delayed(Duration(milliseconds: (markDisplayTime * 1000).round()), () {
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
      await _updateConfiguration();
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
      debugPrint('Error loading next position: $e');
      setState(() {
        _currentPosition = GoPosition.demo();
        _timerRunning = true;
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load new position: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: _navigateToSettings,
            ),
          ),
        );
      }

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
    final currentSkin = _globalConfig?.appSkin ?? AppSkin.classic;

    final correctColor = SkinConfig.getCorrectColor(currentSkin);
    final incorrectColor = SkinConfig.getIncorrectColor(currentSkin);
    final shouldAnimate = SkinConfig.shouldAnimate(currentSkin);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated or static checkmark/cross
        if (shouldAnimate)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _isCorrectAnswer ? correctColor : incorrectColor,
                    shape: BoxShape.circle,
                    boxShadow: currentSkin != AppSkin.eink ? [
                      BoxShadow(
                        color: (_isCorrectAnswer ? correctColor : incorrectColor).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ] : [],
                  ),
                  child: Icon(
                    _isCorrectAnswer ? Icons.check_rounded : Icons.close_rounded,
                    size: 80,
                    color: currentSkin == AppSkin.eink ? Colors.white : Colors.white,
                  ),
                ),
              );
            },
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _isCorrectAnswer ? correctColor : incorrectColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: currentSkin == AppSkin.eink ? Colors.black : Colors.transparent,
                width: currentSkin == AppSkin.eink ? 2 : 0,
              ),
            ),
            child: Icon(
              _isCorrectAnswer ? Icons.check_rounded : Icons.close_rounded,
              size: 80,
              color: Colors.white,
            ),
          ),
        const SizedBox(height: 20),
        // Animated or static result text
        if (shouldAnimate)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.borderColor, width: 2),
                      boxShadow: currentSkin != AppSkin.eink ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : [],
                    ),
                    child: Text(
                      displayResult,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                        shadows: colors.shadowColor != null && currentSkin != AppSkin.eink ? [
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
                ),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.borderColor, width: 2),
            ),
            child: Text(
              displayResult,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colors.textColor,
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
    if (result == 'Draw') { // result.contains('+0.5') || result.contains('-0.5') || 
      return 'DRAW';
    }

    // Return result as-is for normal wins (B+7.5, W+2, etc.)
    return result;
  }

  ResultDisplayColors _getResultDisplayColors(String result) {
    final currentSkin = _globalConfig?.appSkin ?? AppSkin.classic;

    if (result.isEmpty) {
      // Unknown result - use neutral colors
      return ResultDisplayColors(
        backgroundColor: currentSkin == AppSkin.eink
            ? Colors.white
            : const Color.fromRGBO(80, 80, 80, 0.9),
        textColor: currentSkin == AppSkin.eink
            ? Colors.black
            : Colors.white,
        borderColor: currentSkin == AppSkin.eink
            ? Colors.black
            : Colors.grey,
        shadowColor: currentSkin == AppSkin.eink
            ? null
            : Colors.black,
      );
    }

    final displayResult = _formatResultText(result);

    if (currentSkin == AppSkin.eink) {
      // E-ink theme: use only black/white/gray
      if (displayResult == 'DRAW') {
        return const ResultDisplayColors(
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          shadowColor: null,
        );
      } else if (result.startsWith('W+')) {
        return const ResultDisplayColors(
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          shadowColor: null,
        );
      } else if (result.startsWith('B+')) {
        return const ResultDisplayColors(
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          shadowColor: null,
        );
      }

      return const ResultDisplayColors(
        backgroundColor: Colors.white,
        textColor: Colors.black,
        borderColor: Colors.black,
        shadowColor: null,
      );
    }

    // Handle draws (other themes)
    if (displayResult == 'DRAW') {
      return const ResultDisplayColors(
        backgroundColor: Color.fromRGBO(210, 180, 140, 0.9), // Tan/beige background
        textColor: Color(0xFF5D4037), // Dark brown text
        borderColor: Color(0xFF8D6E63), // Medium brown border
        shadowColor: Color.fromRGBO(255, 255, 255, 0.8), // Light shadow for contrast
      );
    }

    // Handle white wins (other themes)
    if (result.startsWith('W+')) {
      return const ResultDisplayColors(
        backgroundColor: Color.fromRGBO(210, 180, 140, 0.9), // Tan/beige background
        textColor: Colors.white, // White color (representing white stones)
        borderColor: Color(0xFF8D6E63), // Medium brown border
        shadowColor: Colors.black, // Dark shadow
      );
    }

    // Handle black wins (other themes)
    if (result.startsWith('B+')) {
      return const ResultDisplayColors(
        backgroundColor: Color.fromRGBO(210, 180, 140, 0.9), // Tan/beige background
        textColor: Colors.black, // Black color (representing black stones)
        borderColor: Color(0xFF8D6E63), // Medium brown border
        shadowColor: Color.fromRGBO(0, 0, 0, 0.3), // Subtle dark shadow
      );
    }

    // Default fallback
    return ResultDisplayColors(
      backgroundColor: currentSkin == AppSkin.eink
          ? Colors.white
          : const Color.fromRGBO(80, 80, 80, 0.9),
      textColor: currentSkin == AppSkin.eink
          ? Colors.black
          : Colors.white,
      borderColor: currentSkin == AppSkin.eink
          ? Colors.black
          : Colors.grey,
      shadowColor: currentSkin == AppSkin.eink
          ? null
          : Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Go Territory Counting'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToSettings,
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 24),
              Text('Loading next position...', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Get ready to analyze the board!', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      );
    }

    final currentSkin = _globalConfig?.appSkin ?? AppSkin.classic;
    final layoutType = _globalConfig?.layoutType ?? LayoutType.vertical;
    final timerType = _globalConfig?.timerType ?? TimerType.smooth;
    final shouldShowGameInfo = _currentConfig != null ? !_currentConfig!.hideGameInfoBar : true;
    final shouldGrayOutBoard = SkinConfig.shouldGrayOutBoard(currentSkin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Territory Counting'),
        leading: layoutType == LayoutType.horizontal ? IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _navigateToSettings,
        ) : null,
        actions: layoutType == LayoutType.horizontal ? [] : [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        autofocus: true,
        child: SafeArea(
          child: AdaptiveLayout(
            layoutType: layoutType,
            timerBar: _timerRunning
                ? TimerBar(
                    duration: Duration(seconds: _currentConfig?.timePerProblemSeconds ?? 30),
                    onComplete: _onTimerComplete,
                    timerType: timerType,
                    appSkin: currentSkin,
                    isVertical: layoutType == LayoutType.horizontal,
                    barThickness: layoutType == LayoutType.horizontal ? 16.0 : 8.0,
                    segmentGap: layoutType == LayoutType.horizontal ? 4.0 : 2.0,
                  )
                : Container(
                    height: layoutType == LayoutType.horizontal ? 200 : 8,
                    width: layoutType == LayoutType.horizontal ? 16 : null,
                    margin: const EdgeInsets.all(16)
                  ),
            gameInfoBar: shouldShowGameInfo
                ? GameStatusBar(position: _positionManager.currentTrainingPosition)
                : null,
            board: Stack(
              children: [
                GoBoard(
                  position: _currentPosition,
                  trainingPosition: _positionManager.currentTrainingPosition,
                  appSkin: currentSkin,
                ),
                if (_showFeedbackOverlay)
                  Positioned.fill(
                    child: Container(
                      color: shouldGrayOutBoard ? SkinConfig.getFeedbackOverlayColor(currentSkin) : Colors.transparent,
                      child: Center(
                        child: _buildFeedbackWidget(),
                      ),
                    ),
                  ),
              ],
            ),
            buttons: _positionManager.currentDataset != null &&
                    _positionManager.currentTrainingPosition != null
                ? ContextAwareResultButtons(
                    datasetType: _positionManager.currentDataset!.metadata.datasetType,
                    actualScore: ScoringConfig.parseScore(_positionManager.currentTrainingPosition!.result),
                    resultString: _positionManager.currentTrainingPosition!.result,
                    onResultSelected: _timerRunning ? _onResultOptionSelected : (_) {},
                    appSkin: currentSkin,
                    layoutType: layoutType,
                  )
                : ResultButtons(
                    onResultSelected: _timerRunning ? _onResultSelected : (_) {},
                    appSkin: currentSkin,
                    layoutType: layoutType,
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNextPosition,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}