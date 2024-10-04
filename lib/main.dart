import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: DirectionalImageGame()));
}

class DirectionalImageGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void> onLoad() async {
    player = Player();
    add(player);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startDrag(info.eventPosition.global);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.updateDrag(info.delta.global);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.endDrag();
  }
}


class Player extends SpriteComponent with HasGameReference<DirectionalImageGame> {
  late Sprite image1;
  late Sprite image2;
  late Sprite image3;
  late Sprite image4;

  Vector2 startDragPosition = Vector2.zero();
  Vector2 totalDelta = Vector2.zero();
  int dragCount = 0;

  // HP 추가
  int hp = 5;

  Player() : super(size: Vector2(100, 150), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadSprites();
    position = (game.size / 2) - (size / 2);
    sprite = image1;
  }

  Future<void> loadSprites() async {
    try {
      image1 = await game.loadSprite('bullet.png');
      image2 = await game.loadSprite('enemy.png');
      image3 = await game.loadSprite('player_sprite.png');
      image4 = await game.loadSprite('star_0.png');
    } catch (e) {
      print('Error loading sprites: $e');
    }
  }

  void startDrag(Vector2 position) {
    startDragPosition = position;
    totalDelta = Vector2.zero();
    dragCount = 0;
  }

  void updateDrag(Vector2 delta) {
    totalDelta.add(delta);
    dragCount++;
  }

  void endDrag() {
    if (dragCount > 0) {
      Vector2 averageDelta = totalDelta / dragCount.toDouble();
      double slope = averageDelta.y / averageDelta.x;

      if (averageDelta.x.abs() > averageDelta.y.abs()) {
        if (averageDelta.x < 0) {
          sprite = image3; // 왼쪽
        } else {
          sprite = image4; // 오른쪽
        }
      } else {
        if (averageDelta.y < 0) {
          sprite = image1; // 위
        } else {
          sprite = image2; // 아래
        }
      }
    }
  }

  // HP를 감소시키는 메서드
  void takeDamage() {
    if (hp > 0) {
      hp--;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // HP 표시
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'HP: $hp',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, game.size.y - 30)); // 왼쪽 아래에 위치
  }
}
