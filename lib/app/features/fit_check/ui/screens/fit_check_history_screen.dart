import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/services/fit_check_service.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class FitCheckHistoryScreen extends StatefulWidget {
  const FitCheckHistoryScreen({super.key});

  @override
  State<FitCheckHistoryScreen> createState() => _FitCheckHistoryScreenState();
}

class _FitCheckHistoryScreenState extends State<FitCheckHistoryScreen> {
  final FitCheckService _fitCheckService = GetIt.I<FitCheckService>();
  int _crossAxisCount = 3;
  double _baseScaleFactor = 1.0;

  // Filter State
  String _selectedTimeFilter = 'all'; // all, today, yesterday, week, month
  List<String> _selectedStyles = [];
  List<String> _selectedColors = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FitCheckLog>>(
        stream: _fitCheckService.getAllFitChecksStream(),
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Geçmiş Kombinler'),
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.white,
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () => _showFilterBottomSheet(logs),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.filter_list),
                      if (_selectedTimeFilter != 'all' ||
                          _selectedStyles.isNotEmpty ||
                          _selectedColors.isNotEmpty)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            body: Builder(builder: (context) {
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
                        'Henüz geçmiş kayıt bulunmuyor.',
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
                        Icons.filter_list_off,
                        size: 64.sp,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Filtrelere uygun kayıt bulunamadı.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GestureDetector(
                onScaleStart: (details) {
                  _baseScaleFactor = _crossAxisCount.toDouble();
                },
                onScaleUpdate: (details) {
                  final effectiveScale = details.scale * details.scale;
                  final newCount = (_baseScaleFactor / effectiveScale).round();
                  final clampedCount = newCount.clamp(2, 4);

                  if (_crossAxisCount != clampedCount) {
                    setState(() {
                      _crossAxisCount = clampedCount;
                    });
                  }
                },
                child: CustomScrollView(
                  slivers: groupedLogs.entries.expand((entry) {
                    final monthDate = entry.key;
                    final monthLogs = entry.value;

                    return [
                      // Month Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                          child: Text(
                            DateFormat('MMMM yyyy', 'tr_TR').format(monthDate),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      // Grid for this month
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _crossAxisCount,
                            crossAxisSpacing: 8.w,
                            mainAxisSpacing: 8.h,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final log = monthLogs[index];
                              return GestureDetector(
                                onTap: () {
                                  context.router.push(
                                      FitCheckResultScreenRoute(log: log));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: log.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey[100],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[100],
                                          child: const Icon(Icons.error),
                                        ),
                                      ),
                                      // Date Overlay
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4.h),
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
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 8.w, bottom: 2.h),
                                            child: Text(
                                              log.overallStyle ?? '',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: monthLogs.length,
                          ),
                        ),
                      ),
                    ];
                  }).toList(),
                ),
              );
            }),
          );
        });
  }

  void _showFilterBottomSheet(List<FitCheckLog> allLogs) {
    // 1. Generate Dynamic Options
    final uniqueStyles = allLogs
        .map((log) => log.overallStyle)
        .where((style) => style != null && style.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    uniqueStyles.sort();

    final uniqueColors = allLogs
        .expand((log) => log.colorPalette?.keys ?? <String>[])
        .where((color) => color.isNotEmpty)
        .toSet()
        .toList();
    uniqueColors.sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrele',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedTimeFilter = 'all';
                            _selectedStyles.clear();
                            _selectedColors.clear();
                          });
                        },
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSection(
                            title: 'Tarih',
                            children: [
                              _buildFilterChip(
                                  'Tümü',
                                  'all',
                                  _selectedTimeFilter,
                                  (val) => setModalState(
                                      () => _selectedTimeFilter = val)),
                              _buildFilterChip(
                                  'Bugün',
                                  'today',
                                  _selectedTimeFilter,
                                  (val) => setModalState(
                                      () => _selectedTimeFilter = val)),
                              _buildFilterChip(
                                  'Dün',
                                  'yesterday',
                                  _selectedTimeFilter,
                                  (val) => setModalState(
                                      () => _selectedTimeFilter = val)),
                              _buildFilterChip(
                                  'Son 7 Gün',
                                  'week',
                                  _selectedTimeFilter,
                                  (val) => setModalState(
                                      () => _selectedTimeFilter = val)),
                              _buildFilterChip(
                                  'Son 30 Gün',
                                  'month',
                                  _selectedTimeFilter,
                                  (val) => setModalState(
                                      () => _selectedTimeFilter = val)),
                            ],
                          ),
                          if (uniqueStyles.isNotEmpty)
                            _buildFilterSection(
                              title: 'Tarz',
                              children: uniqueStyles.map((style) {
                                final isSelected =
                                    _selectedStyles.contains(style);
                                return FilterChip(
                                  label: Text(style),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        _selectedStyles.add(style);
                                      } else {
                                        _selectedStyles.remove(style);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Colors.black,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 12.sp,
                                  ),
                                  side: isSelected
                                      ? BorderSide.none
                                      : BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                );
                              }).toList(),
                            ),
                          if (uniqueColors.isNotEmpty)
                            _buildFilterSection(
                              title: 'Renkler',
                              children: uniqueColors.map((color) {
                                final isSelected =
                                    _selectedColors.contains(color);
                                return FilterChip(
                                  label: Text(color),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        _selectedColors.add(color);
                                      } else {
                                        _selectedColors.remove(color);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Colors.black,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 12.sp,
                                  ),
                                  side: isSelected
                                      ? BorderSide.none
                                      : BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Trigger rebuild to apply filters
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Uygula',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: children,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, String groupValue,
      Function(String) onSelected) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 12.sp,
      ),
      side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  List<FitCheckLog> _filterLogs(List<FitCheckLog> logs) {
    return logs.where((log) {
      // Time Filter
      bool timeMatch = true;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final logDate =
          DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day);

      switch (_selectedTimeFilter) {
        case 'today':
          timeMatch = logDate.isAtSameMomentAs(today);
          break;
        case 'yesterday':
          timeMatch =
              logDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
          break;
        case 'week':
          timeMatch =
              log.createdAt.isAfter(now.subtract(const Duration(days: 7)));
          break;
        case 'month':
          timeMatch =
              log.createdAt.isAfter(now.subtract(const Duration(days: 30)));
          break;
      }

      // Style Filter
      bool styleMatch = true;
      if (_selectedStyles.isNotEmpty) {
        styleMatch = _selectedStyles.contains(log.overallStyle);
      }

      // Color Filter
      bool colorMatch = true;
      if (_selectedColors.isNotEmpty) {
        // Dynamic dynamic match: selectedColors are raw keys from logs now.
        // So we can assume direct containment in keys.
        colorMatch = _selectedColors.any((selectedColor) {
          return log.colorPalette?.keys.contains(selectedColor) ?? false;
        });
      }

      return timeMatch && styleMatch && colorMatch;
    }).toList();
  }

  Map<DateTime, List<FitCheckLog>> _groupLogsByMonth(List<FitCheckLog> logs) {
    final grouped = <DateTime, List<FitCheckLog>>{};
    for (var log in logs) {
      final month = DateTime(log.createdAt.year, log.createdAt.month);
      if (grouped.containsKey(month)) {
        grouped[month]!.add(log);
      } else {
        grouped[month] = [log];
      }
    }
    return grouped;
  }
}
