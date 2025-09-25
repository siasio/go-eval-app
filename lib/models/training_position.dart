import 'dart:convert';
import 'dart:typed_data';

class TrainingPosition {
  final String id;
  final int boardSize;
  final String stonesBase64;
  final double score;
  final String result;
  final int timeLimit;
  final PositionSource source;
  final GameInfo gameInfo;

  const TrainingPosition({
    required this.id,
    required this.boardSize,
    required this.stonesBase64,
    required this.score,
    required this.result,
    required this.timeLimit,
    required this.source,
    required this.gameInfo,
  });

  factory TrainingPosition.fromJson(Map<String, dynamic> json) {
    return TrainingPosition(
      id: json['id'] as String,
      boardSize: json['board_size'] as int,
      stonesBase64: json['stones'] as String,
      score: (json['score'] as num).toDouble(),
      result: json['result'] as String,
      timeLimit: json['time_limit'] as int,
      source: PositionSource.fromJson(json['source'] as Map<String, dynamic>),
      gameInfo: GameInfo.fromJson(json['game_info'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Decode the base64 stones to a 2D array of integers
  /// Returns boardSize x boardSize array where 0=empty, 1=black, 2=white
  List<List<int>> decodeStones() {
    final bytes = base64Decode(stonesBase64);
    final board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => 0));

    for (int i = 0; i < bytes.length && i < boardSize * boardSize; i++) {
      final row = i ~/ boardSize;
      final col = i % boardSize;
      board[row][col] = bytes[i];
    }

    return board;
  }

  /// Get a human-readable description of the position
  String get description {
    final players = '${source.players.black} vs ${source.players.white}';
    final moveInfo = 'Move ${source.moveNumber}';
    return '$players • $moveInfo';
  }

  /// Get the winner from the result
  String get winner {
    if (result.startsWith('B+')) {
      return 'Black';
    } else if (result.startsWith('W+')) {
      return 'White';
    } else {
      return 'Draw';
    }
  }

  /// Get the margin of victory
  String get margin {
    if (result.contains('R')) {
      return 'Resignation';
    }

    final match = RegExp(r'[+-]?(\d+\.?\d*)').firstMatch(result);
    if (match != null) {
      return '${match.group(1)} points';
    }

    return result;
  }
}

class PositionSource {
  final String sgfFile;
  final int moveNumber;
  final Players players;
  final String date;
  final double komi;

  const PositionSource({
    required this.sgfFile,
    required this.moveNumber,
    required this.players,
    required this.date,
    required this.komi,
  });

  factory PositionSource.fromJson(Map<String, dynamic> json) {
    return PositionSource(
      sgfFile: json['sgf_file'] as String,
      moveNumber: json['move_number'] as int,
      players: Players.fromJson(json['players'] as Map<String, dynamic>),
      date: json['date'] as String,
      komi: (json['komi'] as num).toDouble(),
    );
  }
}

class Players {
  final String black;
  final String white;

  const Players({
    required this.black,
    required this.white,
  });

  factory Players.fromJson(Map<String, dynamic> json) {
    return Players(
      black: json['black'] as String,
      white: json['white'] as String,
    );
  }
}

class TrainingDataset {
  final DatasetMetadata metadata;
  final List<TrainingPosition> positions;

  const TrainingDataset({
    required this.metadata,
    required this.positions,
  });

  factory TrainingDataset.fromJson(Map<String, dynamic> json) {
    return TrainingDataset(
      metadata: DatasetMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      positions: (json['positions'] as List)
          .map((p) => TrainingPosition.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

}

class DatasetMetadata {
  final String name;
  final String description;
  final String version;
  final DateTime createdAt;
  final int totalPositions;

  const DatasetMetadata({
    required this.name,
    required this.description,
    required this.version,
    required this.createdAt,
    required this.totalPositions,
  });

  factory DatasetMetadata.fromJson(Map<String, dynamic> json) {
    return DatasetMetadata(
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalPositions: json['total_positions'] as int,
    );
  }
}

class GameInfo {
  final int blackCaptured;
  final int whiteCaptured;
  final double komi;
  final int? lastMoveRow;
  final int? lastMoveCol;
  final List<MoveSequence>? moveSequence;
  final BoardDisplay? boardDisplay;

  const GameInfo({
    this.blackCaptured = 0,
    this.whiteCaptured = 0,
    this.komi = 0.0,
    this.lastMoveRow,
    this.lastMoveCol,
    this.moveSequence,
    this.boardDisplay,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(
      blackCaptured: json['black_captured'] as int? ?? 0,
      whiteCaptured: json['white_captured'] as int? ?? 0,
      komi: (json['komi'] as num?)?.toDouble() ?? 0.0,
      lastMoveRow: json['last_move_row'] as int?,
      lastMoveCol: json['last_move_col'] as int?,
      moveSequence: json['move_sequence'] != null
          ? (json['move_sequence'] as List)
              .map((m) => MoveSequence.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
      boardDisplay: json['board_display'] != null
          ? BoardDisplay.fromJson(json['board_display'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MoveSequence {
  final int row;
  final int col;
  final int moveNumber;

  const MoveSequence({
    required this.row,
    required this.col,
    required this.moveNumber,
  });

  factory MoveSequence.fromJson(Map<String, dynamic> json) {
    return MoveSequence(
      row: json['row'] as int,
      col: json['col'] as int,
      moveNumber: json['move_number'] as int,
    );
  }
}

class BoardDisplay {
  final int? cropStartRow;
  final int? cropStartCol;
  final int? cropWidth;
  final int? cropHeight;
  final int? focusStartRow;
  final int? focusStartCol;
  final int? focusWidth;
  final int? focusHeight;

  const BoardDisplay({
    this.cropStartRow,
    this.cropStartCol,
    this.cropWidth,
    this.cropHeight,
    this.focusStartRow,
    this.focusStartCol,
    this.focusWidth,
    this.focusHeight,
  });

  factory BoardDisplay.fromJson(Map<String, dynamic> json) {
    return BoardDisplay(
      cropStartRow: json['crop_start_row'] as int?,
      cropStartCol: json['crop_start_col'] as int?,
      cropWidth: json['crop_width'] as int?,
      cropHeight: json['crop_height'] as int?,
      focusStartRow: json['focus_start_row'] as int?,
      focusStartCol: json['focus_start_col'] as int?,
      focusWidth: json['focus_width'] as int?,
      focusHeight: json['focus_height'] as int?,
    );
  }
}