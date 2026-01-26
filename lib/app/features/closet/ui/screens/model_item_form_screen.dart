import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModelItemFormScreen extends StatefulWidget {
  final File imageFile;

  const ModelItemFormScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ModelItemFormScreen> createState() => _ModelItemFormScreenState();
}

class _ModelItemFormScreenState extends State<ModelItemFormScreen> {
  String? modelName;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addModel),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fotoğraf önizleme
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                widget.imageFile,
                height: 300.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 24.h),
            // Model adı (opsiyonel)
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).modelNameOptional,
                hintText: AppLocalizations.of(context).modelNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  modelName = value.isEmpty ? null : value;
                });
              },
            ),
            SizedBox(height: 24.h),
            // Kaydet butonu
            ElevatedButton(
              onPressed: !isUploading ? _saveItem : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.baseColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: isUploading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).save,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    setState(() {
      isUploading = true;
    });

    try {
      // Firebase Storage'a yükle
      final closetUseCase = getIt<ClosetUseCase>();
      final imageUrl = await closetUseCase.uploadModelImage(widget.imageFile);

      final item = ModelItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: imageUrl,
        name: modelName,
        createdAt: DateTime.now(),
      );

      // Item'ı ekle
      if (context.mounted) {
        getIt<ClosetBloc>().add(AddModelItemEvent(item));

        // Başarı mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).modelAddedSuccessfully),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Return the created item to the previous screen
        if (context.mounted) {
          context.router.pop(item);
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
