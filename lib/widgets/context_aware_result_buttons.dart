import 'package:flutter/material.dart';
import '../models/dataset_type.dart';
import '../models/game_result_option.dart';

class ContextAwareResultButtons extends StatelessWidget {
  final DatasetType datasetType;
  final double actualScore;
  final String resultString;
  final Function(GameResultOption) onResultSelected;

  const ContextAwareResultButtons({
    super.key,
    required this.datasetType,
    required this.actualScore,
    required this.resultString,
    required this.onResultSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = GameResultOption.generateOptions(
      datasetType,
      actualScore,
      resultString,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: options.map((option) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: options.length == 3 ? 6 : 8,
              ),
              child: _buildResultButton(option),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultButton(GameResultOption option) {
    Color color;
    Color textColor;
    Color borderColor;

    switch (option.buttonType) {
      case ButtonType.whiteWins:
        color = Colors.white;
        textColor = Colors.black87;
        borderColor = Colors.grey[400]!;
        break;
      case ButtonType.draw:
        color = const Color(0xFFD2B48C); // Tan/light brown
        textColor = Colors.black87;
        borderColor = const Color(0xFFA0522D);
        break;
      case ButtonType.blackWins:
        color = const Color(0xFF2C2C2C); // Dark gray/black
        textColor = Colors.white;
        borderColor = Colors.black;
        break;
    }

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onResultSelected(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_getKeyboardIcon(option.buttonType) != null) ...[
                  Icon(
                    _getKeyboardIcon(option.buttonType),
                    size: 16,
                    color: textColor.withOpacity(0.7),
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