import 'dart:typed_data';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static AudioPlayer? _player;

  static AudioPlayer get _p {
    _player ??= AudioPlayer();
    return _player!;
  }

  static Future<void> playCoinDrop() async {
    try {
      final wav = _generateCashRegisterSound();
      await _p.play(BytesSource(wav), volume: 0.6);
    } catch (_) {}
  }

  static Future<void> playMeow() async {
    try {
      final wav = _generateMeowSound();
      await _p.play(BytesSource(wav), volume: 0.4);
    } catch (_) {}
  }

  /// Cash register "ka-ching!" sound
  static Uint8List _generateCashRegisterSound() {
    const sampleRate = 22050;
    const duration = 0.55;
    final numSamples = (sampleRate * duration).toInt();
    final samples = Float64List(numSamples);

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double v = 0;

      // Phase 1: mechanical click (0-0.05s)
      if (t < 0.05) {
        final clickEnv = (1.0 - t / 0.05);
        v += clickEnv * 0.4 * sin(2 * pi * 120 * t);
        v += clickEnv * 0.3 * (Random().nextDouble() * 2 - 1);
      }

      // Phase 2: drawer slide metallic noise (0.03-0.12s)
      if (t >= 0.03 && t < 0.12) {
        final slideT = (t - 0.03) / 0.09;
        final slideEnv = sin(pi * slideT) * 0.3;
        v += slideEnv * sin(2 * pi * 280 * t);
        v += slideEnv * 0.5 * sin(2 * pi * 560 * t);
      }

      // Phase 3: bell ring "ching!" (0.08-0.55s)
      if (t >= 0.08) {
        final bellT = t - 0.08;
        final bellEnv = exp(-bellT * 6) * 0.7;
        v += bellEnv * sin(2 * pi * 2200 * t);
        v += bellEnv * 0.6 * sin(2 * pi * 3300 * t);
        v += bellEnv * 0.3 * sin(2 * pi * 4400 * t);
        v += bellEnv * 0.15 * sin(2 * pi * 5500 * t);
      }

      // Phase 4: secondary bell shimmer (0.15-0.55s)
      if (t >= 0.15) {
        final shimT = t - 0.15;
        final shimEnv = exp(-shimT * 8) * 0.35;
        v += shimEnv * sin(2 * pi * 2600 * t);
        v += shimEnv * 0.5 * sin(2 * pi * 3900 * t);
      }

      samples[i] = v.clamp(-1.0, 1.0);
    }

    return _samplesToWav(samples, sampleRate);
  }

  static Uint8List _generateMeowSound() {
    const sampleRate = 22050;
    const duration = 0.4;
    final numSamples = (sampleRate * duration).toInt();
    final samples = Float64List(numSamples);

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = sin(pi * t / duration) * 0.6;
      final freq = 600 + 200 * sin(2 * pi * 3 * t);
      samples[i] = env * sin(2 * pi * freq * t);
    }

    return _samplesToWav(samples, sampleRate);
  }

  static Uint8List _samplesToWav(Float64List samples, int sampleRate) {
    final numSamples = samples.length;
    final dataSize = numSamples * 2;
    final fileSize = 44 + dataSize;
    final buf = ByteData(fileSize);

    void writeString(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        buf.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    buf.setUint32(4, fileSize - 8, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    buf.setUint32(16, 16, Endian.little);
    buf.setUint16(20, 1, Endian.little);
    buf.setUint16(22, 1, Endian.little);
    buf.setUint32(24, sampleRate, Endian.little);
    buf.setUint32(28, sampleRate * 2, Endian.little);
    buf.setUint16(32, 2, Endian.little);
    buf.setUint16(34, 16, Endian.little);
    writeString(36, 'data');
    buf.setUint32(40, dataSize, Endian.little);

    for (var i = 0; i < numSamples; i++) {
      final s = (samples[i].clamp(-1.0, 1.0) * 32767).toInt();
      buf.setInt16(44 + i * 2, s, Endian.little);
    }

    return buf.buffer.asUint8List();
  }
}
