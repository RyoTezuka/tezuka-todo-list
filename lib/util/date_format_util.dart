import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

DateTime formatStringToDateTime({
  required String sDateTime,
}) {
  Intl.defaultLocale = "ja_JP";
  initializeDateFormatting("ja_JP");
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm", "ja_JP");

  return dateFormat.parseStrict(sDateTime);
}

String formatDateTimeToString({
  required DateTime dDateTime,
}) {
  Intl.defaultLocale = "ja_JP";
  initializeDateFormatting("ja_JP");
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm", "ja_JP");

  return dateFormat.format(dDateTime);
}

Timestamp formatStringToTimestamp({
  required String sDateTime,
}) {
  return Timestamp.fromDate(formatStringToDateTime(sDateTime: sDateTime));
}

String formatTimestampToString({
  required Timestamp tDateTime,
}) {
  return formatDateTimeToString(dDateTime: tDateTime.toDate());
}
