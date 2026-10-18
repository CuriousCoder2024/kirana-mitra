import 'package:intl/intl.dart';

/// Number and date formatting per handoff §6: Indian grouping, no decimals,
/// "Sat 18 Oct", "7:41 pm".
abstract final class Fmt {
  static final _rupee = NumberFormat('#,##,###', 'en_IN');

  static String rupee(num v) => '₹${_rupee.format(v.round())}';

  static String int(num v) => _rupee.format(v.round());

  static String qty(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

  static String dateShort(DateTime d) => DateFormat('EEE d MMM').format(d);

  static String dayMonth(DateTime d) => DateFormat('d MMM').format(d);

  static String time(DateTime d) => DateFormat('h:mm a').format(d).toLowerCase();

  static String timer(Duration d) {
    final s = d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  static DateTime? parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
