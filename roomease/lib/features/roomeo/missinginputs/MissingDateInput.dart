import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MissingDateInput extends StatefulWidget {
  const MissingDateInput(
      {super.key, required this.onDateSelect, required this.placeHolder});

  final Function(String) onDateSelect;
  final String placeHolder;

  @override
  State<MissingDateInput> createState() => _MissingDateInputState();
}

class _MissingDateInputState extends State<MissingDateInput> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Pass the default selectedDate back to the parent widget
    // widget.onDateSelect(DateTime(selectedDate.year, selectedDate.month,
    //     selectedDate.day, selectedDate.hour, selectedDate.minute));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day,
            selectedDate.hour, selectedDate.minute);
      });
      widget
          .onDateSelect(DateFormat('yyyy-MM-dd hh:mm a').format(selectedDate));
      //widget.onDateSelect(DateTime(selectedDate.year, selectedDate.month,
      //selectedDate.day, selectedDate.hour, selectedDate.minute));
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
      widget
          .onDateSelect(DateFormat('yyyy-MM-dd hh:mm a').format(selectedDate));
    }
  }

  Text _formatSelectedDate(DateTime selectedDate) {
    DateTime today = DateTime.now();
    if (selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day) {
      return Text(
          '${DateFormat('EEEE, MMMM dd').format(selectedDate)} (Today) - ${DateFormat('hh:mm a').format(selectedDate)}');
    } else if (selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day + 1) {
      return Text(
          '${DateFormat('EEEE, MMMM dd').format(selectedDate)} (Tomorrow) - ${DateFormat('hh:mm a').format(selectedDate)}');
    }
    return Text(DateFormat('EEEE, MMMM dd - hh:mm a').format(selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(widget.placeHolder),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                child: Text('Select Date'),
              ),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                child: Text('Select Time'),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Currently selected date: '),
              _formatSelectedDate(selectedDate),
            ],
          )
        ],
      ),
    );
  }
}
