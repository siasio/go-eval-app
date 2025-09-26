import 'package:flutter/material.dart';
import '../models/dataset_type.dart';
import '../models/game_result_option.dart';
import '../models/app_skin.dart';
import '../models/layout_type.dart';
import '../themes/app_theme.dart';

class ContextAwareResultButtons extends StatelessWidget {
  final DatasetType datasetType;
  final double actualScore;
  final String resultString;
  final Function(GameResultOption) onResultSelected;
  final AppSkin appSkin;
  final LayoutType layoutType;

  const ContextAwareResultButtons({
    super.key,
    required this.datasetType,
    required this.actualScore,
    required this.resultString,
    required this.onResultSelected,
    this.appSkin = AppSkin.classic,
    this.layoutType = LayoutType.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final options = GameResultOption.generateOptions(
      datasetType,
      actualScore,
      resultString,
    );

    if (layoutType == LayoutType.horizontal) {
      // Vertical arrangement for horizontal mode: White (top), Draw (middle), Black (bottom)
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: options.map((option) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildResultButton(option, isVertical: true),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // Horizontal arrangement for vertical mode
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: options.map((option) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: options.length == 3 ? 6 : 8,
                ),
                child: _buildResultButton(option, isVertical: false),
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  Widget _buildResultButton(GameResultOption option, {required bool isVertical}) {
    final String buttonTypeKey = option.buttonType == ButtonType.whiteWins
        ? 'white'
        : option.buttonType == ButtonType.blackWins
        ? 'black'
        : 'draw';

    final color = SkinConfig.getButtonColor(appSkin, buttonTypeKey);
    final textColor = SkinConfig.getButtonTextColor(appSkin, buttonTypeKey);
    final borderColor = SkinConfig.getBorderColor(appSkin);

    return Material(
      elevation: appSkin == AppSkin.eink ? 0 : 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onResultSelected(option),
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
                      if (_getKeyboardIcon(option.buttonType) != null) ...[
                        Icon(
                          _getKeyboardIcon(option.buttonType),
                          size: 20,
                          color: appSkin == AppSkin.eink
                              ? textColor
                              : textColor.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        option.displayText,
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
                      if (_getKeyboardIcon(option.buttonType) != null) ...[
                        Icon(
                          _getKeyboardIcon(option.buttonType),
                          size: 16,
                          color: appSkin == AppSkin.eink
                              ? textColor
                              : textColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        option.displayText,
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

  IconData? _getKeyboardIcon(ButtonType buttonType) {
    switch (buttonType) {
      case ButtonType.whiteWins:
        return Icons.keyboard_arrow_left;
      case ButtonType.draw:
        return Icons.keyboard_arrow_down;
      case ButtonType.blackWins:
        return Icons.keyboard_arrow_right;
    }
  }
}