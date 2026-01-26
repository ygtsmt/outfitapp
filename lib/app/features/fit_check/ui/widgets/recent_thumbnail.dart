import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class RecentFitCheckThumbnail extends StatelessWidget {
  final FitCheckLog log;

  const RecentFitCheckThumbnail({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(FitCheckResultScreenRoute(log: log));
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: CachedNetworkImage(
                  imageUrl: log.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image,
                          color: Colors.grey[400], size: 24.sp),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child:
                        Icon(Icons.error, color: Colors.grey[400], size: 24.sp),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('d MMM', Localizations.localeOf(context).toString())
                  .format(log.createdAt),
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
