# MomoRun

A fast-paced infinite runner game for iOS with Apple Watch integration that serves as a motion controller.

## Project Overview

MomoRun is an endless runner where players navigate obstacles, collect items, and aim for high scores. What makes this game unique is its deep integration with Apple Watch, allowing players to control the game using wrist movements and gestures.

### Key Features

- **Endless Procedurally Generated Levels**: Never-ending, dynamically created gameplay
- **Apple Watch as Controller**: Use your watch as a motion controller with gesture recognition
- **Real-time Game Status on Watch**: View your score, health, and game stats on your wrist
- **Collectibles and Power-ups**: Gather items to boost your abilities and score
- **Leaderboards and Achievements**: Compete with friends and track your accomplishments

## Technical Architecture

The project is structured into three main components:

### iOS App
- Main game engine built with SpriteKit
- SwiftUI interface for menus and settings
- Game entity system with physics and collision handling
- Procedural level generation
- Watch connectivity management

### WatchOS App
- Motion and gesture recognition system
- Game controls interface
- Real-time game status display
- iOS device connectivity

### Shared Code
- Common models and data structures
- Shared utilities and constants
- Command type definitions for cross-device communication

## Getting Started

1. Clone the repository
2. Open the project in Xcode 15 or later
3. Build and run on an iOS device with a paired Apple Watch for the full experience

## Development

The project follows an organized structure:
- Game logic is contained in the `Game` directory
- UI/UX elements are in `Views`
- Watch-specific code is in the `MomoRun Watch App` directory
- Shared code used by both platforms is in the `Shared` directory

## Requirements

- iOS 17.0+
- watchOS 10.0+
- Xcode 15+
- Swift 5.9+ 