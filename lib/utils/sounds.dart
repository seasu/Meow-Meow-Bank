import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static AudioPlayer? _savePlayer;
  static AudioPlayer? _spendPlayer;

  static Future<void> playCoinDrop() async {
    try {
      _savePlayer ??= AudioPlayer();
      await _savePlayer!.play(AssetSource('sounds/coin_drop.mp3'), volume: 0.7);
    } catch (_) {}
  }

  static Future<void> playSpendMoney() async {
    try {
      _spendPlayer ??= AudioPlayer();
      await _spendPlayer!.play(AssetSource('sounds/spend_money.mp3'), volume: 0.7);
    } catch (_) {}
  }
}
