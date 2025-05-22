import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/theme_provider.dart';

CalendarStyle getCalendarStyle(ThemeState themeState) {
  return CalendarStyle(
    selectedDecoration: BoxDecoration(
      color: themeState.primaryColor,
      shape: BoxShape.circle,
    ),
    todayDecoration: BoxDecoration(
      color: themeState.accentColor,
      shape: BoxShape.circle,
    ),
    markerDecoration: BoxDecoration(
      color: themeState.primaryColor.withOpacity(0.7),
      shape: BoxShape.circle,
    ),
    weekendTextStyle: TextStyle(color: themeState.errorColor),
    defaultTextStyle: TextStyle(color: themeState.primaryTextColor),
  );
}

HeaderStyle getHeaderStyle(ThemeState themeState) {
  return HeaderStyle(
    formatButtonVisible: false,
    titleCentered: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: themeState.primaryColor,
    ),
    leftChevronIcon:
        Icon(Icons.chevron_left, color: themeState.primaryTextColor),
    rightChevronIcon:
        Icon(Icons.chevron_right, color: themeState.primaryTextColor),
  );
}

DaysOfWeekStyle getDaysOfWeekStyle(ThemeState themeState) {
  return DaysOfWeekStyle(
    weekdayStyle: TextStyle(color: themeState.primaryTextColor),
    weekendStyle: TextStyle(color: themeState.errorColor),
  );
}
