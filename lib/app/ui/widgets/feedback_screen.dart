import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome için
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        // SAFE AREA DÜZELTMESİ: Crop işleminden önce system UI'ı ayarla
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF2F2B52),
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF2F2B52),
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Color(0xFF2F2B52),
          ),
        );

        // CROP işlemi
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg, // JPEG formatı
          maxWidth: 2048, // Maksimum genişlik
          maxHeight: 2048, // Maksimum yükseklik
          uiSettings: cropperUiSettings,
        );

        // SAFE AREA DÜZELTMESİ: Crop işleminden sonra system UI'ı geri yükle
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );

        if (croppedFile != null) {
          setState(() {
            _selectedImage = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).failedToPickImage(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).feedback),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state.submitFeedbackStatus == EventStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).feedbackSubmitted),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.submitFeedbackStatus == EventStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context).failedToSubmitFeedback),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context).feedbackDescription,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).addImageOptional,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.add_photo_alternate,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                        if (_selectedImage != null) ...[
                          SizedBox(height: 16.h),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 200.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Message Input
                TextFormField(
                  controller: _messageController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).feedbackHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).feedbackRequired;
                    }
                    if (value.trim().length < 10) {
                      return AppLocalizations.of(context).feedbackMinLength;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),
                BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    return CustomGradientButton(
                      onTap: () {
                        // state.submitFeedbackStatus == EventStatus.processing
                        context.read<AppBloc>().add(
                              SubmitFeedbackEvent(
                                _messageController.text.trim(),
                                imageFile: _selectedImage,
                              ),
                            );
                      },
                      title: AppLocalizations.of(context).submitFeedback,
                      isFilled:
                          state.submitFeedbackStatus != EventStatus.processing,
                    );
                  },
                ),
                // Submit Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
