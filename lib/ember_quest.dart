import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'actors/ember.dart';
import 'actors/water_enemy.dart';
import 'managers/segment_manager.dart';
import 'objects/ground_block.dart';
import 'objects/platform_block.dart';
import 'objects/star.dart';
import 'overlays/hud.dart';

class EmberQuestGame extends FlameGame
    with 
    TapDetector,
    HasCollisionDetection, 
    HasKeyboardHandlerComponents {
  EmberQuestGame();

  late EmberPlayer _ember;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

  int starsCollected = 0;
  int health = 3;
  double cloudSpeed = 0.0;
  double objectSpeed = 0.0;

  late double leftButtonX;
  late double rightButtonX;
  late double jumpButtonX;
  late double buttonY;

  bool isLeftButtonPressed = false;
  bool isRightButtonPressed = false;
  bool isJumpButtonPressed = false;

  final Set<int> pressedButtons = {};

  @override
  Future<void> onLoad() async {
    //debugMode = true; // Uncomment to see the bounding boxes
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

    initializeGame(loadHud: true);

    // Set the positions of the buttons
    leftButtonX = 50;
    rightButtonX = 150;
    jumpButtonX = size.x - 150;
    buttonY = size.y - 100;

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    // Update button positions when the game is resized
    leftButtonX = 50;
    rightButtonX = 150;
    jumpButtonX = size.x - 150;
    buttonY = size.y - 100;
    super.onGameResize(size);
  }

  @override
  void render(Canvas canvas) {
    // Render buttons
    canvas.drawRect(
      Rect.fromPoints(Offset(leftButtonX, buttonY), Offset(leftButtonX + 50, buttonY + 50)),
      Paint()..color = Colors.blue,
    );
    drawIcon(canvas, Icons.arrow_back, leftButtonX + 5, buttonY + 5);
    
    canvas.drawRect(
      Rect.fromPoints(Offset(rightButtonX, buttonY), Offset(rightButtonX + 50, buttonY + 50)),
      Paint()..color = Colors.blue,
    );
    drawIcon(canvas, Icons.arrow_forward, rightButtonX + 5, buttonY + 5);

    canvas.drawRect(
      Rect.fromPoints(Offset(jumpButtonX, buttonY), Offset(jumpButtonX + 50, buttonY + 50)),
      Paint()..color = Colors.blue,
    );
    drawIcon(canvas, Icons.arrow_upward, jumpButtonX + 5, buttonY + 5);

    super.render(canvas);

    // Render buttons with icons
    drawButton(canvas, Icons.arrow_back, leftButtonX, buttonY);
    drawButton(canvas, Icons.arrow_forward, rightButtonX, buttonY);
    drawButton(canvas, Icons.arrow_upward, jumpButtonX, buttonY);
  }

  // Helper method to draw buttons with icons on the canvas
  void drawButton(Canvas canvas, IconData icon, double x, double y) {
    canvas.drawRect(
      Rect.fromPoints(Offset(x, y), Offset(x + 50, y + 50)),
      Paint()..color = Colors.blue,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontFamily: icon.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 5, y + 5));
  }

  // Helper method to draw icons on the canvas
  void drawIcon(Canvas canvas, IconData icon, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontFamily: icon.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  void handleTapDown(TapDownDetails details) {
    // Handle button presses
    if (Rect.fromPoints(Offset(leftButtonX, buttonY), Offset(leftButtonX + 50, buttonY + 50)).contains(details.globalPosition)) {
      // Left button pressed
      pressedButtons.add(1);
      _updateCharacterDirection();
    } else if (Rect.fromPoints(Offset(rightButtonX, buttonY), Offset(rightButtonX + 50, buttonY + 50)).contains(details.globalPosition)) {
      // Right button pressed
      pressedButtons.add(2);
      _updateCharacterDirection();
    } else if (Rect.fromPoints(Offset(jumpButtonX, buttonY), Offset(jumpButtonX + 50, buttonY + 50)).contains(details.globalPosition)) {
      // Jump button pressed
      pressedButtons.add(3);
      _ember.hasJumped = true;
    }
    super.handleTapDown(details);
  }

  @override
  void handleTapUp(TapUpDetails details) {
    // Handle button releases
    if (Rect.fromPoints(Offset(leftButtonX, buttonY), Offset(leftButtonX + 50, buttonY + 50)).contains(details.globalPosition)) {
      // Left button released
      pressedButtons.remove(1);
      _updateCharacterDirection();
    } else if (Rect.fromPoints(Offset(rightButtonX, buttonY), Offset(rightButtonX + 50, buttonY + 50)).contains(details.globalPosition)) {
      // Right button released
      pressedButtons.remove(2);
      _updateCharacterDirection();
    } else if (Rect.fromPoints(Offset(jumpButtonX, buttonY), Offset(jumpButtonX + 50, buttonY + 50)).contains(details.globalPosition)) {
      // Jump button released
      pressedButtons.remove(3);
      _ember.hasJumped = false;
    }

    super.handleTapUp(details);
  }

  // Update character direction based on currently pressed buttons
  void _updateCharacterDirection() {
    if (pressedButtons.contains(1) && pressedButtons.contains(2)) {
      // If both left and right buttons are pressed, stop the character
      _ember.horizontalDirection = 0;
    } else if (pressedButtons.contains(1)) {
      // If only left button is pressed, move left
      _ember.horizontalDirection = -1;
    } else if (pressedButtons.contains(2)) {
      // If only right button is pressed, move right
      _ember.horizontalDirection = 1;
    } else {
      // If no buttons are pressed, stop the character
      _ember.horizontalDirection = 0;
    }
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    }
    super.update(dt);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      switch (block.blockType) {
        case GroundBlock:
          world.add(
            GroundBlock(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
        case PlatformBlock:
          world.add(
            PlatformBlock(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
        case Star:
          world.add(
            Star(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
        case WaterEnemy:
          world.add(
            WaterEnemy(
              gridPosition: block.gridPosition,
              xOffset: xPositionOffset,
            ),
          );
          break;
      }
    }
  }

  void initializeGame({required bool loadHud}) {
    // Assume that size.x < 3200
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }

    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 128),
    );
    world.add(_ember);
    if (loadHud) {
      camera.viewport.add(Hud());
    }
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(loadHud: false);
  }
}
