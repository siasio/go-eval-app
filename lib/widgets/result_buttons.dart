import 'package:flutter/material.dart';
import '../models/scoring_config.dart';
import '../models/app_skin.dart';
import '../models/layout_type.dart';
import '../themes/app_theme.dart';

class ResultButtons extends StatelessWidget {
  final Function(GameResult) onResultSelected;
  final AppSkin appSkin;
  final LayoutType layoutType;

  const ResultButtons({
    super.key,
    required this.onResultSelected,
    this.appSkin = AppSkin.classic,
    this.layoutType = LayoutType.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _buildResultButton(
        label: 'White Wins',
        buttonTypeKey: 'white',
        result: GameResult.whiteWins,
      ),
      _buildResultButton(
        label: 'Draw',
        buttonTypeKey: 'draw',
        result: GameResult.draw,
      ),
      _buildResultButton(
        label: 'Black Wins',
        buttonTypeKey: 'black',
        result: GameResult.blackWins,
      ),
    ];

    if (layoutType == LayoutType.horizontal) {
      // Vertical arrangement: White (top), Draw (middle), Black (bottom)
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: buttons.map((button) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: button,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // Horizontal arrangement
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: buttons.map((button) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: button,
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  Widget _buildResultButton({
    required String label,
    required String buttonTypeKey,
    required GameResult result,
  }) {
    final color = SkinConfig.getButtonColor(appSkin, buttonTypeKey);
    final textColor = SkinConfig.getButtonTextColor(appSkin, buttonTypeKey);
    final borderColor = SkinConfig.getBorderColor(appSkin);
    final isVertical = layoutType == LayoutType.horizontal;

    return Material(
      elevation: appSkin == AppSkin.eink ? 0 : 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onResultSelected(result),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: isVertical ? null : 60,
          width: isVertical ? double.infinity : null,
          constraints: isVertical ? const BoxConstraints(minHeight: 80) : null,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: appSkin == AppSkin.eink ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isVertical
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_getKeyboardIcon(result) != null) ...[
                        Icon(
                          _getKeyboardIcon(result),
                          size: 20,
                          color: appSkin == AppSkin.eink
                              ? textColor
                              : textColor.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_getKeyboardIcon(result) != null) ...[
                        Icon(
                          _getKeyboardIcon(result),
                          size: 16,
                          color: appSkin == AppSkin.eink
                              ? textColor
                              : textColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  IconData? _getKeyboardIcon(GameResult result) {
    switch (result) {
      case GameResult.whiteWins:
        return Icons.keyboard_arrow_left;
      case GameResult.draw:
        return Icons.keyboard_arrow_down;
      case GameResult.blackWins:
        return Icons.keyboard_arrow_right;
    }
  }
}