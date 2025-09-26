import 'package:flutter/material.dart';
import '../models/layout_type.dart';

class AdaptiveLayout extends StatelessWidget {
  final LayoutType layoutType;
  final Widget menuBar;
  final Widget? gameInfoBar;
  final Widget board;
  final Widget buttons;
  final double sidebarWidth;

  const AdaptiveLayout({
    super.key,
    required this.layoutType,
    required this.menuBar,
    this.gameInfoBar,
    required this.board,
    required this.buttons,
    this.sidebarWidth = 180.0,
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
        menuBar,
        if (gameInfoBar != null) gameInfoBar!,
        Expanded(child: board),
        buttons,
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        // Left sidebar with vertical menu and game info
        Container(
          width: sidebarWidth,
          child: Column(
            children: [
              // Timer bar positioned vertically without rotation
              Container(
                height: 200, // Height for vertical timer
                child: menuBar,
              ),
              const SizedBox(height: 8),

              // Vertical game info bar
              if (gameInfoBar != null) ...[
                Expanded(
                  flex: 1,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Container(
                      width: 120, // This becomes the height when rotated
                      child: gameInfoBar!,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const Spacer(),
            ],
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Main board area - centered
        Expanded(
          child: Center(
            child: board,
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // Right sidebar with vertical buttons
        Container(
          width: sidebarWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Vertical button arrangement: Black (top), Draw (middle), White (bottom)
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: buttons,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}