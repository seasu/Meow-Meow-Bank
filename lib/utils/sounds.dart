import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final _player = AudioPlayer();

  static Future<void> playCoin() async {
    await _player.play(AssetSource(''), volume: 0);
  }
}
