import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/features/auth/features/profile/data/models/report_model.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class ReportDialog extends StatelessWidget {
  const ReportDialog({
    super.key,
    required this.mediaUrl,
    required this.reportType,
    required this.onReportSubmitted,
    this.reportController,
    this.contentUrlOrBase64,
    this.prompt,
    this.isBase64,
    this.contentId,
    this.collectionName,
    this.documentId,
  });

  final String mediaUrl;
  final String reportType; // 'video', 'image', 'realtimeImage', 'textToImage'
  final Function(ReportModel) onReportSubmitted;
  final TextEditingController? reportController;
  final String? contentUrlOrBase64;
  final String? prompt;
  final bool? isBase64;
  final String? contentId;
  final String? collectionName;
  final String? documentId;

  @override
  Widget build(BuildContext context) {
    final controller = reportController ?? TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LayoutConstants.highRadius),
      ),
      title: Row(
        children: [
          Icon(
            Icons.report_problem,
            color: Theme.of(context).colorScheme.error,
            size: 24.w,
          ),
          LayoutConstants.defaultEmptyWidth,
          Expanded(
            child: Text(
              AppLocalizations.of(context).reportContent,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prompt != null && prompt!.isNotEmpty) ...[
            Text(
              'Image Prompt:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            LayoutConstants.lowEmptyHeight,
            Container(
              width: double.infinity,
              padding: LayoutConstants.defaultAllPadding,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
                borderRadius:
                    BorderRadius.circular(LayoutConstants.defaultRadius),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                prompt!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            LayoutConstants.midEmptyHeight,
          ],
          Text(
            AppLocalizations.of(context).reportReason,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          LayoutConstants.midEmptyHeight,
          Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(LayoutConstants.defaultRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).enterReportReason,
                border: InputBorder.none,
                contentPadding: LayoutConstants.defaultAllPadding,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.router.pop(),
          child: Text(
            AppLocalizations.of(context).cancel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final report = ReportModel(
              userId:
                  getIt<ProfileBloc>().state.profileInfo?.uid.toString() ?? '',
              description: controller.text,
              contentUrlOrBase64: mediaUrl,
              type: reportType,
              isBase64: isBase64 ?? false,
              prompt: prompt,
              contentId: contentId,
              collectionName: collectionName,
              documentId: documentId,
            );

            onReportSubmitted(report);
            context.router.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(LayoutConstants.defaultRadius),
            ),
          ),
          child: Text(AppLocalizations.of(context).submitReport),
        ),
      ],
    );
  }
}
