import 'package:flutter/material.dart';
import 'package:comby/generated/l10n.dart';
import 'package:image_cropper/image_cropper.dart';

/// STORAGE KEYS
const String authTokenKey = "authToken";
const String refreshTokenKey = "refreshToken";
const String themeMode = "themeMode";
String languageLocale = const Locale('tr').languageCode;
const String passwordRegex = r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$";
const geminiApiKey = "AIzaSyAf9A5aK2dNOjhUxi_L9tmv8E5_Y6HAQlQ";
const String falAiApiKey =
    "5b24d2fb-ed5d-473e-a5e7-f339cfb6fe40:7d0e42fc249d678cfbab8fb2c4b213e0"; // Fal.ai API key'ini buraya ekleyin

List<PlatformUiSettings>? cropperUiSettings = [
  AndroidUiSettings(
    lockAspectRatio: false, // Kullanıcı istediği gibi crop yapabilir
    toolbarTitle: AppLocalizations.current.crop_image,
    toolbarColor: Color(0xFF2F2B52),

    activeControlsWidgetColor: Color(0xFF2F2B52),

    toolbarWidgetColor: Colors.white,
    backgroundColor: Color(0xFF2F2B52),
    cropFrameColor: Color(0xFF2F2B52),
    cropGridColor: Color(0xFF2F2B52).withOpacity(0.5),

    showCropGrid: false,
    statusBarColor: Color(0xFF2F2B52),
    hideBottomControls: false, // butonlar görünür
    initAspectRatio: CropAspectRatioPreset.original,
    // SAFE AREA AYARLARI - Eski Android cihazlar için
    // Status bar ve navigation bar renklerini ayarla
    aspectRatioPresets: [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio16x9,
      CropAspectRatioPreset.ratio5x3,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
    ],
  ),
  IOSUiSettings(
    title: AppLocalizations.current.crop_image,
    doneButtonTitle: AppLocalizations.current.crop_image_done,
    cancelButtonTitle: AppLocalizations.current.crop_image_cancel,
    rotateButtonsHidden: false,
    rotateClockwiseButtonHidden: false,
    minimumAspectRatio: 0.25,
    resetAspectRatioEnabled: true,

    aspectRatioPickerButtonHidden: false, // preset seçim butonu
    resetButtonHidden: false, // kullanıcı istediği zaman resetleyebilir
    aspectRatioLockEnabled: false, // serbest crop
    aspectRatioPresets: [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio16x9,
      CropAspectRatioPreset.ratio5x3,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
    ],
  ),
];
