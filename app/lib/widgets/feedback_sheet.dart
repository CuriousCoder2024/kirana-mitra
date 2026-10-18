import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_provider.dart';
import '../app_info.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/shop_prefs.dart';
import '../state/voice_recorder.dart';
import '../theme/theme.dart';
import 'km_button.dart';
import 'lang_chip.dart';
import 'mic.dart';
import 'top_toast.dart';

/// "Kirana Mitra kaisa chal raha hai?" — thumbs, optional text, optional
/// spoken comment. POST /feedback or multipart POST /feedback-voice.
Future<void> showFeedbackSheet(BuildContext context, {required String screen}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FeedbackSheet(screen: screen),
  );
}

class _FeedbackSheet extends ConsumerStatefulWidget {
  const _FeedbackSheet({required this.screen});

  final String screen;

  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  final _text = TextEditingController();
  final _recorder = VoiceRecorder();
  String? _rating;
  UploadBlob? _audio;
  Duration _audioLength = Duration.zero;
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<bool> _start() async {
    try {
      if (!await _recorder.hasPermission()) return false;
      await _recorder.start();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _stop(Duration elapsed) async {
    final blob = await (() async {
      try {
        return await _recorder.stop();
      } catch (_) {
        return null;
      }
    })();
    if (!mounted) return;
    if (blob == null || elapsed < const Duration(milliseconds: 600)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).voiceTooShort)));
      return;
    }
    setState(() {
      _audio = blob;
      _audioLength = elapsed;
    });
  }

  Future<void> _cancel() async => _recorder.cancel();

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final rating = _rating;
    if (rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.feedbackPickRating)));
      return;
    }
    setState(() => _sending = true);
    final api = ref.read(apiClientProvider);
    final shopId = ref.read(shopPrefsProvider).shopId ?? '';
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    try {
      final FeedbackReply reply;
      if (_audio != null) {
        reply = await api.feedbackVoice(
          shopId: shopId,
          screen: widget.screen,
          rating: rating,
          audio: _audio!,
          appVersion: kAppVersion,
          platform: kPlatformName,
        );
      } else {
        reply = await api.feedback(
          shopId: shopId,
          screen: widget.screen,
          rating: rating,
          comment: _text.text.trim().isEmpty ? null : _text.text.trim(),
          appVersion: kAppVersion,
          platform: kPlatformName,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      if (rootContext.mounted) {
        TopToast.show(rootContext, reply.replyText.isEmpty ? l.feedbackThanks : reply.replyText);
      }
    } on ApiException catch (e) {
      if (rootContext.mounted) TopToast.show(rootContext, e.isNetwork ? l.networkError : e.message);
    } catch (_) {
      if (rootContext.mounted) TopToast.show(rootContext, l.networkError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: 12),
              Text(l.feedbackTitle, style: KmText.sheetTitle),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _Thumb(up: true, label: l.feedbackUp, selected: _rating == 'up', onTap: () => setState(() => _rating = 'up'))),
                  const SizedBox(width: 12),
                  Expanded(child: _Thumb(up: false, label: l.feedbackDown, selected: _rating == 'down', onTap: () => setState(() => _rating = 'down'))),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _text,
                minLines: 1,
                maxLines: 3,
                style: KmText.body,
                decoration: InputDecoration(hintText: l.feedbackCommentHint),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  HoldToTalk(
                    onStart: _start,
                    onSend: _stop,
                    onCancel: _cancel,
                    builder: (context, state) => MicVisual(
                      state: state,
                      label: l.feedbackVoiceHint,
                      restSize: KmSize.micFab,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        return Text(
                          _audio == null
                              ? l.feedbackVoiceHint
                              : l.feedbackVoiceReady(_audioLength.inSeconds.toString()),
                          style: _audio == null ? KmText.caption : KmText.captionSemi.copyWith(color: KmColors.leaf),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              KmButton(
                icon: Icons.send_rounded,
                label: l.feedbackSend,
                block: true,
                loading: _sending,
                onPressed: _sending ? null : _submit,
              ),
              const SizedBox(height: 8),
              KmButton(
                variant: KmButtonVariant.ghost,
                icon: Icons.language_rounded,
                label: l.changeLanguage,
                onPressed: () {
                  Navigator.of(context).pop();
                  showLanguageSheet(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.up, required this.label, required this.selected, required this.onTap});

  final bool up;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = up ? KmColors.leaf : KmColors.terracotta;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: selected ? (up ? KmColors.leafTint : KmColors.mirchiTint) : KmColors.paper,
          borderRadius: BorderRadius.circular(KmRadius.button),
          border: Border.all(color: selected ? color : KmColors.sand, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(KmRadius.button),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(up ? Icons.thumb_up_rounded : Icons.thumb_down_rounded, size: 40, color: color),
                const SizedBox(height: 6),
                Text(label, style: KmText.bodyBold.copyWith(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
