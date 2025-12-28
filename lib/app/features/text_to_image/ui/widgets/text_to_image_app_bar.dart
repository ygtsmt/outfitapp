import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/app/features/text_to_image/bloc/text_to_image_bloc.dart';
import 'package:ginfit/app/features/report/bloc/report_bloc.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/core/ui/widgets/report_dialog.dart';
import 'package:ginfit/core/utils.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TextToImageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextToImageState state;
  final TextEditingController promptController;
  final Uint8List? decodedImageBytes;
  final VoidCallback onReportTap;

  const TextToImageAppBar({
    super.key,
    required this.state,
    required this.promptController,
    required this.decodedImageBytes,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context).createImage,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        // Report button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: onReportTap,
            child: Icon(
              Icons.report,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        // Share button
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _handleShare(context),
            child: Icon(
              Icons.share,
              color: context.baseColor,
            ),
          ),
        ),
      ],
    );
  }

  void _handleShare(BuildContext context) async {
    if (state.textToImagePhotoIsBase64 == true) {
      if (decodedImageBytes != null) {
        Utils.shareImage(decodedImageBytes!, context);
      } else {
        Utils.showToastMessage(
          context: context,
          content: AppLocalizations.of(context).noImageToShare,
        );
      }
    } else if (state.textToImagePhotoUrl != null) {
      final response = await http.get(Uri.parse(state.textToImagePhotoUrl!));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/shared_image.png').create();
        await file.writeAsBytes(bytes);

        Utils.shareImage(response.bodyBytes, context);
      } else {
        Utils.showToastMessage(
          context: context,
          content: AppLocalizations.of(context).noImageToShare,
        );
      }
    } else {
      Utils.showToastMessage(
        context: context,
        content: AppLocalizations.of(context).noImageToShare,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
