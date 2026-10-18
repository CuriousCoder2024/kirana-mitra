import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/api_client.dart';
import '../api/api_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/shop_prefs.dart';
import '../theme/theme.dart';
import '../widgets/km_button.dart';
import '../widgets/lang_chip.dart';
import '../widgets/logo_mark.dart';

/// Set when onboarding fell back to the mock so the chat can say so in a
/// bot bubble (handoff §5.1).
final demoNoticePendingProvider = NotifierProvider<_DemoNotice, bool>(_DemoNotice.new);

class _DemoNotice extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool v) => state = v;
}

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
    setState(() => _saving = true);
    try {
      final shop = await _createShop(ref.read(apiClientProvider)).catchError((Object e) {
        // Backend went away after the health check: switch the whole app to
        // the mock so the demo still proceeds consistently.
        ref.read(forceMockProvider.notifier).enable();
        ref.read(demoNoticePendingProvider.notifier).set(true);
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _form,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 28, KmSpace.gutter, KmSpace.gutter),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: LogoMark(size: 84)),
                        const SizedBox(height: 14),
                        Text(l.appTitle, style: KmText.display, textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text(l.tagline, style: KmText.bodySemi.copyWith(color: KmColors.inkSoft), textAlign: TextAlign.center),
                        const SizedBox(height: 14),
                        _Field(
                          controller: _shop,
                          label: l.shopNameLabel,
                          hint: l.shopNameHint,
                          icon: Icons.storefront_outlined,
                          requiredText: l.fieldRequired,
                          action: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _owner,
                          label: l.ownerNameLabel,
                          hint: l.ownerNameHint,
                          icon: Icons.person_outline_rounded,
                          requiredText: l.fieldRequired,
                          action: TextInputAction.done,
                          onSubmitted: _submit,
                        ),
                        const SizedBox(height: KmSpace.section),
                        Text(l.languageQuestion.toUpperCase(), style: KmText.sectionLabel),
                        const SizedBox(height: 10),
                        LanguageOptions(value: _language, onChanged: (v) => setState(() => _language = v)),
                        const Spacer(),
                        const SizedBox(height: 12),
                        KmButton(
                          size: KmButtonSize.tall,
                          label: l.startButton,
                          trailingIcon: Icons.arrow_forward_rounded,
                          block: true,
                          loading: _saving,
                          onPressed: _saving ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Handoff §5.1 `KmField`: 60 dp, radius 16, 2 dp sand border, leading icon,
/// floating 13 sp label, 18 sp value; focused = saffron border.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.requiredText,
    required this.action,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String requiredText;
  final TextInputAction action;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: KmText.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 24, color: KmColors.inkSoft),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: (v) => (v ?? '').trim().isEmpty ? requiredText : null,
      textInputAction: action,
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
