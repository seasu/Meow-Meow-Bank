import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static AudioPlayer? _player;

  static AudioPlayer get _p {
    _player ??= AudioPlayer();
    return _player!;
  }

  static Future<void> playCoinDrop() async {
    try {
      await _p.play(AssetSource('sounds/coin_drop.mp3'), volume: 0.7);
    } catch (_) {}
  }
}
