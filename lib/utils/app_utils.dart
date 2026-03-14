import 'package:intl/intl.dart';

class AppUtils {
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  static String formatFullDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  static String cleanContent(String? content) {
    if (content == null || content.isEmpty) return '';
    // Remove the "[+XXXX chars]" suffix that NewsAPI adds
    final regex = RegExp(r'\s*\[?\+?\d+\s*chars?\]?$');
    return content.replaceAll(regex, '').trim();
  }

  static String getReadingTime(String? content, String? description) {
    final text = (content ?? '') + (description ?? '');
    if (text.isEmpty) return '';
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes min read';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
