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
  late Background background;

  @override
  Future<void> onLoad() async {
    background = Background(); // 배경 인스턴스 생성
    add(background); // 배경 추가
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

  int hp = 5;

  Player() : super(size: Vector2(100, 150), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadSprites();
    // 플레이어의 크기를 게임 화면 높이의 3/2로 설정
    size = Vector2(size.x * (game.size.y/size.y) * (1/3), game.size.y * (1 / 3));

    // 화면의 가운데 맨 아래로 위치 설정
    position = Vector2((game.size.x / 2) - (size.x / 2), (game.size.y/2) - (size.y/2));
    sprite = image1;
  }

  Future<void> loadSprites() async {
    try {
      image1 = await game.loadSprite('character.png');
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

      if (averageDelta.x.abs() > averageDelta.y.abs()) {
        sprite = averageDelta.x < 0 ? image3 : image4; // 왼쪽 또는 오른쪽
      } else {
        sprite = averageDelta.y < 0 ? image1 : image2; // 위 또는 아래
      }
    }
  }

  void takeDamage() {
    if (hp > 0) {
      hp--;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'HP: $hp',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, game.size.y - 30));
  }
}

class Background extends SpriteComponent with HasGameReference<DirectionalImageGame> {
  Background() : super(size: Vector2.zero());

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('background.png');
    size = game.size; // 게임 크기에 맞춤
    anchor = Anchor.topLeft; // 기본 위치 설정
  }
}
