import 'package:flutter/material.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

Future<void> showMonthPicker(BuildContext context, DateTime selectedDate, Function(DateTime) setDate, Function() loadTransactions) async {
  final picked = await SimpleMonthYearPicker.showMonthYearPickerDialog(
    context: context,
    titleTextStyle: TextStyle(),
    monthTextStyle: TextStyle(),
    yearTextStyle: TextStyle(),
    selectionColor: Color.fromARGB(172, 19, 38, 78),
    disableFuture: true, // This will disable future years. it is false by default.
  );
  setDate(picked);
  print('Selected date: $picked');
  loadTransactions();
}