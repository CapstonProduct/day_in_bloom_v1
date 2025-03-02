import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CalendarWidget({super.key, required this.onDateSelected});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime? _focusedDay;
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay ?? DateTime.now(),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = selectedDay;
        });

        widget.onDateSelected(selectedDay);
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 12),
        weekendStyle: TextStyle(fontSize: 12, color: Colors.red),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          if (date.day % 6 == 5) {
            return Center(
              child: Text(
                '${date.day}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            return Center(
              child: Image.asset(
                getImagePath(date),
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
            );
          }
        },
      ),
    );
  }
}

String getImagePath(DateTime date) {
  const images = {
    0: "assets/flower_phase/flower_phase0.png",
    1: "assets/flower_phase/flower_phase1.png",
    2: "assets/flower_phase/flower_phase2.png",
    3: "assets/flower_phase/flower_phase3.png",
    4: "assets/flower_phase/flower_phase4.png",
  };

  return images[date.day % 6] ?? "";
}
