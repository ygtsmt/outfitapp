import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/app/features/library/ui/widgets/refund_options_dialog.dart';
import 'package:ginfit/generated/l10n.dart';

class FailedRefundCreditWidget extends StatefulWidget {
  const FailedRefundCreditWidget({
    super.key,
    required this.video,
    required this.context,
  });

  final VideoGenerateResponseModel video;
  final BuildContext context;

  @override
  State<FailedRefundCreditWidget> createState() =>
      _FailedRefundCreditWidgetState();
}

class _FailedRefundCreditWidgetState extends State<FailedRefundCreditWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showRefundOptionsDialog(context);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  context.baseColor,
                  context.baseColor.withAlpha(200),
                  context.baseColor.withAlpha(100),
                ],
              )),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 24.w,
                          color: context.white,
                        ),
                        LayoutConstants.tinyEmptyHeight,
                        Text(
                          AppLocalizations.of(context).refundCreditTitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        LayoutConstants.tinyEmptyHeight,
                        Text(
                          AppLocalizations.of(context).refundCreditDescription,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: context.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Background emoji

                Text(
                  '💦',
                  style: TextStyle(
                    fontSize: 75.h,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black45, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),

                // İçerik
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRefundOptionsDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => RefundOptionsDialog(video: widget.video),
    );

    if (result != null && mounted) {
      if (result['result'] == 'refund') {
        // Refund başarılı - success mesajını göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ??
                AppLocalizations.of(context)
                    .refundProcessedSuccessfullyDefault),
            backgroundColor: Colors.green,
          ),
        );
      }
      // 'cancel' durumunda hiçbir şey yapma
    }
  }
}
