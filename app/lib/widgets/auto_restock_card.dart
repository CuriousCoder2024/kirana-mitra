import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/data_providers.dart';
import '../state/shop_settings.dart';
import '../theme/theme.dart';
import 'km_button.dart';
import 'top_toast.dart';

/// Settings card: "Auto-restock top sellers" switch + distributor phone,
/// saved through PATCH /shops/{shop_id}.
class AutoRestockCard extends ConsumerStatefulWidget {
  const AutoRestockCard({super.key});

  @override
  ConsumerState<AutoRestockCard> createState() => _AutoRestockCardState();
}

class _AutoRestockCardState extends ConsumerState<AutoRestockCard> {
  late final TextEditingController _phone = TextEditingController(text: ref.read(shopSettingsProvider).distributorPhone);
  bool? _auto;
  bool _saving = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final auto = _auto ?? ref.read(shopSettingsProvider).autoRestock;
    setState(() => _saving = true);
    try {
      await ref.read(shopSettingsProvider.notifier).save(autoRestock: auto, distributorPhone: _phone.text.trim());
      ref.invalidate(ordersProvider);
      if (mounted) TopToast.show(context, l.settingsSaved);
    } on ApiException catch (e) {
      if (mounted) TopToast.show(context, e.isNetwork ? l.networkError : e.message);
    } catch (_) {
      if (mounted) TopToast.show(context, l.networkError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(shopSettingsProvider);
    final auto = _auto ?? settings.autoRestock;
    return Container(
      padding: const EdgeInsets.all(KmSpace.card),
      decoration: BoxDecoration(
        color: KmColors.paper,
        borderRadius: BorderRadius.circular(KmRadius.card),
        border: Border.all(color: KmColors.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.autorenew_rounded, size: 26, color: KmColors.saffron),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.autoRestockTitle, style: KmText.bodyBold),
                    Text(l.autoRestockSubtitle, style: KmText.caption14),
                  ],
                ),
              ),
              Switch(
                value: auto,
                activeThumbColor: KmColors.white,
                activeTrackColor: KmColors.leaf,
                onChanged: _saving ? null : (v) => setState(() => _auto = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            style: KmText.body,
            decoration: InputDecoration(
              labelText: l.distributorPhoneLabel,
              hintText: l.distributorPhoneHint,
              prefixIcon: const Icon(Icons.phone_outlined, size: 24),
            ),
          ),
          const SizedBox(height: 12),
          KmButton(
            variant: KmButtonVariant.outline,
            size: KmButtonSize.small,
            icon: Icons.save_outlined,
            label: l.save,
            block: true,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
