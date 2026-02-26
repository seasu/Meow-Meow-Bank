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
      final wav = _generateCoinSound();
      await _p.play(BytesSource(wav), volume: 0.5);
    } catch (_) {}
  }

  static Future<void> playMeow() async {
    try {
      final wav = _generateMeowSound();
      await _p.play(BytesSource(wav), volume: 0.4);
    } catch (_) {}
  }

  static Uint8List _generateCoinSound() {
    const sampleRate = 22050;
    const duration = 0.25;
    final numSamples = (sampleRate * duration).toInt();
    final samples = Float64List(numSamples);

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = (1.0 - t / duration) * (1.0 - t / duration);
      final freq = 1200 + 1200 * (1.0 - t / duration);
      samples[i] = env * 0.5 * sin(2 * pi * freq * t);
      samples[i] += env * 0.3 * sin(2 * pi * freq * 2 * t);
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
