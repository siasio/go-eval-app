import 'package:flutter/material.dart';
import '../models/layout_type.dart';

class AdaptiveLayout extends StatelessWidget {
  final LayoutType layoutType;
  final Widget gearIcon;
  final Widget timerBar;
  final Widget? gameInfoBar;
  final Widget board;
  final Widget buttons;
  final double columnWidth;

  const AdaptiveLayout({
    super.key,
    required this.layoutType,
    required this.gearIcon,
    required this.timerBar,
    this.gameInfoBar,
    required this.board,
    required this.buttons,
    this.columnWidth = 120.0,
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
        // Column 1: Gear icon (narrow, flex: 1)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                gearIcon,
                const Expanded(child: SizedBox()), // Spacer that works with Expanded
              ],
            ),
          ),
        ),

        // Column 2: Vertical timer bar (narrow, flex: 1)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: timerBar,
          ),
        ),

        // Column 3: Game info bar (if present, flex: 2)
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

        // Column 4: Main board area (largest, flex: 6)
        Expanded(
          flex: 6,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: board,
          ),
        ),

        // Column 5: Vertical buttons (flex: 2)
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