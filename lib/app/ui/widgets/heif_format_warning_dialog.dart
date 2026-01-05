import 'package:flutter/material.dart';
import 'package:comby/generated/l10n.dart';

class HeifFormatWarningDialog extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const HeifFormatWarningDialog({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.onContinue,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).heifFormatWarning,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seçtiğiniz dosya HEIF/HEVC formatında:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 16),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).pixverseCompatibility,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Format: HEIF → JPEG (Pixverse uyumlu)\n'
                  '• URL: Firebase HTTPS (✓)\n'
                  '• Aspect Ratio: Crop sırasında kontrol edilecek\n'
                  '• Kalite: %90 korunacak',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Devam etmek istiyor musunuz?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            AppLocalizations.of(context).cancelButton,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context).continueButton),
        ),
      ],
    );
  }
}
