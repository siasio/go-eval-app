import 'package:flutter/material.dart';
import '../models/scoring_config.dart';

class ResultButtons extends StatelessWidget {
  final Function(GameResult) onResultSelected;

  const ResultButtons({
    super.key,
    required this.onResultSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildResultButton(
              label: 'White Wins',
              color: Colors.white,
              textColor: Colors.black87,
              borderColor: Colors.grey[400]!,
              result: GameResult.whiteWins,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildResultButton(
              label: 'Draw',
              color: const Color(0xFFD2B48C), // Tan/light brown
              textColor: Colors.black87,
              borderColor: const Color(0xFFA0522D),
              result: GameResult.draw,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildResultButton(
              label: 'Black Wins',
              color: const Color(0xFF2C2C2C), // Dark gray/black
              textColor: Colors.white,
              borderColor: Colors.black,
              result: GameResult.blackWins,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultButton({
    required String label,
    required Color color,
    required Color textColor,
    required Color borderColor,
    required GameResult result,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onResultSelected(result),
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
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}