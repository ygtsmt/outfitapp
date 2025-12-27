import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:ginly/app/features/fit_check/models/fit_check_model.dart';
import 'package:ginly/app/features/fit_check/services/fit_check_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class FitCheckCalendarScreen extends StatefulWidget {
  const FitCheckCalendarScreen({super.key});

  @override
  State<FitCheckCalendarScreen> createState() => _FitCheckCalendarScreenState();
}

class _FitCheckCalendarScreenState extends State<FitCheckCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<FitCheckLog>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchMonthlyData(_focusedDay);
  }

  /// Fetches data for the month of the focused day
  void _fetchMonthlyData(DateTime month) {
    GetIt.I<FitCheckService>().getFitChecksForMonthStream(month).listen((logs) {
      if (!mounted) return;

      final Map<DateTime, List<FitCheckLog>> newEvents = {};
      for (var log in logs) {
        // Normalize date to remove time part for accurate map keys
        final date = DateTime(
            log.createdAt.year, log.createdAt.month, log.createdAt.day);
        if (newEvents[date] == null) newEvents[date] = [];
        newEvents[date]!.add(log);
      }

      setState(() {
        _events = newEvents;
      });
    });
  }

  List<FitCheckLog> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Current theme colors or hardcoded if strictly required
    final kPrimaryColor = Color(0xFFE94057);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kıyafet Takvimi 📅'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendar(kPrimaryColor),
          const Divider(),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildCalendar(Color primaryColor) {
    return TableCalendar<FitCheckLog>(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        markersMaxCount: 1,
        markerDecoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _fetchMonthlyData(focusedDay); // Fetch new data when month swipes
      },
    );
  }

  Widget _buildEventList() {
    final selectedEvents =
        _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 60, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'Bugün için kayıt yok',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final log = selectedEvents[index];
        return _buildFitCheckCard(log);
      },
    );
  }

  Widget _buildFitCheckCard(FitCheckLog log) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Time and Style
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(log.createdAt),
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                if (log.overallStyle != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      log.overallStyle!,
                      style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Image.network(
              log.imageUrl,
              height: 250.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Details
          if (log.aiDescription != null || log.detectedItems != null)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.aiDescription != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        log.aiDescription!,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700),
                      ),
                    ),
                  if (log.detectedItems != null &&
                      log.detectedItems!.isNotEmpty)
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: log.detectedItems!
                          .map((item) => Chip(
                                label: Text(item,
                                    style: TextStyle(fontSize: 11.sp)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.grey.shade100,
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
