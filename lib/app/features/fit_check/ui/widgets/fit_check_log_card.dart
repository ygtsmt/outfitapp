import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/core/routes/app_router.dart';
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
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 1,
      child: InkWell(
        onTap: () {
          context.router.push(FitCheckResultScreenRoute(log: log));
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Thumbnail Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: log.imageUrl,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image,
                          color: Colors.grey[400], size: 24.sp),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.error,
                          color: Colors.grey[400], size: 24.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and Style Row
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('HH:mm').format(log.createdAt),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                        if (log.overallStyle != null) ...[
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                log.overallStyle!,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Description (if available)
                    if (log.aiDescription != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        log.aiDescription!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Detected Items Count (if available)
                    if (log.detectedItems != null &&
                        log.detectedItems!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.checkroom,
                              size: 12.sp, color: Colors.grey[500]),
                          SizedBox(width: 4.w),
                          Text(
                            '${log.detectedItems!.length} parça',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
