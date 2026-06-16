import 'package:intl/intl.dart';

const String dateFormatForTable = "dd-MM-yyyy hh:mm:ss a";
const String yyyymmdd = 'yyyy-MM-dd';
DateFormat yyyymmddFormat = DateFormat(yyyymmdd);

String formattedDate(dynamic date) {
  if (date == null) return '-';

  try {
    DateTime dateTime;

    if (date is DateTime) {
      dateTime = date;
    } else {
      // Try ISO first (fastest & most common)
      try {
        dateTime = DateTime.parse(date.toString());
      } catch (_) {
        // Fallback formats
        final formats = [
          'M/d/yyyy h:mm:ss a',
          'MM/dd/yyyy h:mm:ss a',
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-ddTHH:mm:ss.SSS',
          'dd-MM-yyyy HH:mm:ss',
          'dd/MM/yyyy HH:mm:ss',
        ];

        DateTime? parsed;

        for (var format in formats) {
          try {
            parsed = DateFormat(format).parse(date.toString());
            break;
          } catch (_) {}
        }

        if (parsed == null) return date.toString();
        dateTime = parsed;
      }
    }

    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  } catch (e) {
    return date.toString();
  }
}

String formattedOnlyDate(dynamic date) {
  if (date == null) return '-';

  try {
    DateTime dateTime;

    if (date is DateTime) {
      dateTime = date;
    } else {
      // Try ISO first (fastest & most common)
      try {
        dateTime = DateTime.parse(date.toString());
      } catch (_) {
        // Fallback formats
        final formats = ['M/d/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'yyyy-MM-ddT', 'yyyy-MM-ddT', 'dd-MM-yyyy', 'dd/MM/yyyy'];

        DateTime? parsed;

        for (var format in formats) {
          try {
            parsed = DateFormat(format).parse(date.toString());
            break;
          } catch (_) {}
        }

        if (parsed == null) return date.toString();
        dateTime = parsed;
      }
    }

    return DateFormat('yyyy-MM-dd').format(dateTime);
  } catch (e) {
    return date.toString();
  }
}

String formattedDateFromISO(String? isoString) {
  if (isoString == null || isoString.isEmpty) {
    return DateFormat("dd-MM-yyyy hh:mm:ss a").format(DateTime.now());
  }
  try {
    final dateTime = DateTime.parse(isoString).toLocal();
    final customFormat = DateFormat("dd/MM/yyyy hh:mm:ss a");
    return customFormat.format(dateTime);
  } catch (e) {
    return "Invalid date format";
  }
}

///
String formatUtcToLocal(String utcTimeString, {bool tommorow = false}) {
  final DateTime localTime = _convertIstToDeviceLocal(utcTimeString);
  DateTime now = DateTime.now();
  DateTime localDate = DateTime(localTime.year, localTime.month, localTime.day);
  DateTime nowDate = DateTime(now.year, now.month, now.day);
  int differenceInDays = localDate.difference(nowDate).inDays;
  String formattedTime;
  if (differenceInDays == 0) {
    if (localTime.isBefore(now) || localTime.isAtSameMomentAs(now)) {
      formattedTime = "In-Play";
    } else {
      formattedTime = "Today ${DateFormat.Hm().format(localTime)}";
    }
  } else if (differenceInDays == 1) {
    formattedTime = tommorow ? DateFormat.Hm().format(localTime) : 'Tomorrow ${DateFormat.Hm().format(localTime)}';
  } else {
    formattedTime = DateFormat.yMMMMd().add_jm().format(localTime);
  }
  return formattedTime;
}

String formatUpcomingEvents(String utcTimeString) {
  final DateTime localTime = _convertIstToDeviceLocal(utcTimeString);
  DateTime now = DateTime.now();

  DateTime localDate = DateTime(localTime.year, localTime.month, localTime.day);
  DateTime nowDate = DateTime(now.year, now.month, now.day);
  int differenceInDays = localDate.difference(nowDate).inDays;
  String formattedTime;
  if (differenceInDays == 0) {
    formattedTime = 'Today ${DateFormat.Hm().format(localTime)}';
  } else if (differenceInDays == 1) {
    formattedTime = 'Tomorrow ${DateFormat.Hm().format(localTime)}';
  } else {
    formattedTime = DateFormat.yMMMMd().add_jm().format(localTime);
  }
  return formattedTime;
}

DateTime _convertIstToDeviceLocal(String dateTimeString) {
  final parsed = DateTime.parse(dateTimeString);

  final hasTimezoneSuffix = dateTimeString.endsWith('Z') || dateTimeString.contains('+') || dateTimeString.contains('-', 10);
  final sourceUtc = hasTimezoneSuffix ? parsed : parsed.subtract(const Duration(hours: 5, minutes: 30));
  final deviceOffset = DateTime.now().timeZoneOffset;

  // Convert the UTC instant into the device's local wall-clock time.
  if (deviceOffset == Duration.zero) {
    return sourceUtc.toLocal();
  }

  return sourceUtc.add(deviceOffset);
}

String formattedMobileAmounts(double number) {
  if (number == 0) return "";
  if (number >= -999 && number <= 999) {
    return NumberFormat("###,###,###,###", "en_US").format(number);
  } else if (number >= -999999 && number <= 999999) {
    return "${(number / 1000.0).toStringAsFixed(2)} K";
  } else if (number >= -999999999 && number <= 999999999) {
    return "${(number / 1000000.0).toStringAsFixed(2)} M";
  } else if (number >= -999999999999 && number <= 999999999999) {
    return "${(number / 1000000000.0).toStringAsFixed(2)} B";
  } else if (number >= -999999999999999 && number <= 999999999999999) {
    return "${(number / 1000000000000.0).toStringAsFixed(2)} T";
  } else {
    return "${(number / 1000000000000000.0).toStringAsFixed(2)} E";
  }
}

String formatMinMaxValues({double? min, double? max}) {
  final formatter = NumberFormat('#,##0');

  final minStr = min != null ? formatter.format(min) : "";
  final maxStr = max != null ? formatter.format(max) : "";

  // Both null
  if (minStr.isEmpty && maxStr.isEmpty) return "";

  // Only one exists
  if (minStr.isEmpty) return maxStr;
  if (maxStr.isEmpty) return minStr;

  // Both exist
  return "$minStr / $maxStr";
}

String formatMinValue(int? min) {
  if (min == null) return "";
  final formatter = NumberFormat('#,##0');
  return formatter.format(min);
}

String formatDateString(dynamic dateValue, {bool endOfDay = false}) {
  if (dateValue == null) return '-';

  DateTime? date;
  if (dateValue is DateTime) {
    date = dateValue;
  } else {
    final String raw = dateValue.toString().trim();
    if (raw.isEmpty) return '-';
    date = DateTime.tryParse(raw);
  }

  if (date == null) return '-';

  // Show local time in consistent yyyy-MM-dd HH:mm:ss format.
  DateTime formattedDate = date.toLocal();
  if (endOfDay) {
    formattedDate = DateTime(formattedDate.year, formattedDate.month, formattedDate.day, 23, 59, 59);
  }

  return DateFormat('yyyy-MM-dd HH:mm:ss').format(formattedDate);
}

String toNonEmptyString(dynamic value) {
  return (((value ?? "").toString().isEmpty || value.toString().toLowerCase().contains("null")) ? "-" : value.toString()).trim();
}

String formattedAmounts(double value) {
  final formatter = NumberFormat('#,##0.00');
  final formattedValue = formatter.format(value.abs());
  if (value < 0) {
    return '($formattedValue)';
  }
  return formattedValue;
}

String stringDateToDateTimeString(String dateString, {bool startOfDay = true}) {
  // Parse the string to DateTime
  final date = DateTime.parse(dateString);

  // Format as "YYYY-MM-DD HH:MM:SS.SSS"
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  final time = startOfDay ? '00:00:00.000' : '23:59:59.999';

  return "$year-$month-$day $time";
}

String fromToDateTimeString(String dateString, {bool startOfDay = true}) {
  // Parse the string to DateTime
  final date = DateTime.parse(dateString);

  // Format as "YYYY-MM-DD HH:MM:SS.SSS"
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  if (startOfDay) {
    return "$year-$month-$day 09:00:00.000";
  }

  final nextDay = date.add(const Duration(days: 1));
  final nextYear = nextDay.year.toString().padLeft(4, '0');
  final nextMonth = nextDay.month.toString().padLeft(2, '0');
  final nextDayOfMonth = nextDay.day.toString().padLeft(2, '0');

  return "$nextYear-$nextMonth-$nextDayOfMonth 08:59:59.000";
}

String getTimeFromDateTime(String dateTime) {
  final dt = DateTime.parse(dateTime);
  return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
}
