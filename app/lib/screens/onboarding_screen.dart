import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/api_client.dart';
import '../api/api_provider.dart';
import '../models/models.dart';
import '../l10n/app_localizations.dart';
import '../settings/server_settings.dart';
import '../state/shop_prefs.dart';
import '../theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  final _shop = TextEditingController();
  final _owner = TextEditingController();
  String _language = 'hi-Latn';
  bool _saving = false;
  String? _notice;

  @override
  void dispose() {
    _shop.dispose();
    _owner.dispose();
    super.dispose();
  }

  Future<Shop> _createShop(ApiClient api) => api.createShop(
        shopName: _shop.text.trim(),
        ownerName: _owner.text.trim(),
        language: _language,
      );

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _notice = null;
    });
    final l = AppLocalizations.of(context);
    try {
      final shop = await _createShop(ref.read(apiClientProvider)).catchError((Object e) {
        // Backend went away after the health check: switch the whole app to
        // the mock so the demo still proceeds consistently.
        ref.read(forceMockProvider.notifier).enable();
        setState(() => _notice = l.couldNotCreateShop);
        return _createShop(ref.read(apiClientProvider));
      });
      await ref.read(shopPrefsProvider.notifier).setShop(shop);
      if (mounted) context.go('/chat');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: KmColors.saffron,
                    child: Icon(Icons.storefront_rounded, size: 44, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  // Long-press the title to open the Server sheet (lib/settings).
                  onLongPress: () => showServerSettingsSheet(context),
                  child: Text(l.appTitle, style: text.displaySmall, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 8),
                Text(l.onboardingTitle, style: text.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(l.onboardingSubtitle, style: text.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _shop,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 19),
                        decoration: InputDecoration(
                          labelText: l.shopNameLabel,
                          hintText: l.shopNameHint,
                          prefixIcon: const Icon(Icons.store_outlined),
                        ),
                        validator: (v) => (v ?? '').trim().isEmpty ? l.requiredField : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _owner,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 19),
                        decoration: InputDecoration(
                          labelText: l.ownerNameLabel,
                          hintText: l.ownerNameHint,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v ?? '').trim().isEmpty ? l.requiredField : null,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 24),
                      Text(l.languageLabel, style: text.titleMedium),
                      const SizedBox(height: 10),
                      _LanguagePicker(
                        value: _language,
                        onChanged: (v) => setState(() => _language = v),
                        hindi: l.langHindi,
                        english: l.langEnglish,
                        hinglish: l.langHinglish,
                      ),
                      if (_notice != null) ...[
                        const SizedBox(height: 16),
                        Text(_notice!, style: text.bodySmall?.copyWith(color: KmColors.terracotta)),
                      ],
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: _saving ? null : _submit,
                        icon: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Icon(Icons.arrow_forward_rounded),
                        label: Text(l.startButton),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.value,
    required this.onChanged,
    required this.hindi,
    required this.english,
    required this.hinglish,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hindi;
  final String english;
  final String hinglish;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('hi', hindi, 'नमस्ते'),
      ('hi-Latn', hinglish, 'Namaste'),
      ('en', english, 'Hello'),
    ];
    return Row(
      children: [
        for (final (code, label, sample) in options) ...[
          Expanded(
            child: Material(
              color: value == code ? KmColors.userBubble : Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onChanged(code),
                child: Container(
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: value == code ? KmColors.saffron : KmColors.creamDark,
                      width: value == code ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sample, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: KmColors.brown)),
                      const SizedBox(height: 4),
                      Text(label, style: const TextStyle(fontSize: 14, color: KmColors.brownSoft)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (code != 'en') const SizedBox(width: 10),
        ],
      ],
    );
  }
}
