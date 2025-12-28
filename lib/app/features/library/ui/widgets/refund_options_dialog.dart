import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:flutter/services.dart';
import 'package:ginfit/app/core/services/refund_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginfit/generated/l10n.dart';

class RefundOptionsDialog extends StatefulWidget {
  const RefundOptionsDialog({
    super.key,
    required this.video,
  });

  final VideoGenerateResponseModel video;

  @override
  State<RefundOptionsDialog> createState() => _RefundOptionsDialogState();
}

class _RefundOptionsDialogState extends State<RefundOptionsDialog> {
  bool _isLoading = false;
  bool _canRefund = true;
  int _refundCount = 0;

  @override
  void initState() {
    super.initState();
    _checkRefundEligibility();
  }

  bool get _isMounted => mounted;

  Future<void> _checkRefundEligibility() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final appState = context.read<AppBloc>().state;
      final creditRequirements = appState.generateCreditRequirements;

      if (creditRequirements != null) {
        final refundService =
            RefundService(creditRequirements: creditRequirements);
        final canRefund = await refundService.canRequestRefund(userId);
        final refundCount = await refundService.getRefundCount(userId);

        setState(() {
          _canRefund = canRefund;
          _refundCount = refundCount;
        });
      }
    }
  }

  Future<void> _processRefund() async {
    try {
      setState(() => _isLoading = true);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final appState = context.read<AppBloc>().state;
        final creditRequirements = appState.generateCreditRequirements;

        if (creditRequirements != null) {
          try {
            final refundService =
                RefundService(creditRequirements: creditRequirements);

            final result =
                await refundService.processVideoRefund(userId, widget.video);

            if (result['success']) {
              try {
                final profileBloc = getIt<ProfileBloc>();
                final event = FetchProfileInfoEvent(
                    FirebaseAuth.instance.currentUser!.uid);
                profileBloc.add(event);
              } catch (e) {
                // Profile update failed, but refund succeeded
              }

              // Close dialog first, then show success message in parent
              if (_isMounted) {
                context.router.pop({
                  'result': 'refund',
                  'message': result['message'] ??
                      AppLocalizations.of(context).refundProcessedSuccessfully
                });
              }
            } else {
              // Show error message before closing dialog
              if (_isMounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['reason'] ??
                        AppLocalizations.of(context).refundFailed),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (serviceError) {
            if (_isMounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context).errorProcessingRefund),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context).creditRequirementsNotLoaded),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // General error handling
    } finally {
      if (_isMounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withAlpha(200),
              Theme.of(context).colorScheme.primary.withAlpha(200),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).videoGenerationFailed,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).videoGenerationFailedDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            if (_canRefund) ...[
              _buildOption(
                context: context,
                icon: _isLoading
                    ? Icons.hourglass_empty
                    : Icons.account_balance_wallet_rounded,
                title: _isLoading
                    ? AppLocalizations.of(context).processing
                    : AppLocalizations.of(context).refundCredit,
                onTap: _isLoading ? null : _processRefund,
              ),
            ] else ...[
              _buildContactSupportWidget(),
            ],
            SizedBox(height: 16.h),
            if (widget.video.input?.prompt != null &&
                widget.video.input!.prompt!.isNotEmpty) ...[
              _buildPromptWidget(),
              SizedBox(height: 16.h),
            ],
            TextButton(
              onPressed: () => context.router.pop({'result': 'cancel'}),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupportWidget() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 32.w,
          ),
          SizedBox(height: 12.h),
          Text(
            AppLocalizations.of(context).refundLimitReached,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)
                .refundLimitReachedDescription(_refundCount),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.withOpacity(0.9),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                  const ClipboardData(text: 'ginlyaideveloper@gmail.com'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).emailCopied),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.email,
                    color: Colors.orange,
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).contactSupport,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptWidget() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        spacing: 8.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).toAvoidFiltering,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
          Row(
            spacing: 4.h,
            children: [
              Expanded(
                child: Text(
                  widget.video.input!.prompt!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.video.input!.prompt!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).promptCopied),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(onTap == null ? 0.1 : 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(onTap == null ? 0.1 : 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(onTap == null ? 0.5 : 1.0),
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white.withOpacity(onTap == null ? 0.5 : 1.0),
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
