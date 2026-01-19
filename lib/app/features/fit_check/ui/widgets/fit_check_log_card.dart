import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class FitCheckLogCard extends StatelessWidget {
  final FitCheckLog log;

  const FitCheckLogCard({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
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
            child: CachedNetworkImage(
              imageUrl: log.imageUrl,
              height: 300.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300.h,
                color: Colors.grey[200],
                child: Center(
                  child:
                      Icon(Icons.image, color: Colors.grey[400], size: 48.sp),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300.h,
                color: Colors.grey[200],
                child: Center(
                    child: Icon(Icons.error,
                        color: Colors.grey[400], size: 48.sp)),
              ),
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
                                side: BorderSide.none,
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
