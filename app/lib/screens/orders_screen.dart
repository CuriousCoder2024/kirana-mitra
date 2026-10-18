import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/chat_controller.dart';
import '../state/data_providers.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import '../widgets/async_body.dart';
import '../widgets/km_app_bar.dart';
import '../widgets/km_badge.dart';
import '../widgets/km_button.dart';
import '../widgets/tab_scaffold.dart';

/// GET /orders/{shop_id}: newest first, WhatsApp share per order, Undo on
/// placed auto orders (POST /undo with the order's message_id).
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final orders = ref.watch(ordersProvider);
    final busy = ref.watch(chatControllerProvider.select((s) => s.busy));
    return TabScaffold(
      showFab: false,
      appBar: KmAppBar(title: l.ordersTitle, onBack: () => context.go('/forecast')),
      body: AsyncBody<OrdersResponse>(
        value: orders,
        onRefresh: () => ref.refresh(ordersProvider.future),
        builder: (data) {
          if (data.orders.isEmpty) return EmptyHint(text: l.ordersEmpty, icon: Icons.receipt_long_outlined);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 12, KmSpace.gutter, 40),
            itemCount: data.orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: KmSpace.cardGap),
            itemBuilder: (context, i) => _OrderCard(
              order: data.orders[i],
              busy: busy,
              onUndo: data.orders[i].messageId == null
                  ? null
                  : () => ref.read(chatControllerProvider.notifier).undo(data.orders[i].messageId!),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.busy, required this.onUndo});

  final Order order;
  final bool busy;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final at = Fmt.parse(order.createdAt);
    final cancelled = !order.isPlaced;
    return Opacity(
      opacity: cancelled ? 0.6 : 1,
      child: Container(
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
                Icon(order.isAuto ? Icons.autorenew_rounded : Icons.shopping_cart_checkout_rounded, size: 22, color: KmColors.saffron),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    at == null ? order.orderId : '${Fmt.dateShort(at)} · ${Fmt.time(at)}',
                    style: KmText.bodyBold,
                  ),
                ),
                KmBadge(
                  variant: cancelled ? KmBadgeVariant.warn : KmBadgeVariant.ok,
                  label: cancelled ? l.orderCancelled : (order.isAuto ? l.orderAuto : l.orderManual),
                  inRow: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final line in order.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(line.name, style: KmText.body)),
                    Text('${Fmt.qty(line.qty)} ${line.unit}', style: KmText.numberS.copyWith(fontSize: 20)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: KmButton(
                    variant: KmButtonVariant.whatsapp,
                    size: KmButtonSize.small,
                    label: l.shareWhatsapp,
                    block: true,
                    onPressed: order.whatsappUrl.isEmpty || cancelled
                        ? null
                        : () => launchUrl(Uri.parse(order.whatsappUrl), mode: LaunchMode.externalApplication),
                  ),
                ),
                if (order.isAuto && order.isPlaced && onUndo != null) ...[
                  const SizedBox(width: 10),
                  KmButton.undo(label: l.undo, onPressed: busy ? null : onUndo),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
