import 'package:flutter/material.dart';
import '../models/go_position.dart';
import '../models/training_position.dart';
import '../models/app_skin.dart';
import '../themes/app_theme.dart';
import 'go_board.dart';

/// A container widget that encapsulates the Go board with consistent overlay behavior
/// and stable sizing across different layout modes.
class GameBoardContainer extends StatefulWidget {
  final GoPosition position;
  final TrainingPosition? trainingPosition;
  final AppSkin appSkin;
  final bool showFeedbackOverlay;
  final Widget? feedbackWidget;

  const GameBoardContainer({
    super.key,
    required this.position,
    this.trainingPosition,
    this.appSkin = AppSkin.classic,
    this.showFeedbackOverlay = false,
    this.feedbackWidget,
  });

  @override
  State<GameBoardContainer> createState() => _GameBoardContainerState();
}

class _GameBoardContainerState extends State<GameBoardContainer> {
  double? _cachedBoardSize;

  @override
  Widget build(BuildContext context) {
    final shouldGrayOutBoard = SkinConfig.shouldGrayOutBoard(widget.appSkin);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Only recalculate board size when the overlay is not showing to prevent jumping
        if (_cachedBoardSize == null || !widget.showFeedbackOverlay) {
          // Calculate optimal board size to maintain 1:1 aspect ratio
          final availableSize = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;

          // Account for margins and ensure minimum size
          _cachedBoardSize = (availableSize - 32).clamp(200.0, double.infinity);
        }

        return Center(
          child: SizedBox(
            width: _cachedBoardSize!,
            height: _cachedBoardSize!,
            child: Stack(
              children: [
                // The Go board itself
                GoBoard(
                  position: widget.position,
                  trainingPosition: widget.trainingPosition,
                  appSkin: widget.appSkin,
                ),
                // Overlay that only covers the board area
                if (widget.showFeedbackOverlay)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: shouldGrayOutBoard
                            ? SkinConfig.getFeedbackOverlayColor(widget.appSkin)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.feedbackWidget != null
                          ? Center(child: widget.feedbackWidget!)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}