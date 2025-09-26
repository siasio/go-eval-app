# Go Territory Trainer - Flutter App

Cross-platform mobile and web application for training Go territory counting skills.

## Features

- **Multiple Dataset Support**: Train on different Go position datasets:
  - 9x9 Final positions (area-based scoring with KataGo ownership maps)
  - 19x19 Midgame positions (territory estimation)
  - Support for custom dataset loading via file picker
- **Animated Timer Bar**: Visual countdown with color changes (green → orange → red)
- **Interactive Go Board**: Supports multiple board sizes (9x9, 19x19) with:
  - Realistic stone rendering
  - Region highlighting and cropping
  - Move sequence visualization
  - Last move indicators
- **Context-Aware Result Buttons**: Dynamic button options based on dataset type and scoring
- **Keyboard Shortcuts**: Arrow key support for quick selection
- **Configuration System**: Per-dataset customizable settings for timing and scoring thresholds
- **Statistics Tracking**: View dataset information and position statistics
- **Cross-Platform**: Runs on Android, Web, and Desktop

## Prerequisites

1. **Install Flutter**: Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install)
2. **Verify Installation**: Run `flutter doctor` to ensure everything is set up correctly

## Development

### Running the App

```bash
cd app/

# Desktop (fastest for development)
flutter run -d windows   # Windows
flutter run -d macos     # macOS
flutter run -d linux     # Linux

# Web browser
flutter run -d chrome

# Android device/emulator
flutter run
```

### Project Structure

```
app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/                        # Core logic
│   │   ├── dataset_parser.dart      # JSON dataset parsing
│   │   ├── game_result_parser.dart  # Game result parsing
│   │   └── go_logic.dart            # Go game logic
│   ├── models/                      # Data models
│   │   ├── go_position.dart         # Go board position data
│   │   ├── training_position.dart   # Training position data
│   │   ├── dataset_type.dart        # Dataset type enumeration
│   │   ├── dataset_configuration.dart # Configuration model
│   │   ├── scoring_config.dart      # Scoring configuration
│   │   └── game_result_option.dart  # Result option model
│   ├── screens/                     # UI screens
│   │   ├── training_screen.dart     # Main training screen
│   │   ├── settings_screen.dart     # Settings and info screen
│   │   └── configuration_screen.dart # Dataset configuration
│   ├── services/                    # Services layer
│   │   ├── position_manager.dart    # Position management
│   │   ├── position_loader.dart     # Dataset loading
│   │   ├── configuration_manager.dart # Settings management
│   │   └── dataset_preference_manager.dart # User preferences
│   └── widgets/                     # Reusable widgets
│       ├── timer_bar.dart           # Animated countdown timer
│       ├── go_board.dart            # Go board rendering
│       ├── result_buttons.dart      # Basic result buttons
│       ├── context_aware_result_buttons.dart # Smart result buttons
│       ├── game_status_bar.dart     # Status information
│       └── dataset_selector.dart    # Dataset selection widget
├── assets/                          # Bundled datasets
├── test/                           # Unit tests
├── web/                            # Web platform files
├── linux/                          # Linux desktop files
└── pubspec.yaml                    # Dependencies
```

## Data Integration

The app supports multiple ways to load Go position datasets:

### Built-in Datasets
- Pre-bundled datasets are included in `assets/`
- Currently includes 9x9 final positions and 19x19 midgame positions

### Custom Dataset Loading
1. Use the file picker in the Settings screen
2. Select JSON files matching the schema in `../data/schemas/dataset.json`
3. Datasets are automatically validated and loaded

### Dataset Schema
Datasets must follow the JSON schema defined in `../data/schemas/`:
- `dataset.json` - Main dataset structure
- `compact-position.json` - Individual position format

### Supported Dataset Types
- `final-9x9-area` - Final positions on 9x9 board (KataGo ownership)
- `final-19x19-area` - Final positions on 19x19 board (KataGo ownership)
- `midgame-19x19-estimation` - Midgame positions with territory estimation
- `final-9x9-area-vars` - 9x9 final positions with variations (planned)
- `partial-area` - Partial area analysis (planned)

## Controls

### Mouse/Touch
- **Result Buttons**: Click the appropriate button based on your prediction
- **Settings Button**: Top-right gear icon to access settings
- **Refresh FAB**: Floating action button to load next position

### Keyboard Shortcuts
- **← Left Arrow**: Select White Wins
- **↓ Down Arrow**: Select Draw/Tie
- **→ Right Arrow**: Select Black Wins

### Configurable Options
- **Timer Duration**: Per-dataset customizable (default varies by type)
- **Scoring Thresholds**: Configure what constitutes a "close" vs "decisive" win
- **Display Duration**: How long to show the correct answer
- **Dataset Selection**: Switch between different training datasets

## Deployment

### Web
```bash
flutter build web
# Deploy dist files from build/web/
```

### Android
```bash
flutter build apk --release
# APK available in build/app/outputs/flutter-apk/
```

## Advanced Features

### Configuration System
Each dataset type can have custom configuration:
- Timer duration for each problem
- Scoring thresholds (when is a game "close" vs decisive)
- Mark display time after answering
- Advanced scoring rules per dataset type

### Dataset Information
View detailed statistics about loaded datasets:
- Total number of positions
- Dataset version and creation date
- Source information
- Position distribution and metadata

## Extending the App

### Adding New Dataset Types
1. Add the new type to `DatasetType` enum in `lib/models/dataset_type.dart`
2. Update the schema in `../data/schemas/dataset.json`
3. Add appropriate configuration defaults in `DatasetConfiguration`
4. Handle the new type in result generation logic