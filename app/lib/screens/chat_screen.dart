import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_client.dart';
import '../api/api_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/chat_controller.dart';
import '../state/shop_prefs.dart';
import '../state/voice_recorder.dart';
import '../theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/mic_button.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _recorder = VoiceRecorder();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      final prefs = ref.read(shopPrefsProvider);
      final name = prefs.ownerName.isEmpty ? 'ji' : prefs.ownerName.split(' ').first;
      final ctrl = ref.read(chatControllerProvider.notifier)
        ..networkErrorText = l.networkError
        ..comingSoonText = l.comingSoon;
      ctrl.addWelcome(
        prefs.language == 'hi-Latn' ? l.welcomeMessageHinglish(name) : l.welcomeMessage(name),
      );
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<void> _sendText() async {
    final t = _text.text;
    _text.clear();
    await ref.read(chatControllerProvider.notifier).sendText(t);
  }

  Future<bool> _startRecording() async {
    final l = AppLocalizations.of(context);
    try {
      if (!await _recorder.hasPermission()) {
        _snack(l.micPermissionDenied);
        return false;
      }
      await _recorder.start();
      return true;
    } catch (_) {
      _snack(l.micPermissionDenied);
      return false;
    }
  }

  Future<void> _stopRecording() async {
    final l = AppLocalizations.of(context);
    final tooShort = _recorder.elapsed < const Duration(milliseconds: 600);
    UploadBlob? blob;
    try {
      blob = await _recorder.stop();
    } catch (_) {
      blob = null;
    }
    if (tooShort || blob == null) {
      _snack(l.voiceTooShort);
      return;
    }
    await ref
        .read(chatControllerProvider.notifier)
        .sendVoice(blob, placeholder: l.voiceNoteSent);
  }

  Future<void> _cancelRecording() async {
    final l = AppLocalizations.of(context);
    await _recorder.cancel();
    _snack(l.recordingCancelled);
  }

  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mime = file.mimeType ?? (file.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
    await ref.read(chatControllerProvider.notifier).sendImage(
          UploadBlob(bytes: bytes, filename: file.name.isEmpty ? 'shelf.jpg' : file.name, mimeType: mime),
          placeholder: l.photoSent,
        );
  }

  Future<void> _onAction(ChatMessage from, QuickAction a) async {
    final effect = await ref.read(chatControllerProvider.notifier).tapAction(from, a);
    if (!mounted || effect == null) return;
    switch (effect) {
      case NavigateEffect(:final route):
        context.go(route);
      case OpenUrlEffect(:final url):
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _changeShop() async {
    await ref.read(shopPrefsProvider.notifier).reset();
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(chatControllerProvider);
    final demo = ref.watch(isDemoModeProvider);
    final prefs = ref.watch(shopPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.chatTitle),
            if (prefs.shopName.isNotEmpty)
              Text(prefs.shopName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
          ],
        ),
        actions: [
          if (demo)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text(l.demoMode, style: const TextStyle(fontSize: 13, color: KmColors.brown)),
                backgroundColor: KmColors.cream,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              ),
            ),
          PopupMenuButton<String>(
            iconSize: 28,
            onSelected: (v) {
              if (v == 'change') _changeShop();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'change', child: Text(l.changeShop)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.messages.length + (state.busy ? 1 : 0),
              itemBuilder: (context, i) {
                if (state.busy && i == 0) return TypingIndicator(label: l.thinking);
                final idx = state.messages.length - 1 - (state.busy ? i - 1 : i);
                final m = state.messages[idx];
                return MessageBubble(message: m, onAction: (a) => _onAction(m, a));
              },
            ),
          ),
          _Composer(
            controller: _text,
            hint: l.typeMessageHint,
            sendLabel: l.send,
            busy: state.busy,
            onSend: _sendText,
            onPhoto: _pickPhoto,
            mic: MicButton(
              enabled: !state.busy,
              onStart: _startRecording,
              onStop: _stopRecording,
              onCancel: _cancelRecording,
              holdLabel: l.holdToTalk,
              recordingLabel: l.recording,
              cancelLabel: l.slideToCancel,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hint,
    required this.sendLabel,
    required this.busy,
    required this.onSend,
    required this.onPhoto,
    required this.mic,
  });

  final TextEditingController controller;
  final String hint;
  final String sendLabel;
  final bool busy;
  final VoidCallback onSend;
  final VoidCallback onPhoto;
  final Widget mic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: KmColors.brown.withValues(alpha: 0.15),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: busy ? null : onPhoto,
                    iconSize: 30,
                    color: KmColors.terracotta,
                    constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                    icon: const Icon(Icons.photo_camera_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: hint,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        fillColor: KmColors.cream,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: busy ? null : onSend,
                    iconSize: 26,
                    tooltip: sendLabel,
                    constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              mic,
            ],
          ),
        ),
      ),
    );
  }
}
