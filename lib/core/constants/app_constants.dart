import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle için
import 'package:flutter/widgets.dart';
import 'package:comby/generated/l10n.dart';
import 'package:image_cropper/image_cropper.dart';

/// STORAGE KEYS
const String authTokenKey = "authToken";
const String refreshTokenKey = "refreshToken";
const String themeMode = "themeMode";
String languageLocale = const Locale('tr').languageCode;
const String passwordRegex = r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$";

const appId = "0bf81f0a52cf49109bba64ccb59070da";
const geminiApiKey = "AIzaSyACsjR_d1kwVClwXUkITExCeO8KyzVtn0Y";
const togetherApiUrl = 'https://api.together.xyz/v1/images/generations';
const togetherAPiKey =
    "df1fd62679c42ef1345d7bba0ead56fd4b18f078d50007fb2e87d8f03f890b11";
const String errorImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/ginowl-ginfit.firebasestorage.app/o/core%2FSomeThings_went_wrong-removebg-preview.png?alt=media&token=d490cc69-d7c0-4a9a-97b9-fac552076f5c';
const String addPhotoImageUrl =
    "https://firebasestorage.googleapis.com/v0/b/ginowl-ginfit.firebasestorage.app/o/core%2F791768-middle-removebg-preview.png?alt=media&token=e0ef1a01-fe7a-4a57-8f92-d112a76ba7bf";

const String polloApiKey = "pollo_uvWmiCMlETsiV9zykDO1TMbzx6zB2l02ibozPb1s9yEy";
const String falAiApiKey =
    "5b24d2fb-ed5d-473e-a5e7-f339cfb6fe40:7d0e42fc249d678cfbab8fb2c4b213e0"; // Fal.ai API key'ini buraya ekleyin
const String pixverseOriginalApiKey =
    "sk-5e85c415c778470cde912f0f684526f6"; // Pixverse Original API key

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
