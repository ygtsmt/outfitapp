import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/services/fit_check_service.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class FitChecksTabContent extends StatefulWidget {
  const FitChecksTabContent({super.key});

  @override
  State<FitChecksTabContent> createState() => _FitChecksTabContentState();
}

class _FitChecksTabContentState extends State<FitChecksTabContent> {
  final FitCheckService _fitCheckService = GetIt.I<FitCheckService>();
  int _crossAxisCount = 3;

  // Filter State
  String _selectedTimeFilter = 'all';
  List<String> _selectedStyles = [];
  List<String> _selectedColors = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FitCheckLog>>(
      stream: _fitCheckService.getAllFitChecksStream(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noFitCheckLogsYet,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final filteredLogs = _filterLogs(logs);
        final groupedLogs = _groupLogsByMonth(filteredLogs);

        if (filteredLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_alt_off,
                  size: 64.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noFilterResults,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Filter bar
            if (_selectedTimeFilter != 'all' ||
                _selectedStyles.isNotEmpty ||
                _selectedColors.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Icon(Icons.filter_list,
                        size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getFilterSummary(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(
                        AppLocalizations.of(context).clearAll,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
                itemCount: groupedLogs.length,
                itemBuilder: (context, index) {
                  final entry = groupedLogs.entries.elementAt(index);
                  final monthKey = entry.key;
                  final monthLogs = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          monthKey,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _crossAxisCount,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.h,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: monthLogs.length,
                        itemBuilder: (context, i) {
                          final log = monthLogs[i];
                          return _buildFitCheckCard(log);
                        },
                      ),
                      SizedBox(height: 16.h),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFitCheckCard(FitCheckLog log) {
    return GestureDetector(
      onTap: () {
        context.router.push(FitCheckResultScreenRoute(log: log));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: log.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd MMM').format(log.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FitCheckLog> _filterLogs(List<FitCheckLog> logs) {
    var filtered = logs;

    // Time filter
    if (_selectedTimeFilter != 'all') {
      final now = DateTime.now();
      filtered = filtered.where((log) {
        switch (_selectedTimeFilter) {
          case 'today':
            return log.createdAt.year == now.year &&
                log.createdAt.month == now.month &&
                log.createdAt.day == now.day;
          case 'yesterday':
            final yesterday = now.subtract(const Duration(days: 1));
            return log.createdAt.year == yesterday.year &&
                log.createdAt.month == yesterday.month &&
                log.createdAt.day == yesterday.day;
          case 'week':
            final weekAgo = now.subtract(const Duration(days: 7));
            return log.createdAt.isAfter(weekAgo);
          default:
            return true;
        }
      }).toList();
    }

    // Style filter
    if (_selectedStyles.isNotEmpty) {
      filtered = filtered.where((log) {
        return log.overallStyle != null &&
            _selectedStyles.contains(log.overallStyle!.toLowerCase());
      }).toList();
    }

    // Color filter
    if (_selectedColors.isNotEmpty) {
      filtered = filtered.where((log) {
        return log.colorPalette != null &&
            log.colorPalette!.keys
                .any((color) => _selectedColors.contains(color.toLowerCase()));
      }).toList();
    }

    return filtered;
  }

  Map<String, List<FitCheckLog>> _groupLogsByMonth(List<FitCheckLog> logs) {
    final Map<String, List<FitCheckLog>> grouped = {};

    for (final log in logs) {
      final monthKey = DateFormat('MMMM yyyy').format(log.createdAt);
      grouped.putIfAbsent(monthKey, () => []).add(log);
    }

    return grouped;
  }

  String _getFilterSummary() {
    final parts = <String>[];

    if (_selectedTimeFilter != 'all') {
      parts.add(_selectedTimeFilter);
    }

    if (_selectedStyles.isNotEmpty) {
      parts.add('${_selectedStyles.length} styles');
    }

    if (_selectedColors.isNotEmpty) {
      parts.add('${_selectedColors.length} colors');
    }

    return parts.join(' • ');
  }

  void _clearFilters() {
    setState(() {
      _selectedTimeFilter = 'all';
      _selectedStyles.clear();
      _selectedColors.clear();
    });
  }
}
