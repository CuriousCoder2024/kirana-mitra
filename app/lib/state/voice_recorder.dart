import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../api/api_client.dart';

/// Thin wrapper over the `record` package. Produces m4a/aac on Android and
/// webm/opus on the web (Chrome's MediaRecorder cannot encode AAC); both are
/// accepted by POST /voice-note.
class VoiceRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  DateTime? _startedAt;

  bool get isRecording => _startedAt != null;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start() async {
    final String path;
    final AudioEncoder encoder;
    if (kIsWeb) {
      path = 'voice-note';
      encoder = AudioEncoder.opus;
    } else {
      final dir = await getTemporaryDirectory();
      path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      encoder = AudioEncoder.aacLc;
    }
    await _recorder.start(
      RecordConfig(
        encoder: encoder,
        bitRate: 64000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
    _startedAt = DateTime.now();
  }

  Duration get elapsed =>
      _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);

  /// Stops and returns the bytes, or null when nothing usable was recorded.
  Future<UploadBlob?> stop() async {
    _startedAt = null;
    final path = await _recorder.stop();
    if (path == null || path.isEmpty) return null;
    final bytes = await XFile(path).readAsBytes();
    if (bytes.isEmpty) return null;
    return kIsWeb
        ? UploadBlob(bytes: bytes, filename: 'note.webm', mimeType: 'audio/webm')
        : UploadBlob(bytes: bytes, filename: 'note.m4a', mimeType: 'audio/m4a');
  }

  Future<void> cancel() async {
    _startedAt = null;
    await _recorder.cancel();
  }

  void dispose() => _recorder.dispose();
}
