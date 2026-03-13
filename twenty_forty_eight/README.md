# 2048 (Flutter)

A mobile implementation of the **2048** game built with Flutter.

## Implemented Features

- **4x4** board.
- **3–4** random tiles at game start.
- New tiles have values **2** or **4**.
- Movement in all 4 directions (swipes + control buttons).
- Merge of equal tiles with doubled value.
- Current score (**Score**) and best score (**Best**) tracking.
- Best score persistence via `SharedPreferences`.
- Movement/merge/spawn animations.
- `Game Over` dialog + game restart.

## Controls

- **Swipe** on the board (up/down/left/right).
- Use the **D-pad buttons** below the board.
- Use **Restart** from the AppBar.

## Quick Start

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run the app

```bash
flutter run
```

> If needed, select a device/emulator with `flutter devices`.

## Project Structure

- `lib/game_board.dart` — game logic (move, merge, spawn, game over).
- `lib/main.dart` — UI, animations, gesture/button handling, best score.

## Known Limitations

- Board size is currently fixed to 4x4.
- No dedicated difficulty levels yet.
- No sound effects.
