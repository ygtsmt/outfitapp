import 'package:comby/app/features/fit_check/ui/widgets/fit_check_stats_dashboard.dart';
import 'package:comby/app/features/fit_check/ui/widgets/fit_check_log_card.dart';
import 'package:comby/app/features/fit_check/ui/widgets/recent_overview.dart';
import 'package:comby/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/services/fit_check_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FitCheckCalendarScreen extends StatefulWidget {
  const FitCheckCalendarScreen({super.key});

  @override
  State<FitCheckCalendarScreen> createState() => _FitCheckCalendarScreenState();
}

class _FitCheckCalendarScreenState extends State<FitCheckCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<FitCheckLog>> _events = {};
  int _currentStreak = 0;
  List<FitCheckLog> _recentFitChecks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchMonthlyData(_focusedDay);
    _fetchStreak();
    _fetchRecentFitChecks();
  }

  Future<void> _fetchRecentFitChecks() async {
    final recent =
        await GetIt.I<FitCheckService>().getRecentFitChecks(limit: 30);
    if (mounted) {
      setState(() {
        _recentFitChecks = recent;
      });
    }
  }

  Future<void> _fetchStreak() async {
    final streak = await GetIt.I<FitCheckService>().calculateStreak();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
      });
    }
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

    // Get User Name for motivation
    final user = FirebaseAuth.instance.currentUser;
    String? userName;
    if (user != null && !user.isAnonymous) {
      userName = user.displayName;
      // If displayName contains space, take first name
      if (userName != null && userName.contains(' ')) {
        userName = userName.split(' ')[0];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).outfitCalendar),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FitCheckRecentOverview(
            recentFitChecks: _recentFitChecks,
          ),
          const Divider(),
          _buildCalendar(kPrimaryColor),
          const Divider(),
          SizedBox(height: 16.h),
          FitCheckStatsDashboard(
            events: _events,
            currentStreak: _currentStreak,
            userName: userName,
          ),
          SizedBox(height: 16.h),
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
      headerStyle: const HeaderStyle(
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

        final events = _getEventsForDay(selectedDay);
        if (events.isNotEmpty) {
          _showDailyEvents(context, selectedDay, events);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).noRecordFoundForDate),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _fetchMonthlyData(focusedDay);
      },
    );
  }

  void _showDailyEvents(
      BuildContext context, DateTime day, List<FitCheckLog> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Text(
                      DateFormat('d MMMM yyyy',
                              Localizations.localeOf(context).toString())
                          .format(day),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94057).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${events.length} ${AppLocalizations.of(context).kombins}',
                        style: TextStyle(
                          color: const Color(0xFFE94057),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return FitCheckLogCard(log: events[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
