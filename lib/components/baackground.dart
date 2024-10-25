// background.dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Background extends SpriteComponent with HasGameReference {
  Background() : super(size: Vector2.zero());

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('background.png');
    // 크기는 onGameResize에서 설정
    anchor = Anchor.topLeft; // 기본 위치 설정
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size; // 게임 크기에 맞춤
  }
}
