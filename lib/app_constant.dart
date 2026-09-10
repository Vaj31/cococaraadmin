import 'package:intl/intl.dart' show DateFormat;

final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
final DateFormat timeFormatter = DateFormat('jms');
final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy hh:mm a');

class AppDateFormatter {
  static const String dateFormat = 'dd/MM/yyyy';
  static const String placeholder = 'dd/mm/yyyy';
  static final DateFormat date = DateFormat('dd/MM/yyyy');
  static final DateFormat dateTime = DateFormat('dd/MM/yyyy hh:mm a');

  static String formatDate(DateTime? dt, {String fallback = 'dd/mm/yyyy'}) {
    if (dt == null) return fallback;
    return date.format(dt);
  }

  static String formatDateTime(DateTime? dt, {String fallback = 'dd/mm/yyyy --:-- --'}) {
    if (dt == null) return fallback;
    return dateTime.format(dt);
  }
}


