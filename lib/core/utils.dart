import 'dart:io';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:comby/core/extensions.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:comby/generated/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Utils {
  Utils._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text, Color color, BuildContext context) {
    if (text == null) return;
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.surface),
      ),
      backgroundColor: color,
    );
    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static showToastMessage(
      {required BuildContext context,
      required String content,
      Color? color}) async {
    await Fluttertoast.showToast(
        msg: content,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: color ?? Theme.of(context).primaryColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showItemsAlertDialog(
      {required BuildContext context,
      required String title,
      required Widget content,
      String? confirmButtonText,
      VoidCallback? onConfirm,
      String? cancelButtonText,
      VoidCallback? onCancel}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                LayoutConstants.centralEmptyHeight,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (cancelButtonText != null)
                      InkWell(
                        onTap: () {
                          if (onCancel != null) onCancel();
                          context.router.pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.3,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  width: 2, color: context.baseColor)),
                          child: Text(cancelButtonText),
                        ),
                      ),
                    if (cancelButtonText != null)
                      LayoutConstants.centralEmptyWidth,
                    if (confirmButtonText != null)
                      InkWell(
                        onTap: () {
                          if (onConfirm != null) onConfirm();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.3,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 2, color: Colors.red),
                              color: Theme.of(context).colorScheme.primary),
                          child: Text(
                            confirmButtonText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ));
      },
    );
  }

  static Future<void> shareImage(
      Uint8List imageBytes, BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/shared_image.png').create();
      await file.writeAsBytes(imageBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: AppLocalizations.of(context).shareText,
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  static Future<void> shareImageFromUrl(
      String imageUrl, BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/shared_image.png').create();
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: AppLocalizations.of(context).shareTextFromUrl,
        );
      } else {
        debugPrint('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sharing image from URL: $e');
    }
  }

  static Future<void> shareVideo(
      Uint8List videoBytes, BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/shared_video.mp4').create();
      await file.writeAsBytes(videoBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: AppLocalizations.of(context).shareVideoText,
      );
    } catch (e) {
      debugPrint('Error sharing video: $e');
    }
  }

  static void showEditUsernameDialog({
    required BuildContext context,
    required String currentUsername,
    required Function(String) onSave,
  }) {
    final TextEditingController controller =
        TextEditingController(text: currentUsername);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LayoutConstants.highRadius),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).editUsername,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).newUsername,
                  hintText: AppLocalizations.of(context).enterNewUsername,
                  prefixIcon: Icon(
                    Icons.edit_outlined,
                    color: context.baseColor,
                    size: 16.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(LayoutConstants.defaultRadius),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(LayoutConstants.defaultRadius),
                    borderSide: BorderSide(color: context.baseColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: LayoutConstants.lowAllPadding,
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          actions: [
            Row(
              spacing: 8.h,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomGradientButton(
                    title: AppLocalizations.of(context).cancel,
                    onTap: () => Navigator.of(context).pop(),
                    isFilled: false,
                  ),
                ),
                Expanded(
                  child: CustomGradientButton(
                    title: AppLocalizations.of(context).save,
                    onTap: () {
                      final newUsername = controller.text.trim();
                      if (newUsername.isNotEmpty &&
                          newUsername != currentUsername) {
                        onSave(newUsername);
                        Navigator.of(context).pop();
                      }
                    },
                    isFilled: true,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
