import 'package:flutter/material.dart';
import '../models/go_position.dart';
import '../models/training_position.dart';

class GoBoard extends StatelessWidget {
  final GoPosition position;
  final TrainingPosition? trainingPosition;

  const GoBoard({
    super.key,
    required this.position,
    this.trainingPosition,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDEB887), // Burlywood color
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: GoBoardPainter(position, trainingPosition),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class GoBoardPainter extends CustomPainter {
  final GoPosition position;
  final TrainingPosition? trainingPosition;

  GoBoardPainter(this.position, this.trainingPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Determine board display area
    final boardDisplay = trainingPosition?.gameInfo.boardDisplay;
    final int displayStartRow = boardDisplay?.cropStartRow ?? 0;
    final int displayStartCol = boardDisplay?.cropStartCol ?? 0;
    final int displayWidth = boardDisplay?.cropWidth ?? position.size;
    final int displayHeight = boardDisplay?.cropHeight ?? position.size;

    final double cellSize = size.width / (displayWidth + 1);
    final double boardStart = cellSize;
    final double boardEnd = size.width - cellSize;

    // Draw grid lines with proper intersection handling for cropped boards
    _drawGridLines(canvas, size, boardStart, cellSize, displayStartRow, displayStartCol,
                   displayWidth, displayHeight, paint);

    // Draw star points for 19x19 board (only if visible in crop)
    if (position.size == 19) {
      final starPoints = [3, 9, 15];
      final starPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      for (int row in starPoints) {
        for (int col in starPoints) {
          if (row >= displayStartRow && row < displayStartRow + displayHeight &&
              col >= displayStartCol && col < displayStartCol + displayWidth) {
            final double x = boardStart + (col - displayStartCol) * cellSize;
            final double y = boardStart + (row - displayStartRow) * cellSize;
            canvas.drawCircle(Offset(x, y), 3, starPaint);
          }
        }
      }
    }

    // Draw stones
    final double stoneRadius = cellSize * 0.4;

    for (int row = displayStartRow; row < displayStartRow + displayHeight && row < position.size; row++) {
      for (int col = displayStartCol; col < displayStartCol + displayWidth && col < position.size; col++) {
        final stone = position.board[row][col];
        if (stone != StoneColor.empty) {
          final double x = boardStart + (col - displayStartCol) * cellSize;
          final double y = boardStart + (row - displayStartRow) * cellSize;

          // Stone shadow
          final shadowPaint = Paint()
            ..color = Colors.black.withOpacity(0.3)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(x + 1, y + 1),
            stoneRadius,
            shadowPaint,
          );

          // Stone body
          final stonePaint = Paint()
            ..style = PaintingStyle.fill;

          if (stone == StoneColor.black) {
            stonePaint.shader = RadialGradient(
              colors: [
                const Color(0xFF4A4A4A),
                const Color(0xFF1A1A1A),
              ],
            ).createShader(Rect.fromCircle(
              center: Offset(x, y),
              radius: stoneRadius,
            ));
          } else {
            stonePaint.shader = RadialGradient(
              colors: [
                const Color(0xFFFFFFF0),
                const Color(0xFFE8E8E8),
              ],
            ).createShader(Rect.fromCircle(
              center: Offset(x, y),
              radius: stoneRadius,
            ));
          }

          canvas.drawCircle(Offset(x, y), stoneRadius, stonePaint);

          // Stone highlight
          final highlightPaint = Paint()
            ..color = Colors.white.withOpacity(stone == StoneColor.black ? 0.3 : 0.6)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(x - stoneRadius * 0.3, y - stoneRadius * 0.3),
            stoneRadius * 0.2,
            highlightPaint,
          );

          // Draw last move marker (triangle)
          if (trainingPosition?.gameInfo.lastMoveRow == row &&
              trainingPosition?.gameInfo.lastMoveCol == col) {
            _drawLastMoveMarker(canvas, x, y, stoneRadius, stone);
          }
        }

        // Draw move sequence numbers
        if (trainingPosition?.gameInfo.moveSequence != null) {
          for (final move in trainingPosition!.gameInfo.moveSequence!) {
            if (move.row == row && move.col == col && position.board[row][col] == StoneColor.empty) {
              final double x = boardStart + (col - displayStartCol) * cellSize;
              final double y = boardStart + (row - displayStartRow) * cellSize;
              _drawMoveNumber(canvas, x, y, move.moveNumber, stoneRadius);
            }
          }
        }
      }
    }

    // Draw focus area highlighting (gray out everything except focus area)
    if (boardDisplay?.focusStartRow != null && boardDisplay?.focusStartCol != null &&
        boardDisplay?.focusWidth != null && boardDisplay?.focusHeight != null) {
      _drawFocusHighlight(canvas, size, boardStart, cellSize, displayStartRow, displayStartCol,
                         displayWidth, displayHeight, boardDisplay!);
    }
  }

  void _drawGridLines(Canvas canvas, Size size, double boardStart, double cellSize,
                     int displayStartRow, int displayStartCol, int displayWidth, int displayHeight,
                     Paint paint) {
    final halfCell = cellSize * 0.5;

    // Draw lines for each intersection
    for (int displayRow = 0; displayRow < displayHeight; displayRow++) {
      for (int displayCol = 0; displayCol < displayWidth; displayCol++) {
        final actualRow = displayStartRow + displayRow;
        final actualCol = displayStartCol + displayCol;

        final double x = boardStart + displayCol * cellSize;
        final double y = boardStart + displayRow * cellSize;

        // Draw horizontal line through this intersection
        double leftEnd = x;
        double rightEnd = x;

        // Extend left
        if (displayCol > 0 || actualCol > 0) {
          leftEnd = displayCol > 0 ? boardStart : x - halfCell;
        }

        // Extend right
        if (displayCol < displayWidth - 1 || actualCol < position.size - 1) {
          rightEnd = displayCol < displayWidth - 1
              ? boardStart + (displayWidth - 1) * cellSize
              : x + halfCell;
        }

        if (leftEnd != rightEnd) {
          canvas.drawLine(Offset(leftEnd, y), Offset(rightEnd, y), paint);
        }

        // Draw vertical line through this intersection
        double topEnd = y;
        double bottomEnd = y;

        // Extend up
        if (displayRow > 0 || actualRow > 0) {
          topEnd = displayRow > 0 ? boardStart : y - halfCell;
        }

        // Extend down
        if (displayRow < displayHeight - 1 || actualRow < position.size - 1) {
          bottomEnd = displayRow < displayHeight - 1
              ? boardStart + (displayHeight - 1) * cellSize
              : y + halfCell;
        }

        if (topEnd != bottomEnd) {
          canvas.drawLine(Offset(x, topEnd), Offset(x, bottomEnd), paint);
        }
      }
    }
  }

  void _drawFocusHighlight(Canvas canvas, Size size, double boardStart, double cellSize,
                          int displayStartRow, int displayStartCol, int displayWidth, int displayHeight,
                          BoardDisplay boardDisplay) {
    final focusStartRow = boardDisplay.focusStartRow!;
    final focusStartCol = boardDisplay.focusStartCol!;
    final focusWidth = boardDisplay.focusWidth!;
    final focusHeight = boardDisplay.focusHeight!;

    final overlayPaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Calculate focus area in display coordinates
    final focusDisplayStartRow = focusStartRow - displayStartRow;
    final focusDisplayStartCol = focusStartCol - displayStartCol;

    // Only draw overlay if focus area intersects with display area
    if (focusDisplayStartRow < displayHeight && focusDisplayStartCol < displayWidth &&
        focusDisplayStartRow + focusHeight > 0 && focusDisplayStartCol + focusWidth > 0) {

      // Draw overlay on areas outside the focus
      final focusLeft = boardStart + (focusDisplayStartCol * cellSize) - (cellSize * 0.5);
      final focusTop = boardStart + (focusDisplayStartRow * cellSize) - (cellSize * 0.5);
      final focusRight = focusLeft + (focusWidth * cellSize);
      final focusBottom = focusTop + (focusHeight * cellSize);

      final boardRect = Rect.fromLTWH(0, 0, size.width, size.height);
      final focusRect = Rect.fromLTWH(
        focusLeft.clamp(0, size.width),
        focusTop.clamp(0, size.height),
        (focusRight - focusLeft).clamp(0, size.width - focusLeft.clamp(0, size.width)),
        (focusBottom - focusTop).clamp(0, size.height - focusTop.clamp(0, size.height)),
      );

      // Create path excluding focus area
      final path = Path()
        ..addRect(boardRect)
        ..addRect(focusRect)
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(path, overlayPaint);
    }
  }

  void _drawLastMoveMarker(Canvas canvas, double x, double y, double stoneRadius, StoneColor stoneColor) {
    final trianglePaint = Paint()
      ..color = stoneColor == StoneColor.black ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;

    final triangleSize = stoneRadius * 0.5;
    final path = Path();

    // Draw triangle pointing up
    path.moveTo(x, y - triangleSize);
    path.lineTo(x - triangleSize * 0.8, y + triangleSize * 0.5);
    path.lineTo(x + triangleSize * 0.8, y + triangleSize * 0.5);
    path.close();

    canvas.drawPath(path, trianglePaint);
  }

  void _drawMoveNumber(Canvas canvas, double x, double y, int moveNumber, double stoneRadius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$moveNumber',
        style: TextStyle(
          color: Colors.black,
          fontSize: stoneRadius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(GoBoardPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.trainingPosition != trainingPosition;
  }
}