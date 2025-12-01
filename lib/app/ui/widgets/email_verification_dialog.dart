import 'package:flutter/material.dart';
import 'package:ginly/app/core/services/email_verification_service.dart';
import 'package:ginly/generated/l10n.dart';

class EmailVerificationDialog extends StatefulWidget {
  final VoidCallback? onVerified;

  const EmailVerificationDialog({
    super.key,
    this.onVerified,
  });

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).emailVerificationRequired,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).emailVerificationMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_isEmailSent)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).verificationEmailSent,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendVerificationEmail,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context).sendVerificationEmail),
        ),
        ElevatedButton(
          onPressed: _checkVerificationStatus,
          child: Text(AppLocalizations.of(context).checkVerification),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
    );
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await EmailVerificationService.sendEmailVerification();
      setState(() {
        _isEmailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context).errorSendingVerificationEmail),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isVerified =
          await EmailVerificationService.checkEmailVerificationStatus();

      if (isVerified) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onVerified?.call();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context).emailVerifiedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).emailNotVerifiedYet),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).errorCheckingVerification),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
