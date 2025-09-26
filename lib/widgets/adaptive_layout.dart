import 'package:flutter/material.dart';
import '../models/layout_type.dart';

class AdaptiveLayout extends StatelessWidget {
  final LayoutType layoutType;
  final Widget timerBar;
  final Widget? gameInfoBar;
  final Widget board;
  final Widget buttons;

  const AdaptiveLayout({
    super.key,
    required this.layoutType,
    required this.timerBar,
    this.gameInfoBar,
    required this.board,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    if (layoutType == LayoutType.horizontal) {
      return _buildHorizontalLayout();
    } else {
      return _buildVerticalLayout();
    }
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        // Traditional vertical layout: gear icon is in AppBar, timer bar here
        timerBar,
        if (gameInfoBar != null) gameInfoBar!,
        Expanded(child: board),
        buttons,
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Column 1: Vertical timer bar (narrow, flex: 1)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: timerBar,
          ),
        ),

        // Column 2: Game info bar (if present, flex: 2)
        if (gameInfoBar != null)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RotatedBox(
                quarterTurns: 3, // Rotate for vertical display
                child: gameInfoBar!,
              ),
            ),
          ),

        // Column 3: Main board area (largest, flex: 6)
        Expanded(
          flex: 6,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: board,
          ),
        ),

        // Column 4: Vertical buttons (flex: 2)
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: buttons,
          ),
        ),
      ],
    );
  }
}