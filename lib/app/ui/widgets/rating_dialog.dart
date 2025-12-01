import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: context.baseColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rate,
                size: 30.sp,
                color: context.baseColor,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              AppLocalizations.of(context).rateOurApp,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: context.baseColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              AppLocalizations.of(context).howWasYourExperience,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Star Rating
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.w,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                    // Yıldız seçilir seçilmez işlemi başlat
                    _handleRating(index + 1);
                  },
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    size: 36.sp,
                    color: index < _selectedRating
                        ? Colors.amber
                        : Colors.grey[400],
                  ),
                );
              }),
            ),

            // Rating Text

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: Text(
                      AppLocalizations.of(context).maybeLater,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return AppLocalizations.of(context).veryPoor;
      case 2:
        return AppLocalizations.of(context).poor;
      case 3:
        return AppLocalizations.of(context).good;
      case 4:
        return AppLocalizations.of(context).veryGood;
      case 5:
        return AppLocalizations.of(context).excellent;
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    if (rating <= 2) {
      return Colors.red;
    } else if (rating == 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void _handleRating(int rating) async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 500));

    Navigator.of(context).pop(rating);
  }
}
