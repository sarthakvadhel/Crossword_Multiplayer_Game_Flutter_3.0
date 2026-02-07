# Crossword Master

A **crossword multiplayer style word game** built with Flutter for iOS and Android.

## Features

- **Turn-based crossword gameplay** — Place letters on a crossword board, earn points, and compete against a computer opponent
- **5-letter hand** — Each player holds 5 letters per turn with balanced vowel/consonant distribution
- **Smart AI opponent** — Moderately challenging computer player that varies its strategy
- **Scoring system** — Points for correct letters (+1), word completion (+word length), empty hand bonus (+5), and longest word bonus (+6)
- **Swap & Pass** — Exchange unwanted letters for new ones
- **Hint system** — Highlights valid placement positions on the board
- **Word clues** — View clues and completion patterns for all puzzle words
- **Celebration banners** — Animated rewards for achievements (streaks, word completion, bonuses)
- **Persistent progress** — Game state saved locally via SharedPreferences
- **Profile page** — Player stats, settings, and Google Sign-In structure

## Project Structure

```
lib/
├── core/                    # Constants, theme, utilities, services
│   ├── animations/          # Animation helpers
│   ├── constants/           # Game constants
│   ├── services/            # Storage, sound, banner, auth services
│   ├── theme/               # App theme and colors
│   └── utils/               # Helper utilities
├── data/
│   ├── models/              # Data models (tile, word, puzzle, player, game state)
│   └── repositories/        # Puzzle data, score tracking, AI config
├── game_engine/             # Core game logic
│   ├── ai_engine.dart       # AI opponent logic
│   ├── board_engine.dart    # Board state management
│   ├── letter_generator.dart # Letter generation
│   ├── move_validator.dart  # Move validation
│   ├── scoring_engine.dart  # Score calculation
│   └── turn_manager.dart    # Turn flow management
├── presentation/
│   ├── screens/             # Home, Game, Profile screens + popups
│   └── widgets/             # Reusable UI components
├── state/                   # Provider-based state management
└── main.dart                # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Setup

```bash
flutter pub get
flutter run
```

### Running Tests

```bash
flutter test
```

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Provider** — State management
- **SharedPreferences** — Local persistence
- **Google Sign-In** — Authentication (structure ready)

## Puzzle 1

The first puzzle is a 10×10 crossword grid with 5 interlocking words:

| # | Direction | Word  | Clue                   |
|---|-----------|-------|------------------------|
| 1 | Across    | FLAME | Fire's dancing light   |
| 2 | Across    | TORCH | Portable light source  |
| 3 | Across    | BREAD | Baked food staple      |
| 4 | Across    | SHINE | To glow brightly       |
| 5 | Down      | FLORA | Plant life             |

## Future Features (Structure Ready)

- Multiplayer with friends
- Ad integration
- Cloud save
- Leaderboard
- Additional puzzles