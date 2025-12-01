import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome için
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/data/models/features_doc_model.dart';
import 'package:ginly/app/features/template_generate/bloc/template_generate_bloc.dart';
import 'package:ginly/app/ui/widgets/auth_required_widget.dart';
import 'package:ginly/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginly/app/ui/widgets/custom_progress_dialog.dart';
import 'package:ginly/app/ui/widgets/total_credit_widget.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginly/core/routes/app_router.dart';
import 'package:ginly/app/core/services/revenue_cat_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:ginly/app/ui/widgets/rating_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../widgets/template_preview_widget.dart';
import '../widgets/photo_type_selection_widget.dart';
import '../widgets/photo_upload_section_widget.dart';
import '../widgets/generate_video_button_widget.dart';

class GenerateTemplateVideoScreen extends StatefulWidget {
  final VideoTemplate videoTemplate;
  const GenerateTemplateVideoScreen({super.key, required this.videoTemplate});

  @override
  State<GenerateTemplateVideoScreen> createState() =>
      _GenerateTemplateVideoScreenState();
}

class _GenerateTemplateVideoScreenState
    extends State<GenerateTemplateVideoScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  File? _imageFile1;
  File? _imageFile2;
  File? _imageFile3;
  ui.Image? _mergedImage;
  bool isdifferentPhoto = false;
  bool _isGenerationStarted = false;
  late final DateTime _screenStartTime;
  bool _hasGenerated = false;

  @override
  void initState() {
    super.initState();
    _screenStartTime = DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TemplateGenerateBloc, TemplateGenerateState>(
      listener: (context, state) {
        // Video generation başarılı olduğunda library'ye yönlendir
        if (state.generateStatus == EventStatus.success &&
            _isGenerationStarted) {
          // Success log
          _hasGenerated = true;

          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).video_generation_success,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Reset generation flag
          setState(() {
            _isGenerationStarted = false;
          });

          // Library video screen'e yönlendir
          context.router.pushNamed('/homeScreen/library/library-screen');
        }

        // Video generation başarısız olduğunda hata mesajı göster
        if (state.generateStatus == EventStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    AppLocalizations.of(context).video_generation_error,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Reset generation flag
          setState(() {
            _isGenerationStarted = false;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            centerTitle: true,
            title: BlocBuilder<AppBloc, AppState>(
              builder: (context, appState) {
                return Text(
                  resolveByLocale(
                    appState.languageLocale,
                    widget.videoTemplate.title ?? '',
                    tr: widget.videoTemplate.titleTr,
                    de: widget.videoTemplate.titleDe,
                    fr: widget.videoTemplate.titleFr,
                    ar: widget.videoTemplate.titleAr,
                    ru: widget.videoTemplate.titleRu,
                    zh: widget.videoTemplate.titleZh,
                    es: widget.videoTemplate.titleEs,
                    hi: widget.videoTemplate.titleHi,
                    pt: widget.videoTemplate.titlePt,
                    id: widget.videoTemplate.titleId,
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
            actions: const [
              TotalCreditWidget(
                navigateAvailable: true,
              ),
            ],
            actionsPadding: EdgeInsets.only(right: 12.w),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Template Preview
                TemplatePreviewWidget(
                  videoTemplate: widget.videoTemplate,
                ),

                // Photo Type Selection - Preview'ın üstüne gelecek (negatif margin ile)
                Transform.translate(
                  offset: Offset(0, -30.h), // Yukarı doğru kaydır
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: _buildTemplateForm(state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Column _buildTemplateForm(TemplateGenerateState state) {
    return Column(
      children: [
        if (widget.videoTemplate.isMustSinglePhoto == false) ...[
          PhotoTypeSelectionWidget(
            isDifferentPhoto: isdifferentPhoto,
            onPhotoTypeChanged: (value) =>
                setState(() => isdifferentPhoto = value),
          ),
        ],
        if (widget.videoTemplate.isMustSinglePhoto == true)
          SizedBox(height: 16.h),
        // Photo Upload Section
        PhotoUploadSectionWidget(
          isDifferentPhoto: isdifferentPhoto,
          imageFile1: _imageFile1,
          imageFile2: _imageFile2,
          imageFile3: _imageFile3,
          onImagePicked: _pickImage,
        ),

        SizedBox(height: 4.h),

        // Generate Button

        auth.currentUser?.uid == null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: AuthRequiredWidget(),
              )
            : Column(
                children: [
                  GenerateVideoButtonWidget(
                    videoTemplate: widget.videoTemplate,
                    state: state,
                    isGenerationStarted: _isGenerationStarted,
                    onGeneratePressed: () async {
                      await _generateTemplateVideo(state);
                    },
                    isDifferentPhoto: isdifferentPhoto,
                    imageFile1: _imageFile1,
                    imageFile2: _imageFile2,
                    imageFile3: _imageFile3,
                  ),
                  // Bedava kredi kazan butonu - sadece hasReceivedReviewCredit false ise
                  Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.h,
                      ),
                      child: CustomGradientButton(
                          onTap: () {
                            context.router.push(FreeCreditScreenRoute());
                          },
                          title: AppLocalizations.of(context).earnFreeCredits,
                          isFilled: true))
                ],
              ),
        LayoutConstants.largeEmptyHeight
      ],
    );
  }

  Future<void> _generateTemplateVideo(TemplateGenerateState state) async {
    // Eğer video generation zaten başlatılmışsa, tekrar başlatma
    if (_isGenerationStarted) {
      return;
    }

    // 🔥 FREE USER REVIEW CHECK - 2. video için review zorunluluğu
    final shouldContinue = await _checkReviewRequirementForFreeUsers(context);
    if (!shouldContinue || !context.mounted) return;

    // 💎 PREMIUM TEMPLATE CHECK - Premium template kullanma hakkı kontrolü
    final canUsePremiumTemplate = await _checkPremiumTemplateAccess(context);
    if (!canUsePremiumTemplate || !context.mounted) return;

    setState(() {
      _isGenerationStarted = true;
    });

    if (isdifferentPhoto) {
      await _mergeImages();
      if (_mergedImage != null) {
        final file = await convertUiImageToFile(_mergedImage!, 'merged_image');
        getIt<TemplateGenerateBloc>().add(
          UploadPhotoForTemplateEvent(
            imageFile: file,
            prompt: widget.videoTemplate.prompt,
            negativePrompt: widget.videoTemplate.negativePrompt,
            length: widget.videoTemplate.duration ?? 5,
            aspectRatio: '16:9',
            seed: widget.videoTemplate.seed,
            resolution: widget.videoTemplate.quality ?? '540p',
            style: widget.videoTemplate.style ?? 'auto',
            templateName: widget.videoTemplate.title,
            aiModel: widget.videoTemplate.aiModel,
            effect: widget.videoTemplate.effect,
            templateId: widget.videoTemplate.template_id ?? 0,
          ),
        );
      }
    } else {
      if (_imageFile3 != null) {
        getIt<TemplateGenerateBloc>().add(
          UploadPhotoForTemplateEvent(
            imageFile: _imageFile3!,
            prompt: widget.videoTemplate.prompt,
            negativePrompt: widget.videoTemplate.negativePrompt,
            length: widget.videoTemplate.duration ?? 5,
            aspectRatio: '1:1',
            seed: widget.videoTemplate.seed,
            resolution: widget.videoTemplate.quality ?? '540p',
            style: widget.videoTemplate.style ?? 'auto',
            templateName: widget.videoTemplate.title,
            aiModel: widget.videoTemplate.aiModel,
            effect: widget.videoTemplate.effect,
            templateId: widget.videoTemplate.template_id ?? 0,
          ),
        );
      }
    }
  }

  Future<bool> _requestPermissions() async {
    // ImagePicker kendi izin yönetimini yapıyor, biz hiç izin istemiyoruz
    // Sadece fotoğraf seçme izni yeterli, full access gerekmez
    return true;
  }

  Future<void> _pickImage(int imageNumber) async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    // Loading dialog'u göster
    final progressDialog = CustomProgressDialog(context);
    progressDialog.show();

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      // Dialog'u kapat
      progressDialog.close();

      if (pickedFile == null) return;

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

      final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          maxWidth: 4000,
          maxHeight: 4000,
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

      if (croppedFile == null) return;

      // Maksimum boyut kontrolü yap
      final imageFile = File(croppedFile.path);
      final imageSize = await _getImageSize(imageFile);

      if (imageSize.width > 4000 || imageSize.height > 4000) {
        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).image_size_too_large,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Minimum boyut kontrolü yap ve gerekirse siyah alan ekle
      final paddedFile = await ImageFormatService.ensureMinimumSize(
        imageFile,
        minWidth: 300,
        minHeight: 300,
      );

      if (paddedFile == null) return;

      setState(() {
        if (imageNumber == 1) {
          _imageFile1 = paddedFile;
        } else if (imageNumber == 2) {
          _imageFile2 = paddedFile;
        } else {
          _imageFile3 = paddedFile;
        }
      });

      // 🔥 EKSTRA: Fotoğrafı hemen storage'a yükle ve user_uploaded_files listesine ekle
      _uploadToUserUploadedFiles(paddedFile);
    } catch (e) {
      // Hata durumunda dialog'u kapat
      progressDialog.close();
    }
  }

  Future<void> _mergeImages() async {
    if (_imageFile1 == null || _imageFile2 == null) return;

    final image1 = await _loadUiImage(_imageFile1!);
    final image2 = await _loadUiImage(_imageFile2!);

    const targetHeight = 400.0;
    final aspectRatio1 = image1.width / image1.height;
    final aspectRatio2 = image2.width / image2.height;

    final newWidth1 = targetHeight * aspectRatio1;
    final newWidth2 = targetHeight * aspectRatio2;

    final mergedWidth = (newWidth1 + newWidth2).toInt();

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final paint = Paint();

    // Resim 1 çizimi (sol)
    final src1 =
        Rect.fromLTWH(0, 0, image1.width.toDouble(), image1.height.toDouble());
    final dst1 = Rect.fromLTWH(0, 0, newWidth1, targetHeight);
    canvas.drawImageRect(image1, src1, dst1, paint);

    // Resim 2 çizimi (sağ)
    final src2 =
        Rect.fromLTWH(0, 0, image2.width.toDouble(), image2.height.toDouble());
    final dst2 = Rect.fromLTWH(newWidth1, 0, newWidth2, targetHeight);
    canvas.drawImageRect(image2, src2, dst2, paint);

    final picture = pictureRecorder.endRecording();
    final mergedImage =
        await picture.toImage(mergedWidth, targetHeight.toInt());

    final croppedImage = await cropTo16by9(mergedImage);

    setState(() {
      _mergedImage = croppedImage;
    });
  }

  Future<ui.Image> cropTo16by9(ui.Image image) async {
    final width = image.width;
    final height = image.height;

    final targetWidth = ((height * 16) / 9).toInt();

    if (width == targetWidth) return image;

    final startX =
        ((width - targetWidth) / 2).clamp(0, double.infinity).toInt();

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final originalBytes = byteData!.buffer.asUint8List();

    final decoded = img.decodeImage(originalBytes)!;
    final cropped = img.copyCrop(decoded,
        x: startX, y: 0, width: targetWidth, height: height);

    final croppedBytes = Uint8List.fromList(img.encodePng(cropped));
    final codec = await ui.instantiateImageCodec(croppedBytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> _loadUiImage(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<Size> _getImageSize(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
  }

  Future<File> convertUiImageToFile(ui.Image image, String fileName) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception(AppLocalizations.of(context).image_data_error);
    }

    final buffer = byteData.buffer;
    final uint8List = buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName.png';

    final file = File(filePath);
    await file.writeAsBytes(uint8List);
    return file;
  }

  // 🔥 FREE KULLANICI İÇİN REVIEW ZORUNLULUĞU
  // Returns: true = devam edebilir, false = durdur
  Future<bool> _checkReviewRequirementForFreeUsers(BuildContext context) async {
    try {
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] ========================================');
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Review check STARTED');

      // 🤖 Android için review kontrolünü devre dışı bırak (Play Store politikası)
      if (Platform.isAndroid) {
        debugPrint(
            '🔥 [TEMPLATE-REVIEW-CHECK] Android detected - skipping review requirement (Play Store policy)');
        return true;
      }

      final userId = auth.currentUser?.uid;
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] User ID: $userId');

      if (userId == null) {
        debugPrint(
            '🔥 [TEMPLATE-REVIEW-CHECK] User ID is NULL, returning true');
        return true; // Giriş yapılmamış, devam et
      }

      // 1. Premium kullanıcı mı kontrol et
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Checking subscription status...');
      final hasSubscription = await RevenueCatService.isUserSubscribed();
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] Has Subscription: $hasSubscription');

      if (hasSubscription) {
        debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Premium user, returning true');
        // Premium kullanıcı - review zorunlu değil
        return true;
      }

      // 2. User dokümanını al
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Fetching user document...');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        debugPrint(
            '🔥 [TEMPLATE-REVIEW-CHECK] User document does NOT exist, returning true');
        return true;
      }

      final userData = userDoc.data();
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] User document fetched');

      // 3. Video sayısını kontrol et (userGeneratedVideos array field)
      final videos = userData?['userGeneratedVideos'] as List<dynamic>?;
      final videoCount = videos?.length ?? 0;
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] Video Count (from userGeneratedVideos array): $videoCount');
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Videos array: $videos');

      // Video sayısı 1 değilse (2. video değilse) - geç
      if (videoCount != 1) {
        debugPrint(
            '🔥 [TEMPLATE-REVIEW-CHECK] Video count is NOT 1, returning true');
        return true;
      }

      // 3.5 ⚡ PLAN KONTROLÜ - RevenueCat ile aktif planı kontrol et
      final hasActiveSubscription = await RevenueCatService.isUserSubscribed();
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] Has Active Subscription (RevenueCat): $hasActiveSubscription');

      if (hasActiveSubscription) {
        debugPrint(
            '🔥 [TEMPLATE-REVIEW-CHECK] ✅ User has active plan (RevenueCat), bypassing review requirement');
        return true; // Planı var, review gerekmez
      }

      // 4. Kullanıcı review yapmış mı kontrol et (Free kullanıcılar için)
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] Checking user review credit status...');
      final hasReceivedReviewCredit =
          userData?['profile_info']?['hasReceivedReviewCredit'] ?? false;
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] User Has Received Review Credit: $hasReceivedReviewCredit');

      if (hasReceivedReviewCredit) {
        debugPrint(
            '🔥 [TEMPLATE-REVIEW-CHECK] ✅ User already completed review, returning true');
        return true; // Kullanıcı daha önce review yapmış, devam et
      }

      // 5. Device'dan daha önce review yapıldı mı kontrol et
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Checking device review status...');
      final deviceId = await _getDeviceId();
      final deviceDoc = await FirebaseFirestore.instance
          .collection('device_review_credits')
          .doc(deviceId)
          .get();

      final deviceAlreadyClaimed =
          deviceDoc.exists && deviceDoc.data()?['claimed'] == true;
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] Device Already Claimed: $deviceAlreadyClaimed');

      if (deviceAlreadyClaimed) {
        debugPrint(
            '🔥 [TEMPLATE-REVIEW-CHECK] ✅ Device already claimed, returning true (skip review)');
        return true; // Bu cihazdan daha önce review yapılmış, kullanıcıyı engelleme
      }

      // 6. Hem kullanıcı hem device review yapmamış - Dialog göster
      debugPrint(
          '🔥 [TEMPLATE-REVIEW-CHECK] ⚠️ No review from user or device! Showing dialog...');
      await _showReviewRequiredDialog(context);
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Dialog shown, returning FALSE');
      return false; // Video üretimini durdur
    } catch (e) {
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] ❌❌❌ EXCEPTION: $e');
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Exception Type: ${e.runtimeType}');
      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Stack: ${StackTrace.current}');
      debugPrint('❌ Review check error: $e');

      // Exception göster kullanıcıya
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review check error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }

      debugPrint('🔥 [TEMPLATE-REVIEW-CHECK] Returning TRUE (fail-safe)');
      return true; // Hata durumunda devam et (kullanıcıyı bloklamayalım)
    }
  }

  // Review zorunluluk dialog'u
  Future<void> _showReviewRequiredDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).reviewRequiredTitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).reviewRequiredMessage,
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard,
                        color: Colors.green[700], size: 24),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).reviewRequiredBonus,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    // Direkt review sürecini başlat
                    await _startReviewProcess(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.baseColor,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 18.sp),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context).reviewRequiredButton,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context).cancel,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Review sürecini başlat (Free Credit Screen'deki gibi)
  Future<void> _startReviewProcess(BuildContext context) async {
    try {
      // 1. Kullanıcı kontrolü
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 2. Device kontrolü
      final deviceId = await _getDeviceId();
      final deviceDoc = await FirebaseFirestore.instance
          .collection('device_review_credits')
          .doc(deviceId)
          .get();

      if (deviceDoc.exists && deviceDoc.data()?['claimed'] == true) {
        // Bu cihazdan daha önce review credit alınmış
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .deviceAlreadyClaimedReviewCredit),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 3. Rating dialog göster
      if (!context.mounted) return;
      final rating = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const RatingDialog(),
      );

      if (rating != null && rating >= 3) {
        // 4. Loading dialog göster
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext loadingContext) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: context.baseColor),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).loading_please_wait,
                  ),
                ],
              ),
            );
          },
        );

        // 5. 3 saniye bekle

        // 6. Loading kapat
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // 7. Review dialog'u aç
        final inAppReview = InAppReview.instance;
        final isAvailable = await inAppReview.isAvailable();

        if (isAvailable) {
          await inAppReview.requestReview();
        } else {
          await inAppReview.openStoreListing(appStoreId: '6739088765');
        }
        await Future.delayed(Duration(seconds: 3));

        // 8. Confirmation dialog
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext confirmContext) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context).reviewConfirmationTitle),
                ],
              ),
              content: Text(
                Platform.isIOS
                    ? AppLocalizations.of(context).reviewConfirmationMessageIOS
                    : AppLocalizations.of(context)
                        .reviewConfirmationMessageAndroid,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(confirmContext).pop(false),
                  child: Text(AppLocalizations.of(context).no),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(confirmContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.baseColor,
                  ),
                  child: Text(
                    AppLocalizations.of(context).yesIRated,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );

        // 9. Eğer evet dediyse kredi ekle
        if (confirmed == true && context.mounted) {
          await _addReviewCredit(user.uid, deviceId);
        }
      }
    } catch (e) {
      debugPrint('❌ Review process error: $e');
    }
  }

  // Device ID al
  Future<String> _getDeviceId() async {
    const storage = FlutterSecureStorage();
    const deviceIdKey = 'unique_device_fingerprint';

    try {
      final storedId = await storage.read(key: deviceIdKey);
      if (storedId != null && storedId.isNotEmpty) {
        return storedId;
      }

      final deviceInfo = DeviceInfoPlugin();
      String deviceFingerprint;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final androidId = androidInfo.id ?? 'unknown';
        final model = androidInfo.model ?? 'unknown';
        final brand = androidInfo.brand ?? 'unknown';
        deviceFingerprint = 'android_${androidId}_${brand}_$model';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final idfv = iosInfo.identifierForVendor ?? 'unknown';
        final model = iosInfo.model ?? 'unknown';
        deviceFingerprint = 'ios_${idfv}_$model';
      } else {
        final uniqueId = const Uuid().v4();
        deviceFingerprint = 'unknown_$uniqueId';
      }

      await storage.write(key: deviceIdKey, value: deviceFingerprint);
      return deviceFingerprint;
    } catch (e) {
      debugPrint('❌ Error getting device ID: $e');
      final fallbackId =
          'fallback_${const Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}';
      return fallbackId;
    }
  }

  // 🔥 EKSTRA: Fotoğrafı hemen storage'a yükle ve user_uploaded_files listesine ekle
  Future<void> _uploadToUserUploadedFiles(File imageFile) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      // Firebase Storage'a yükle
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child(
          "user_uploaded_files/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);
      final url = await uploadTask.ref.getDownloadURL();

      // Firestore'da user_uploaded_files listesine ekle
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).update({
        'user_uploaded_files': FieldValue.arrayUnion([url])
      });

      debugPrint('✅ Fotoğraf user_uploaded_files listesine eklendi: $url');
    } catch (e) {
      debugPrint('❌ user_uploaded_files yüklenirken hata: $e');
      // Hata olsa bile kullanıcı deneyimini etkilemesin
    }
  }

  // 💎 PREMIUM TEMPLATE KULLANMA HAKKI KONTROLÜ
  // Returns: true = kullanabilir, false = kullanamaz (payment ekranına yönlendir)
  Future<bool> _checkPremiumTemplateAccess(BuildContext context) async {
    try {
      // 1. Template premium mi kontrol et
      final isPremiumTemplate = widget.videoTemplate.isPremiumTemplate ?? false;

      if (!isPremiumTemplate) {
        return true; // Premium template değilse, direkt devam et
      }

      // 2. Kullanıcının aboneliği var mı kontrol et
      final hasSubscription = await RevenueCatService.isUserSubscribed();

      if (hasSubscription) {
        return true; // Abonelik varsa, premium template'i sınırsız kullanabilir
      }

      // 3. Kullanıcı daha önce premium template kullanmış mı kontrol et
      final userId = auth.currentUser?.uid;
      if (userId == null) {
        debugPrint(
            '💎 [PREMIUM-TEMPLATE-CHECK] User ID is NULL, returning true');
        return true;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        debugPrint(
            '💎 [PREMIUM-TEMPLATE-CHECK] User document does NOT exist, returning true');
        return true;
      }

      final userData = userDoc.data();
      final hasUsedPremiumTemplate =
          userData?['profile_info']?['user_used_premium_template'] ?? false;

      debugPrint(
          '💎 [PREMIUM-TEMPLATE-CHECK] Has Used Premium Template: $hasUsedPremiumTemplate');

      if (!hasUsedPremiumTemplate) {
        debugPrint(
            '💎 [PREMIUM-TEMPLATE-CHECK] ✅ User has NOT used premium template before, allowing 1 free use');

        // 🎁 İlk kez kullanıyorsa, kullanma hakkını tüket
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profile_info.user_used_premium_template': true});

        debugPrint(
            '💎 [PREMIUM-TEMPLATE-CHECK] ✅ Premium template usage marked as used');
        return true; // İlk kez kullanıyorsa, izin ver
      }

      // 4. Kullanıcı daha önce kullanmış ve aboneliği yok -> Payment ekranına yönlendir
      debugPrint(
          '💎 [PREMIUM-TEMPLATE-CHECK] ❌ User already used premium template and has no subscription');
      debugPrint('💎 [PREMIUM-TEMPLATE-CHECK] Showing payment dialog...');

      if (context.mounted) {
        await _showPremiumTemplateDialog(context);
      }

      return false; // Kullanamaz
    } catch (e) {
      debugPrint('❌ [PREMIUM-TEMPLATE-CHECK] Error: $e');
      return true; // Hata durumunda kullanıcıyı bloklamayalım
    }
  }

  // 💎 Premium Template Dialog - Abonelik/Kredi paketi satın alması gerektiğini göster
  Future<void> _showPremiumTemplateDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).premiumTemplateTitle,
                  style: TextStyle(
                    fontSize: 20.sp,
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
                AppLocalizations.of(context).premiumTemplateUsedMessage,
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 24),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).unlimitedUsage,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).premiumTemplateUnlimitedInfo,
                      style: TextStyle(fontSize: 13.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.router.push(PaymentsScreenRoute());
                  },
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context).buySubscriptionOrCredits,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.baseColor,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context).continueWithOtherTemplates,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Review credit ekle (Cloud Function çağır)
  Future<void> _addReviewCredit(String userId, String deviceId) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('claimReviewCredit');
      final result = await callable.call({
        'deviceId': deviceId,
        'rating': 5,
      });

      if (result.data['success'] == true && context.mounted) {
        final creditAmount = result.data['creditAmount'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(creditAmount > 0
                ? '🌟 ${AppLocalizations.of(context).reviewThanksWithCredit}'
                : AppLocalizations.of(context).reviewCompletedNoCredit),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Profile refresh
        getIt<ProfileBloc>().add(FetchProfileInfoEvent(userId));
      }
    } catch (e) {
      debugPrint('❌ Error adding review credit: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kredi eklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
