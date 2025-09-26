import 'package:flutter/material.dart';
import '../models/training_position.dart';
import '../models/app_skin.dart';
import '../themes/app_theme.dart';

class GameStatusBar extends StatelessWidget {
  final TrainingPosition? position;
  final AppSkin appSkin;

  const GameStatusBar({
    super.key,
    required this.position,
    this.appSkin = AppSkin.classic,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = SkinConfig.getResultBackgroundColor(appSkin);
    final textColor = SkinConfig.getTextColor(appSkin);
    final shouldAnimate = SkinConfig.shouldAnimate(appSkin);

    if (position == null) {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Demo position', style: TextStyle(fontSize: 12, color: textColor)),
          ],
        ),
      );
    }

    final gameInfo = position!.gameInfo;

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: shouldAnimate ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Black captures
          Expanded(
            child: _buildCaptureInfo(
              'Black stones dead',
              gameInfo?.whiteCaptured ?? 0, // White captured black stones
              Colors.black,
            ),
          ),

          // Komi
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Komi',
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                Text(
                  '${gameInfo?.komi ?? 0}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          // White captures
          Expanded(
            child: _buildCaptureInfo(
              'White stones dead',
              gameInfo?.blackCaptured ?? 0, // Black captured white stones
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureInfo(String label, int count, Color stoneColor) {
    final textColor = SkinConfig.getTextColor(appSkin);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stoneColor,
                border: Border.all(
                  color: stoneColor == Colors.white ? Colors.black : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: textColor.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}