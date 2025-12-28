// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome için
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_generate_header.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_prompt_section.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_image_upload_section.dart';
import 'package:ginfit/app/ui/widgets/auth_required_widget.dart';
import 'package:ginfit/app/ui/widgets/custom_generate_button.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_pixverse_settings_section.dart';
import 'dart:io';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/ui/widgets/heif_format_warning_dialog.dart';
import 'package:ginfit/core/routes/app_router.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_cropper/image_cropper.dart';

class VideoGenerateScreen extends StatefulWidget {
  const VideoGenerateScreen({super.key});

  @override
  State<VideoGenerateScreen> createState() => _VideoGenerateScreenState();
}

class _VideoGenerateScreenState extends State<VideoGenerateScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController promptController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocConsumer<VideoGenerateBloc, VideoGenerateState>(
        listener: (context, state) {
          if (state.status == EventStatus.success) {
            _resetForm();
            context.router.pushNamed('/homeScreen/library/library-screen');
          }

          // Error handling
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: _buildAppBar(context),
              body: /*  state.uploadStatus != EventStatus.idle
                  ? _buildLoadingScreen()
                  :  */
                  SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    VideoGenerateHeader(),
                    SizedBox(height: 24.h),

                    // Prompt Section
                    VideoPromptSection(
                      promptController: promptController,
                      state: state,
                    ),
                    SizedBox(height: 24.h),

                    // Image Upload Section
                    VideoImageUploadSection(
                      state: state,
                      onImagePickerDialog: _showImagePickerDialog,
                    ),
                    SizedBox(height: 24.h),

                    // Settings Section
                    _buildSettingsSection(state),

                    // Generate Button
                    _buildGenerateButton(state),
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: LoadingAnimationWidget.fourRotatingDots(
            size: MediaQuery.of(context).size.height / 16,
            color: context.baseColor,
          ))
        ],
      ),
    );
  }

  // Processing durumu kontrolü
  bool _isProcessing(VideoGenerateState state) {
    return state.status == EventStatus.processing ||
        state.uploadStatus == EventStatus.processing;
  }

  // Button'ın enable olup olmadığını kontrol et
  bool _isButtonEnabled(VideoGenerateState state) {
    // Processing durumunda değilse, upload sırasında değilse ve prompt doluysa enable
    return !_isProcessing(state) &&
        state.uploadStatus != EventStatus.processing &&
        _isPromptValid();
  }

  // Prompt validation
  bool _isPromptValid() {
    final promptText = promptController.text.trim();
    return promptText.isNotEmpty;
  }

  // Video generation handler with debounce protection
  void _handleGenerateVideo(
      BuildContext context, VideoGenerateState state) async {
    // Eğer zaten processing ise, hiçbir şey yapma
    if (_isProcessing(state)) {
      return;
    }

    // Prompt validation - prompt boşsa hiçbir şey yapma
    if (!_isPromptValid()) {
      return;
    }

    // Check for banned words first
    final promptText = promptController.text.trim();
    final bannedWordsResult = BannedWordsService.checkPrompt(promptText);
    if (bannedWordsResult.hasBannedWord) {
      BannedWordsDialog.show(context, bannedWordsResult.bannedWord!);
      return;
    }

    // Debounce protection - son 2 saniye içinde tıklanmışsa engelle
    final now = DateTime.now();
    if (_lastGenerateClick != null &&
        now.difference(_lastGenerateClick!).inMilliseconds < 2000) {
      return;
    }

    _lastGenerateClick = now;

    // Video generation'ı başlat
    getIt<VideoGenerateBloc>().add(
      GenerateVideoEvent(
        prompt: promptController.text,
      ),
    );
  }

  // Son generate click zamanı
  DateTime? _lastGenerateClick;

  // Form'u reset et - success durumunda çağrılır
  void _resetForm() {
    // Prompt controller'ı temizle
    promptController.clear();

    // Bloc state'ini reset et
    getIt<VideoGenerateBloc>().add(
      ResetVideoGenerateFormEvent(),
    );

    // Last click zamanını sıfırla
    _lastGenerateClick = null;
  }

  // App Bar Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        AppLocalizations.of(context).videoGenerate,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  // Main Content Widget
  Widget _buildMainContent(VideoGenerateState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          VideoGenerateHeader(),
          SizedBox(height: 24.h),

          // Prompt Section
          VideoPromptSection(
            promptController: promptController,
            state: state,
          ),
          SizedBox(height: 24.h),

          // Image Upload Section
          VideoImageUploadSection(
            state: state,
            onImagePickerDialog: _showImagePickerDialog,
          ),
          SizedBox(height: 24.h),

          // Settings Section
          _buildSettingsSection(state),

          // Generate Button

          _buildGenerateButton(state),
        ],
      ),
    );
  }

  // Generate Button Widget
  Widget _buildGenerateButton(VideoGenerateState state) {
    return auth.currentUser?.uid == null
        ? AuthRequiredWidget()
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(
                    includeMetadataChanges:
                        false), // Sadece gerçek data değişikliklerini dinle
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(AppLocalizations.of(context).errorLoadingCredits);
              }

              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>?;
              final totalCredit = userData?['profile_info']?['totalCredit'] ??
                  userData?['totalCredit'] ??
                  userData?['profile_info']?['credits'] ??
                  userData?['credits'] ??
                  0;

              // Get credit requirements from AppBloc
              final appBloc = getIt<AppBloc>();
              final creditRequirements =
                  appBloc.state.generateCreditRequirements;
              final requiredCredits =
                  creditRequirements?.videoRequiredCredits ?? 3;

              final hasEnoughCredits = totalCredit >= requiredCredits;

              // Get hasReceivedReviewCredit from ProfileBloc
              final profileBloc = context.read<ProfileBloc>();
              final hasReceivedReviewCredit =
                  profileBloc.state.profileInfo?.hasReceivedReviewCredit ??
                      false;

              return CustomGenerateButton(
                title: _isProcessing(state)
                    ? AppLocalizations.of(context).processing_request
                    : AppLocalizations.of(context).generate,
                generateType: GenerateType.video,
                onTap: () {
                  if (!hasEnoughCredits) {
                    // Platform kontrolü - Android ve iOS için farklı davranış (Play Store politikası)
                    if (Platform.isAndroid) {
                      // Android'de review teşviki yok, direkt ödeme ekranına veya reklam ekranına yönlendir
                      if (hasReceivedReviewCredit) {
                        context.router.push(PaymentsScreenRoute());
                      } else {
                        context.router.push(FreeCreditScreenRoute()); // Sadece reklam seçeneği için
                      }
                    } else {
                      // iOS'ta review credit kontrolü yap
                      if (hasReceivedReviewCredit) {
                        context.router.push(PaymentsScreenRoute());
                      } else {
                        context.router.push(FreeCreditScreenRoute());
                      }
                    }
                  } else if (_isButtonEnabled(state)) {
                    _handleGenerateVideo(context, state);
                  }
                },
                leading: _isProcessing(state)
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(context.white),
                        ),
                      )
                    : Icon(
                        Icons.play_arrow_rounded,
                        color: _isButtonEnabled(state) && hasEnoughCredits
                            ? context.white
                            : context.white.withOpacity(0.5),
                        size: 24,
                      ),
                isFilled: hasEnoughCredits,
              );
            },
          );
  }

  void _showImagePickerDialog(BuildContext context, bool isStartImage) async {
    print('🖼️ _showImagePickerDialog başladı: isStartImage=$isStartImage');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    print('📸 Image picker sonucu: ${image?.path ?? "null"}');

    if (image != null) {
      final file = File(image.path);

      // Dosya bilgilerini al
      final fileInfo = await ImageFormatService.getFileInfo(file);

      // HEIF format kontrolü
      if (ImageFormatService.isHeifFormat(file.path)) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (context) => HeifFormatWarningDialog(
            fileName: path.basename(file.path),
            fileSize: fileInfo['sizeFormatted'] ?? 'Bilinmiyor',
            onContinue: () => Navigator.pop(context, true),
            onCancel: () => Navigator.pop(context, false),
          ),
        );

        if (shouldContinue != true) return;
      }

      // Pixverse uyumluluk kontrolleri
      if (fileInfo['sizeValid'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).fileSizeTooLarge),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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
          sourcePath: file.path,
          compressFormat: ImageCompressFormat.jpg, // JPEG formatı
          maxWidth: 2048, // Maksimum genişlik
          maxHeight: 2048, // Maksimum yükseklik
          uiSettings: cropperUiSettings);

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
        print('✅ Crop işlemi başarılı: ${croppedFile.path}');

        // Minimum boyut kontrolü yap ve gerekirse siyah alan ekle
        final paddedFile = await ImageFormatService.ensureMinimumSize(
          File(croppedFile.path),
          minWidth: 300,
          minHeight: 300,
        );

        if (paddedFile != null) {
          print('✅ Minimum boyut kontrolü tamamlandı: ${paddedFile.path}');
          // Padded file'ı bloc'a gönder
          print('🚀 PickImageEvent gönderiliyor...');
          getIt<VideoGenerateBloc>().add(
            PickImageEvent(
              isStartImage: isStartImage,
              croppedFilePath: paddedFile.path,
            ),
          );
          print('📤 PickImageEvent gönderildi');
        } else {
          print('❌ Minimum boyut kontrolü başarısız');
        }
      } else {
        print('❌ Crop işlemi iptal edildi veya başarısız');
      }
    }
  }

  Widget _buildSettingsSection(VideoGenerateState state) {
    return VideoPixverseSettingsSection(
      state: state,
      onResolutionSelected: (resolution) => getIt<VideoGenerateBloc>().add(
        UpdateSettingsEvent(resolution: resolution),
      ),
      onLengthSelected: (length) => getIt<VideoGenerateBloc>().add(
        UpdateSettingsEvent(length: int.tryParse(length)),
      ),
      onAspectRatioSelected: (aspectRatio) => getIt<VideoGenerateBloc>().add(
        UpdateSettingsEvent(aspectRatio: aspectRatio),
      ),
      onStyleSelected: (style) => getIt<VideoGenerateBloc>().add(
        UpdateSettingsEvent(style: style),
      ),
      onModeSelected: (mode) => getIt<VideoGenerateBloc>().add(
        UpdateSettingsEvent(mode: mode),
      ),
      onNegativePromptChanged: (negativePrompt) =>
          getIt<VideoGenerateBloc>().add(
        UpdateSettingsEvent(negativePrompt: negativePrompt),
      ),
    );
  }
}
