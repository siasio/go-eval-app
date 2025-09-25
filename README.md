# Go Territory Trainer - Flutter App

Cross-platform mobile and web application for training Go territory counting skills.

## Features

- **Animated Timer Bar**: Visual countdown with color changes (green → orange → red)
- **Interactive Go Board**: Beautiful 19×19 board with realistic stone rendering
- **Quick Selection**: Three buttons for White Wins, Draw, or Black Wins
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
│   ├── main.dart              # App entry point
│   ├── models/
│   │   └── go_position.dart   # Go board position data model
│   ├── screens/
│   │   └── training_screen.dart # Main game screen
│   └── widgets/
│       ├── timer_bar.dart     # Animated countdown timer
│       ├── go_board.dart      # Go board rendering
│       └── result_buttons.dart # Selection buttons
├── web/                       # Web platform files
├── linux/                     # Linux desktop files
└── pubspec.yaml              # Dependencies
```

## Data Integration

The app loads position data from `../data/positions/` in JSON format. Position files must match the schema defined in `../data/schemas/compact-position.json`.

### Loading Custom Positions

1. Place JSON position files in `../data/positions/`
2. Update the app's data loading logic in `lib/models/`
3. Hot reload to see new positions

## Controls

- **Timer**: Configurable countdown (default: 30 seconds)
- **White Button**: Select if White has more territory
- **Draw Button**: Select if the position is roughly equal
- **Black Button**: Select if Black has more territory
- **Refresh FAB**: Reset to new position

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

## Next Steps

- Integrate real position data from data pipeline
- Add scoring feedback and statistics
- Add user progress tracking