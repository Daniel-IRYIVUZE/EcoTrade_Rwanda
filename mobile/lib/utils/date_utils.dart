import 'package:intl/intl.dart';

class AppDateUtils {
  static String format(DateTime date, {String pattern = 'dd MMM yyyy'}) =>
      DateFormat(pattern).format(date);

  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);

  static String formatDateTime(DateTime date) => DateFormat('dd MMM yyyy, hh:mm a').format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
