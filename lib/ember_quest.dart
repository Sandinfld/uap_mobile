// ember_quest.dart

import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'actors/ember.dart';
import 'overlays/main_menu.dart';
import 'overlays/game_over.dart';

// Tambahkan import untuk auth.dart
import 'auth.dart';

class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  EmberQuestGame();

  late EmberPlayer _ember;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

  int starsCollected = 0;
  int health = 3;
  double cloudSpeed = 0.0;
  double objectSpeed = 0.0;

  // Tambahkan properti isLoggedIn
  bool isLoggedIn = false;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
    ]);
    camera.viewfinder.anchor = Anchor.topLeft;

    // Tambahkan logika pengecekan login di sini jika diperlukan

    initializeGame(loadHud: true);
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    } else {
      // Jika belum login, tampilkan layar login
      if (!isLoggedIn) {
        overlays.add('MainMenu');
      }
    }
    super.update(dt);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    // Implementasikan seperti sebelumnya
  }

  void initializeGame({required bool loadHud}) {
    // Implementasikan seperti sebelumnya
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(loadHud: false);
  }
}
