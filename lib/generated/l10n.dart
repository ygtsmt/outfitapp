// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(_current != null,
        'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(instance != null,
        'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?');
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Account Information`
  String get accountInformation {
    return Intl.message(
      'Account Information',
      name: 'accountInformation',
      desc: '',
      args: [],
    );
  }

  /// `This email address is already associated with a different login method.`
  String get account_exists_with_different_credential {
    return Intl.message(
      'This email address is already associated with a different login method.',
      name: 'account_exists_with_different_credential',
      desc: '',
      args: [],
    );
  }

  /// `AI Video Generation`
  String get ai_video_generation {
    return Intl.message(
      'AI Video Generation',
      name: 'ai_video_generation',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get and {
    return Intl.message(
      'and',
      name: 'and',
      desc: '',
      args: [],
    );
  }

  /// `Anime Style`
  String get anime_style {
    return Intl.message(
      'Anime Style',
      name: 'anime_style',
      desc: '',
      args: [],
    );
  }

  /// `Japanese anime art style`
  String get anime_style_description {
    return Intl.message(
      'Japanese anime art style',
      name: 'anime_style_description',
      desc: '',
      args: [],
    );
  }

  /// `App Settings`
  String get app_settings {
    return Intl.message(
      'App Settings',
      name: 'app_settings',
      desc: '',
      args: [],
    );
  }

  /// `Aspect Ratio`
  String get aspectRatio {
    return Intl.message(
      'Aspect Ratio',
      name: 'aspectRatio',
      desc: '',
      args: [],
    );
  }

  /// `Aspect Ratio`
  String get aspect_ratio {
    return Intl.message(
      'Aspect Ratio',
      name: 'aspect_ratio',
      desc: '',
      args: [],
    );
  }

  /// `Auction`
  String get auction {
    return Intl.message(
      'Auction',
      name: 'auction',
      desc: '',
      args: [],
    );
  }

  /// `Auto-renewable, cancel anytime`
  String get autoRenewable {
    return Intl.message(
      'Auto-renewable, cancel anytime',
      name: 'autoRenewable',
      desc: '',
      args: [],
    );
  }

  /// `Auto Style`
  String get auto_style {
    return Intl.message(
      'Auto Style',
      name: 'auto_style',
      desc: '',
      args: [],
    );
  }

  /// `Automatic style selection for best results`
  String get auto_style_description {
    return Intl.message(
      'Automatic style selection for best results',
      name: 'auto_style_description',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back_to_login {
    return Intl.message(
      'Back',
      name: 'back_to_login',
      desc: '',
      args: [],
    );
  }

  /// `(Beginning of video)`
  String get beginning_of_video {
    return Intl.message(
      '(Beginning of video)',
      name: 'beginning_of_video',
      desc: '',
      args: [],
    );
  }

  /// `BEST VALUE`
  String get bestValue {
    return Intl.message(
      'BEST VALUE',
      name: 'bestValue',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_password {
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Claim Earned Credits`
  String get claim_earned_credits {
    return Intl.message(
      'Claim Earned Credits',
      name: 'claim_earned_credits',
      desc: '',
      args: [],
    );
  }

  /// `Clay Style`
  String get clay_style {
    return Intl.message(
      'Clay Style',
      name: 'clay_style',
      desc: '',
      args: [],
    );
  }

  /// `Claymation art style`
  String get clay_style_description {
    return Intl.message(
      'Claymation art style',
      name: 'clay_style_description',
      desc: '',
      args: [],
    );
  }

  /// `Comic Style`
  String get comic_style {
    return Intl.message(
      'Comic Style',
      name: 'comic_style',
      desc: '',
      args: [],
    );
  }

  /// `Comic book art style`
  String get comic_style_description {
    return Intl.message(
      'Comic book art style',
      name: 'comic_style_description',
      desc: '',
      args: [],
    );
  }

  /// `Oops! Something went wrong!`
  String get common_error {
    return Intl.message(
      'Oops! Something went wrong!',
      name: 'common_error',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get confirm_password_error {
    return Intl.message(
      'Passwords do not match',
      name: 'confirm_password_error',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      desc: '',
      args: [],
    );
  }

  /// `Create Image`
  String get createImage {
    return Intl.message(
      'Create Image',
      name: 'createImage',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in the form below to create an account`
  String get create_account_form {
    return Intl.message(
      'Please fill in the form below to create an account',
      name: 'create_account_form',
      desc: '',
      args: [],
    );
  }

  /// `Restore Purchases`
  String get restorePurchases {
    return Intl.message(
      'Restore Purchases',
      name: 'restorePurchases',
      desc: '',
      args: [],
    );
  }

  /// `Purchases restored successfully!`
  String get restorePurchasesSuccess {
    return Intl.message(
      'Purchases restored successfully!',
      name: 'restorePurchasesSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No purchases found to restore.`
  String get restorePurchasesEmpty {
    return Intl.message(
      'No purchases found to restore.',
      name: 'restorePurchasesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Failed to restore purchases. Please try again.`
  String get restorePurchasesError {
    return Intl.message(
      'Failed to restore purchases. Please try again.',
      name: 'restorePurchasesError',
      desc: '',
      args: [],
    );
  }

  /// `Create videos with your prompt and image`
  String get create_videos_with_prompt_and_image {
    return Intl.message(
      'Create videos with your prompt and image',
      name: 'create_videos_with_prompt_and_image',
      desc: '',
      args: [],
    );
  }

  /// `Created at`
  String get createdAt {
    return Intl.message(
      'Created at',
      name: 'createdAt',
      desc: '',
      args: [],
    );
  }

  /// `This credential is already in use by another account.`
  String get credential_already_in_use {
    return Intl.message(
      'This credential is already in use by another account.',
      name: 'credential_already_in_use',
      desc: '',
      args: [],
    );
  }

  /// `credit`
  String get credit {
    return Intl.message(
      'credit',
      name: 'credit',
      desc: '',
      args: [],
    );
  }

  /// `Credits earned`
  String get creditEarned {
    return Intl.message(
      'Credits earned',
      name: 'creditEarned',
      desc: '',
      args: [],
    );
  }

  /// `credits pack/week`
  String get creditsPackPerWeek {
    return Intl.message(
      'credits pack/week',
      name: 'creditsPackPerWeek',
      desc: '',
      args: [],
    );
  }

  /// `Earned credits have been added to your account!`
  String get credits_added_successfully {
    return Intl.message(
      'Earned credits have been added to your account!',
      name: 'credits_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Crop`
  String get crop_image {
    return Intl.message(
      'Crop',
      name: 'crop_image',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get crop_image_done {
    return Intl.message(
      'Done',
      name: 'crop_image_done',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get crop_image_cancel {
    return Intl.message(
      'Cancel',
      name: 'crop_image_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get crop_image_reset {
    return Intl.message(
      'Reset',
      name: 'crop_image_reset',
      desc: '',
      args: [],
    );
  }

  /// `Rotate`
  String get crop_image_rotate {
    return Intl.message(
      'Rotate',
      name: 'crop_image_rotate',
      desc: '',
      args: [],
    );
  }

  /// `Flip`
  String get crop_image_flip {
    return Intl.message(
      'Flip',
      name: 'crop_image_flip',
      desc: '',
      args: [],
    );
  }

  /// `Rotate Left`
  String get crop_image_rotate_left {
    return Intl.message(
      'Rotate Left',
      name: 'crop_image_rotate_left',
      desc: '',
      args: [],
    );
  }

  /// `Rotate Right`
  String get crop_image_rotate_right {
    return Intl.message(
      'Rotate Right',
      name: 'crop_image_rotate_right',
      desc: '',
      args: [],
    );
  }

  /// `Flip Horizontal`
  String get crop_image_flip_horizontal {
    return Intl.message(
      'Flip Horizontal',
      name: 'crop_image_flip_horizontal',
      desc: '',
      args: [],
    );
  }

  /// `Flip Vertical`
  String get crop_image_flip_vertical {
    return Intl.message(
      'Flip Vertical',
      name: 'crop_image_flip_vertical',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get current_password {
    return Intl.message(
      'Current Password',
      name: 'current_password',
      desc: '',
      args: [],
    );
  }

  /// `Custom Create`
  String get customCreate {
    return Intl.message(
      'Custom Create',
      name: 'customCreate',
      desc: '',
      args: [],
    );
  }

  /// `Cyberpunk Style`
  String get cyberpunk_style {
    return Intl.message(
      'Cyberpunk Style',
      name: 'cyberpunk_style',
      desc: '',
      args: [],
    );
  }

  /// `Futuristic cyberpunk aesthetic`
  String get cyberpunk_style_description {
    return Intl.message(
      'Futuristic cyberpunk aesthetic',
      name: 'cyberpunk_style_description',
      desc: '',
      args: [],
    );
  }

  /// `Daily ad credits earned. Come back tomorrow to watch more ads`
  String get daily_ads_earned {
    return Intl.message(
      'Daily ad credits earned. Come back tomorrow to watch more ads',
      name: 'daily_ads_earned',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message(
      'Dark Mode',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Describe what you want to see...`
  String get describeWhatYouWantToSee {
    return Intl.message(
      'Describe what you want to see...',
      name: 'describeWhatYouWantToSee',
      desc: '',
      args: [],
    );
  }

  /// `Describe the video you want to create...`
  String get describe_video_hint {
    return Intl.message(
      'Describe the video you want to create...',
      name: 'describe_video_hint',
      desc: '',
      args: [],
    );
  }

  /// `Describe Your Video`
  String get describe_your_video {
    return Intl.message(
      'Describe Your Video',
      name: 'describe_your_video',
      desc: '',
      args: [],
    );
  }

  /// `Earn Credits`
  String get earn_credits {
    return Intl.message(
      'Earn Credits',
      name: 'earn_credits',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Edit Username`
  String get editUsername {
    return Intl.message(
      'Edit Username',
      name: 'editUsername',
      desc: '',
      args: [],
    );
  }

  /// `Effect`
  String get effect {
    return Intl.message(
      'Effect',
      name: 'effect',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `This email address is already in use by another account.`
  String get email_already_in_use {
    return Intl.message(
      'This email address is already in use by another account.',
      name: 'email_already_in_use',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get email_error {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'email_error',
      desc: '',
      args: [],
    );
  }

  /// `Please fill out this field.`
  String get empty_error {
    return Intl.message(
      'Please fill out this field.',
      name: 'empty_error',
      desc: '',
      args: [],
    );
  }

  /// `(End of video)`
  String get end_of_video {
    return Intl.message(
      '(End of video)',
      name: 'end_of_video',
      desc: '',
      args: [],
    );
  }

  /// `Enter new username`
  String get enterNewUsername {
    return Intl.message(
      'Enter new username',
      name: 'enterNewUsername',
      desc: '',
      args: [],
    );
  }

  /// `Enter your report reason...`
  String get enterReportReason {
    return Intl.message(
      'Enter your report reason...',
      name: 'enterReportReason',
      desc: '',
      args: [],
    );
  }

  /// `Enter your e-mail address`
  String get enterYourEmail {
    return Intl.message(
      'Enter your e-mail address',
      name: 'enterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Error loading PDF`
  String get errorLoadingPdf {
    return Intl.message(
      'Error loading PDF',
      name: 'errorLoadingPdf',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred, credit could not be added.`
  String get error_adding_credit {
    return Intl.message(
      'An error occurred, credit could not be added.',
      name: 'error_adding_credit',
      desc: '',
      args: [],
    );
  }

  /// `Fast Mode`
  String get fast_mode {
    return Intl.message(
      'Fast Mode',
      name: 'fast_mode',
      desc: '',
      args: [],
    );
  }

  /// `Fast mode is not compatible with 1080p resolution or 8s video length`
  String get fast_mode_incompatible {
    return Intl.message(
      'Fast mode is not compatible with 1080p resolution or 8s video length',
      name: 'fast_mode_incompatible',
      desc: '',
      args: [],
    );
  }

  /// `Faster generation with optimized quality`
  String get fast_mode_description {
    return Intl.message(
      'Faster generation with optimized quality',
      name: 'fast_mode_description',
      desc: '',
      args: [],
    );
  }

  /// `Faster generation speed`
  String get fasterGenerationSpeed {
    return Intl.message(
      'Faster generation speed',
      name: 'fasterGenerationSpeed',
      desc: '',
      args: [],
    );
  }

  /// `First Person`
  String get firstPerson {
    return Intl.message(
      'First Person',
      name: 'firstPerson',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot your password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Free`
  String get freePlan {
    return Intl.message(
      'Free',
      name: 'freePlan',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get full_name {
    return Intl.message(
      'Full Name',
      name: 'full_name',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Generate`
  String get generate {
    return Intl.message(
      'Generate',
      name: 'generate',
      desc: '',
      args: [],
    );
  }

  /// `Generate images instantly`
  String get generateImagesInstantly {
    return Intl.message(
      'Generate images instantly',
      name: 'generateImagesInstantly',
      desc: '',
      args: [],
    );
  }

  /// `Generate realtime images`
  String get generateRealtimeImages {
    return Intl.message(
      'Generate realtime images',
      name: 'generateRealtimeImages',
      desc: '',
      args: [],
    );
  }

  /// `Generate your first image`
  String get generateYourFirstImage {
    return Intl.message(
      'Generate your first image',
      name: 'generateYourFirstImage',
      desc: '',
      args: [],
    );
  }

  /// `Generate your first video`
  String get generateYourFirstVideo {
    return Intl.message(
      'Generate your first video',
      name: 'generateYourFirstVideo',
      desc: '',
      args: [],
    );
  }

  /// `Generate with Pollo 1.6`
  String get generate_with_pollo {
    return Intl.message(
      'Generate with Pollo 1.6',
      name: 'generate_with_pollo',
      desc: '',
      args: [],
    );
  }

  /// `GET A PREMIUM 🔱`
  String get getPremium {
    return Intl.message(
      'GET A PREMIUM 🔱',
      name: 'getPremium',
      desc: '',
      args: [],
    );
  }

  /// `Single Photo`
  String get group_photo {
    return Intl.message(
      'Single Photo',
      name: 'group_photo',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get high_quality {
    return Intl.message(
      'High',
      name: 'high_quality',
      desc: '',
      args: [],
    );
  }

  /// `I have read and agreed to the`
  String get iHaveReadAndAgreedTo {
    return Intl.message(
      'I have read and agreed to the',
      name: 'iHaveReadAndAgreedTo',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Image Details`
  String get imageDetails {
    return Intl.message(
      'Image Details',
      name: 'imageDetails',
      desc: '',
      args: [],
    );
  }

  /// `Image data could not be retrieved`
  String get image_data_error {
    return Intl.message(
      'Image data could not be retrieved',
      name: 'image_data_error',
      desc: '',
      args: [],
    );
  }

  /// `Image to Video`
  String get image_to_video {
    return Intl.message(
      'Image to Video',
      name: 'image_to_video',
      desc: '',
      args: [],
    );
  }

  /// `Images`
  String get images {
    return Intl.message(
      'Images',
      name: 'images',
      desc: '',
      args: [],
    );
  }

  /// `One Time Purchase`
  String get oneTimePurchase {
    return Intl.message(
      'One Time Purchase',
      name: 'oneTimePurchase',
      desc: '',
      args: [],
    );
  }

  /// `Price Not Available`
  String get priceNotAvailable {
    return Intl.message(
      'Price Not Available',
      name: 'priceNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Extra Credit Packages`
  String get extraCreditPackages {
    return Intl.message(
      'Extra Credit Packages',
      name: 'extraCreditPackages',
      desc: '',
      args: [],
    );
  }

  /// `Subscriptions`
  String get subscriptions {
    return Intl.message(
      'Subscriptions',
      name: 'subscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get creditPackages {
    return Intl.message(
      'Credits',
      name: 'creditPackages',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get credits {
    return Intl.message(
      'Credits',
      name: 'credits',
      desc: '',
      args: [],
    );
  }

  /// `Plans`
  String get plans {
    return Intl.message(
      'Plans',
      name: 'plans',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Now`
  String get purchaseNow {
    return Intl.message(
      'Purchase Now',
      name: 'purchaseNow',
      desc: '',
      args: [],
    );
  }

  /// `One Time`
  String get oneTime {
    return Intl.message(
      'One Time',
      name: 'oneTime',
      desc: '',
      args: [],
    );
  }

  /// `Non-renewable`
  String get nonRenewable {
    return Intl.message(
      'Non-renewable',
      name: 'nonRenewable',
      desc: '',
      args: [],
    );
  }

  /// `You have already used your trial package. You can continue by purchasing a subscription.`
  String get trialPackageUsed {
    return Intl.message(
      'You have already used your trial package. You can continue by purchasing a subscription.',
      name: 'trialPackageUsed',
      desc: '',
      args: [],
    );
  }

  /// `Packages loading...`
  String get packagesLoading {
    return Intl.message(
      'Packages loading...',
      name: 'packagesLoading',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Subscription`
  String get goToSubscriptions {
    return Intl.message(
      'Purchase Subscription',
      name: 'goToSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Purchase`
  String get purchase {
    return Intl.message(
      'Purchase',
      name: 'purchase',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load user information`
  String get userInfoLoadError {
    return Intl.message(
      'Failed to load user information',
      name: 'userInfoLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Credits added successfully!`
  String get creditsAddedSuccessfully {
    return Intl.message(
      'Credits added successfully!',
      name: 'creditsAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Purchase failed. Please try again.`
  String get purchaseFailed {
    return Intl.message(
      'Purchase failed. Please try again.',
      name: 'purchaseFailed',
      desc: '',
      args: [],
    );
  }

  /// `Image Templates`
  String get imageTemplates {
    return Intl.message(
      'Image Templates',
      name: 'imageTemplates',
      desc: '',
      args: [],
    );
  }

  /// `All Images`
  String get allImages {
    return Intl.message(
      'All Images',
      name: 'allImages',
      desc: '',
      args: [],
    );
  }

  /// `No user data found`
  String get noUserDataFound {
    return Intl.message(
      'No user data found',
      name: 'noUserDataFound',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String errorOccurred(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'errorOccurred',
      desc: '',
      args: [error],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get fileSize {
    return Intl.message(
      'Size',
      name: 'fileSize',
      desc: '',
      args: [],
    );
  }

  /// `Account deletion error`
  String get accountDeletionError {
    return Intl.message(
      'Account deletion error',
      name: 'accountDeletionError',
      desc: '',
      args: [],
    );
  }

  /// `Username updated successfully`
  String get usernameUpdatedSuccessfully {
    return Intl.message(
      'Username updated successfully',
      name: 'usernameUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Image deleted successfully`
  String get imageDeletedSuccessfully {
    return Intl.message(
      'Image deleted successfully',
      name: 'imageDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Report sent successfully!`
  String get reportSentSuccessfully {
    return Intl.message(
      'Report sent successfully!',
      name: 'reportSentSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Very soon!`
  String get verySoon {
    return Intl.message(
      'Very soon!',
      name: 'verySoon',
      desc: '',
      args: [],
    );
  }

  /// `Purchase successful! Credits will be added shortly.`
  String get purchaseSuccessful {
    return Intl.message(
      'Purchase successful! Credits will be added shortly.',
      name: 'purchaseSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Input Image`
  String get inputImage {
    return Intl.message(
      'Input Image',
      name: 'inputImage',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient credit`
  String get insufficient_credit {
    return Intl.message(
      'Insufficient credit',
      name: 'insufficient_credit',
      desc: '',
      args: [],
    );
  }

  /// `Invalid credential. Please try again.`
  String get invalid_credential {
    return Intl.message(
      'Invalid credential. Please try again.',
      name: 'invalid_credential',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address.`
  String get invalid_email {
    return Intl.message(
      'Invalid email address.',
      name: 'invalid_email',
      desc: '',
      args: [],
    );
  }

  /// `The verification code is invalid. Please enter the correct code and try again.`
  String get invalid_verification_code {
    return Intl.message(
      'The verification code is invalid. Please enter the correct code and try again.',
      name: 'invalid_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `The verification ID is invalid. Try restarting the process.`
  String get invalid_verification_id {
    return Intl.message(
      'The verification ID is invalid. Try restarting the process.',
      name: 'invalid_verification_id',
      desc: '',
      args: [],
    );
  }

  /// `To protect your legal rights, please read and agree to our`
  String get legal_notice {
    return Intl.message(
      'To protect your legal rights, please read and agree to our',
      name: 'legal_notice',
      desc: '',
      args: [],
    );
  }

  /// `Length`
  String get length {
    return Intl.message(
      'Length',
      name: 'length',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get library {
    return Intl.message(
      'Library',
      name: 'library',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Loading, please wait...`
  String get loading_please_wait {
    return Intl.message(
      'Loading, please wait...',
      name: 'loading_please_wait',
      desc: '',
      args: [],
    );
  }

  /// `Preparing credit information`
  String get preparing_credit_info {
    return Intl.message(
      'Preparing credit information',
      name: 'preparing_credit_info',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Best Price`
  String get bestPrice {
    return Intl.message(
      'Best Price',
      name: 'bestPrice',
      desc: '',
      args: [],
    );
  }

  /// `Premium Plan`
  String get premiumPlan {
    return Intl.message(
      'Premium Plan',
      name: 'premiumPlan',
      desc: '',
      args: [],
    );
  }

  /// `8s video and fast mode not supports 1080p resolution`
  String get length_resolution_incompatible {
    return Intl.message(
      '8s video and fast mode not supports 1080p resolution',
      name: 'length_resolution_incompatible',
      desc: '',
      args: [],
    );
  }

  /// `Image aspect ratio must be between 1:4 and 4:1 (0.25 to 4.0)`
  String get image_aspect_ratio_invalid {
    return Intl.message(
      'Image aspect ratio must be between 1:4 and 4:1 (0.25 to 4.0)',
      name: 'image_aspect_ratio_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Cropped`
  String get cropped {
    return Intl.message(
      'Cropped',
      name: 'cropped',
      desc: '',
      args: [],
    );
  }

  /// `All Effects`
  String get allEffects {
    return Intl.message(
      'All Effects',
      name: 'allEffects',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Category`
  String get filterByCategory {
    return Intl.message(
      'Filter by Category',
      name: 'filterByCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select All`
  String get selectAll {
    return Intl.message(
      'Select All',
      name: 'selectAll',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clearAll {
    return Intl.message(
      'Clear All',
      name: 'clearAll',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `No Effects Found`
  String get noEffectsFound {
    return Intl.message(
      'No Effects Found',
      name: 'noEffectsFound',
      desc: '',
      args: [],
    );
  }

  /// `Categories Effects`
  String get categoriesEffects {
    return Intl.message(
      'Categories Effects',
      name: 'categoriesEffects',
      desc: '',
      args: [],
    );
  }

  /// `Show More`
  String get showMore {
    return Intl.message(
      'Show More',
      name: 'showMore',
      desc: '',
      args: [],
    );
  }

  /// `Show All Effects`
  String get showAllEffects {
    return Intl.message(
      'Show All Effects',
      name: 'showAllEffects',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Rate Us`
  String get rateUs {
    return Intl.message(
      'Rate Us',
      name: 'rateUs',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `We'd love to hear your thoughts! Share your feedback, suggestions, or report any issues you've encountered.`
  String get feedbackDescription {
    return Intl.message(
      'We\'d love to hear your thoughts! Share your feedback, suggestions, or report any issues you\'ve encountered.',
      name: 'feedbackDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tell us what you think about the app, what features you'd like to see, or any problems you've experienced...`
  String get feedbackHint {
    return Intl.message(
      'Tell us what you think about the app, what features you\'d like to see, or any problems you\'ve experienced...',
      name: 'feedbackHint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your feedback`
  String get feedbackRequired {
    return Intl.message(
      'Please enter your feedback',
      name: 'feedbackRequired',
      desc: '',
      args: [],
    );
  }

  /// `Feedback must be at least 10 characters long`
  String get feedbackMinLength {
    return Intl.message(
      'Feedback must be at least 10 characters long',
      name: 'feedbackMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Submit Feedback`
  String get submitFeedback {
    return Intl.message(
      'Submit Feedback',
      name: 'submitFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Thank you! Your feedback has been submitted successfully.`
  String get feedbackSubmitted {
    return Intl.message(
      'Thank you! Your feedback has been submitted successfully.',
      name: 'feedbackSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Add Image (Optional)`
  String get addImageOptional {
    return Intl.message(
      'Add Image (Optional)',
      name: 'addImageOptional',
      desc: '',
      args: [],
    );
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Loading PDF...`
  String get loadingPdf {
    return Intl.message(
      'Loading PDF...',
      name: 'loadingPdf',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your credentials to login.`
  String get loginDescription {
    return Intl.message(
      'Please enter your credentials to login.',
      name: 'loginDescription',
      desc: '',
      args: [],
    );
  }

  /// `login`
  String get loginTitle {
    return Intl.message(
      'login',
      name: 'loginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get logout_confirmation {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logout_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `You are using a guest account. If you logout, all your data will be lost permanently!`
  String get guest_logout_warning {
    return Intl.message(
      'You are using a guest account. If you logout, all your data will be lost permanently!',
      name: 'guest_logout_warning',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Long Video`
  String get long_video {
    return Intl.message(
      'Long Video',
      name: 'long_video',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get low_quality {
    return Intl.message(
      'Low',
      name: 'low_quality',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get medium_quality {
    return Intl.message(
      'Medium',
      name: 'medium_quality',
      desc: '',
      args: [],
    );
  }

  /// `Min 6 chars`
  String get min_6_chars {
    return Intl.message(
      'Min 6 chars',
      name: 'min_6_chars',
      desc: '',
      args: [],
    );
  }

  /// `The verification code is missing. Please enter the code.`
  String get missing_verification_code {
    return Intl.message(
      'The verification code is missing. Please enter the code.',
      name: 'missing_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `The verification ID is missing. Try restarting the process.`
  String get missing_verification_id {
    return Intl.message(
      'The verification ID is missing. Try restarting the process.',
      name: 'missing_verification_id',
      desc: '',
      args: [],
    );
  }

  /// `Mode`
  String get mode {
    return Intl.message(
      'Mode',
      name: 'mode',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Plan`
  String get monthlyPlan {
    return Intl.message(
      'Monthly Plan',
      name: 'monthlyPlan',
      desc: '',
      args: [],
    );
  }

  /// `Motion Mode`
  String get motionMode {
    return Intl.message(
      'Motion Mode',
      name: 'motionMode',
      desc: '',
      args: [],
    );
  }

  /// `Negative Prompt`
  String get negative_prompt {
    return Intl.message(
      'Negative Prompt',
      name: 'negative_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Describe what you don't want in the video (optional)`
  String get negative_prompt_hint {
    return Intl.message(
      'Describe what you don\'t want in the video (optional)',
      name: 'negative_prompt_hint',
      desc: '',
      args: [],
    );
  }

  /// `Network connection failed. Please check your internet connection.`
  String get network_request_failed {
    return Intl.message(
      'Network connection failed. Please check your internet connection.',
      name: 'network_request_failed',
      desc: '',
      args: [],
    );
  }

  /// `New Username`
  String get newUsername {
    return Intl.message(
      'New Username',
      name: 'newUsername',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `You haven't generated any image yet`
  String get noImageGenerated {
    return Intl.message(
      'You haven\'t generated any image yet',
      name: 'noImageGenerated',
      desc: '',
      args: [],
    );
  }

  /// `No image to share`
  String get noImageToShare {
    return Intl.message(
      'No image to share',
      name: 'noImageToShare',
      desc: '',
      args: [],
    );
  }

  /// `This account was not logged in with a password, the password cannot be changed`
  String get noPasswordChange {
    return Intl.message(
      'This account was not logged in with a password, the password cannot be changed',
      name: 'noPasswordChange',
      desc: '',
      args: [],
    );
  }

  /// `You haven't generated realtime images yet`
  String get noRealtimeImageGenerated {
    return Intl.message(
      'You haven\'t generated realtime images yet',
      name: 'noRealtimeImageGenerated',
      desc: '',
      args: [],
    );
  }

  /// `You haven't generated any video yet`
  String get noVideoGenerated {
    return Intl.message(
      'You haven\'t generated any video yet',
      name: 'noVideoGenerated',
      desc: '',
      args: [],
    );
  }

  /// `No watermarks/ads`
  String get noWatermarksAds {
    return Intl.message(
      'No watermarks/ads',
      name: 'noWatermarksAds',
      desc: '',
      args: [],
    );
  }

  /// `Normal Mode`
  String get normal_mode {
    return Intl.message(
      'Normal Mode',
      name: 'normal_mode',
      desc: '',
      args: [],
    );
  }

  /// `Standard quality with balanced speed`
  String get normal_mode_description {
    return Intl.message(
      'Standard quality with balanced speed',
      name: 'normal_mode_description',
      desc: '',
      args: [],
    );
  }

  /// `This operation is currently disabled. Please contact your administrator for more information.`
  String get operation_not_allowed {
    return Intl.message(
      'This operation is currently disabled. Please contact your administrator for more information.',
      name: 'operation_not_allowed',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message(
      'Optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Or Login With`
  String get orLoginWith {
    return Intl.message(
      'Or Login With',
      name: 'orLoginWith',
      desc: '',
      args: [],
    );
  }

  /// `P&E`
  String get pAndE {
    return Intl.message(
      'P&E',
      name: 'pAndE',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Your password has been changed successfully`
  String get passwordChangedSuccess {
    return Intl.message(
      'Your password has been changed successfully',
      name: 'passwordChangedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Password reset link sent to your e-mail`
  String get passwordResetLinkSent {
    return Intl.message(
      'Password reset link sent to your e-mail',
      name: 'passwordResetLinkSent',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid password.`
  String get password_error {
    return Intl.message(
      'Please enter a valid password.',
      name: 'password_error',
      desc: '',
      args: [],
    );
  }

  /// `Passwords don't match`
  String get passwords_dont_match {
    return Intl.message(
      'Passwords don\'t match',
      name: 'passwords_dont_match',
      desc: '',
      args: [],
    );
  }

  /// `per week`
  String get perWeek {
    return Intl.message(
      'per week',
      name: 'perWeek',
      desc: '',
      args: [],
    );
  }

  /// `You need to grant permission to select a photo`
  String get permissionRequired {
    return Intl.message(
      'You need to grant permission to select a photo',
      name: 'permissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInformation {
    return Intl.message(
      'Personal Information',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Photo added!`
  String get photoAdded {
    return Intl.message(
      'Photo added!',
      name: 'photoAdded',
      desc: '',
      args: [],
    );
  }

  /// `Photo is successfully deleted!`
  String get photo_deleted_successfully {
    return Intl.message(
      'Photo is successfully deleted!',
      name: 'photo_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Photo Type`
  String get photo_type {
    return Intl.message(
      'Photo Type',
      name: 'photo_type',
      desc: '',
      args: [],
    );
  }

  /// `Customize Video`
  String get pixverse_settings {
    return Intl.message(
      'Customize Video',
      name: 'pixverse_settings',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a video description`
  String get please_enter_video_description {
    return Intl.message(
      'Please enter a video description',
      name: 'please_enter_video_description',
      desc: '',
      args: [],
    );
  }

  /// `Pollo 1.6 Settings`
  String get pollo_settings {
    return Intl.message(
      'Pollo 1.6 Settings',
      name: 'pollo_settings',
      desc: '',
      args: [],
    );
  }

  /// `Predict Time`
  String get predictTime {
    return Intl.message(
      'Predict Time',
      name: 'predictTime',
      desc: '',
      args: [],
    );
  }

  /// `Premium Package`
  String get premiumPackage {
    return Intl.message(
      'Premium Package',
      name: 'premiumPackage',
      desc: '',
      args: [],
    );
  }

  /// `Processing your request...`
  String get processing_request {
    return Intl.message(
      'Processing your request...',
      name: 'processing_request',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Prompt cannot be empty`
  String get promptEmpty {
    return Intl.message(
      'Prompt cannot be empty',
      name: 'promptEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Quality`
  String get quality {
    return Intl.message(
      'Quality',
      name: 'quality',
      desc: '',
      args: [],
    );
  }

  /// `Realtime Images`
  String get realtimeImages {
    return Intl.message(
      'Realtime Images',
      name: 'realtimeImages',
      desc: '',
      args: [],
    );
  }

  /// `Repeat New Password`
  String get repeat_new_password {
    return Intl.message(
      'Repeat New Password',
      name: 'repeat_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Report Content`
  String get reportContent {
    return Intl.message(
      'Report Content',
      name: 'reportContent',
      desc: '',
      args: [],
    );
  }

  /// `Please specify why this content is inappropriate`
  String get reportReason {
    return Intl.message(
      'Please specify why this content is inappropriate',
      name: 'reportReason',
      desc: '',
      args: [],
    );
  }

  /// `Successfully submitted! It will be reviewed as soon as possible and you will be notified`
  String get reportSuccess {
    return Intl.message(
      'Successfully submitted! It will be reviewed as soon as possible and you will be notified',
      name: 'reportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required {
    return Intl.message(
      'Required',
      name: 'required',
      desc: '',
      args: [],
    );
  }

  /// `You need to log in again to perform this operation.`
  String get requires_recent_login {
    return Intl.message(
      'You need to log in again to perform this operation.',
      name: 'requires_recent_login',
      desc: '',
      args: [],
    );
  }

  /// `Reset Your Password`
  String get resetYourPassword {
    return Intl.message(
      'Reset Your Password',
      name: 'resetYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Resolution`
  String get resolution {
    return Intl.message(
      'Resolution',
      name: 'resolution',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `SAVE`
  String get save {
    return Intl.message(
      'SAVE',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Second Person`
  String get secondPerson {
    return Intl.message(
      'Second Person',
      name: 'secondPerson',
      desc: '',
      args: [],
    );
  }

  /// `Secure`
  String get secure {
    return Intl.message(
      'Secure',
      name: 'secure',
      desc: '',
      args: [],
    );
  }

  /// `Select Start Image`
  String get select_start_image {
    return Intl.message(
      'Select Start Image',
      name: 'select_start_image',
      desc: '',
      args: [],
    );
  }

  /// `Select Tail Image`
  String get select_tail_image {
    return Intl.message(
      'Select Tail Image',
      name: 'select_tail_image',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `2 separate photos`
  String get separate_photos {
    return Intl.message(
      '2 separate photos',
      name: 'separate_photos',
      desc: '',
      args: [],
    );
  }

  /// `Short Video`
  String get short_video {
    return Intl.message(
      'Short Video',
      name: 'short_video',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signup_button_link {
    return Intl.message(
      'Sign up',
      name: 'signup_button_link',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? `
  String get signup_button_text {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'signup_button_text',
      desc: '',
      args: [],
    );
  }

  /// `Start Generating`
  String get startGenerating {
    return Intl.message(
      'Start Generating',
      name: 'startGenerating',
      desc: '',
      args: [],
    );
  }

  /// `Start Image`
  String get start_image {
    return Intl.message(
      'Start Image',
      name: 'start_image',
      desc: '',
      args: [],
    );
  }

  /// `Style`
  String get style {
    return Intl.message(
      'Style',
      name: 'style',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get submitReport {
    return Intl.message(
      'Report',
      name: 'submitReport',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe Now`
  String get subscribeNow {
    return Intl.message(
      'Subscribe Now',
      name: 'subscribeNow',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Successfully`
  String get successfully {
    return Intl.message(
      'Successfully',
      name: 'successfully',
      desc: '',
      args: [],
    );
  }

  /// `Tail Image`
  String get tail_image {
    return Intl.message(
      'Tail Image',
      name: 'tail_image',
      desc: '',
      args: [],
    );
  }

  /// `You must agree to the Terms of Service and Privacy Policy to continue.`
  String get terms_of_service_required {
    return Intl.message(
      'You must agree to the Terms of Service and Privacy Policy to continue.',
      name: 'terms_of_service_required',
      desc: '',
      args: [],
    );
  }

  /// `Text to Video`
  String get text_to_video {
    return Intl.message(
      'Text to Video',
      name: 'text_to_video',
      desc: '',
      args: [],
    );
  }

  /// `3D Animation`
  String get threeDAnimationStyle {
    return Intl.message(
      '3D Animation',
      name: 'threeDAnimationStyle',
      desc: '',
      args: [],
    );
  }

  /// `Three-dimensional animation style`
  String get threeDAnimationStyleDescription {
    return Intl.message(
      'Three-dimensional animation style',
      name: 'threeDAnimationStyleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Access to your account has been temporarily blocked. Please try again later.`
  String get too_many_requests {
    return Intl.message(
      'Access to your account has been temporarily blocked. Please try again later.',
      name: 'too_many_requests',
      desc: '',
      args: [],
    );
  }

  /// `Trending AI Video Effects`
  String get trendingVideoEffects {
    return Intl.message(
      'Trending AI Video Effects',
      name: 'trendingVideoEffects',
      desc: '',
      args: [],
    );
  }

  /// `Try Now`
  String get tryNow {
    return Intl.message(
      'Try Now',
      name: 'tryNow',
      desc: '',
      args: [],
    );
  }

  /// `Type your prompt below to generate realtime images`
  String get typeYourPrompt {
    return Intl.message(
      'Type your prompt below to generate realtime images',
      name: 'typeYourPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Ultra`
  String get ultra_quality {
    return Intl.message(
      'Ultra',
      name: 'ultra_quality',
      desc: '',
      args: [],
    );
  }

  /// `Unlock all features`
  String get unlockAllFeatures {
    return Intl.message(
      'Unlock all features',
      name: 'unlockAllFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Upload if both people are in the same photo`
  String get uploadIfSamePhoto {
    return Intl.message(
      'Upload if both people are in the same photo',
      name: 'uploadIfSamePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Upload Images`
  String get upload_images {
    return Intl.message(
      'Upload Images',
      name: 'upload_images',
      desc: '',
      args: [],
    );
  }

  /// `Upload Photo`
  String get upload_photo {
    return Intl.message(
      'Upload Photo',
      name: 'upload_photo',
      desc: '',
      args: [],
    );
  }

  /// `Upload Photos`
  String get upload_photos {
    return Intl.message(
      'Upload Photos',
      name: 'upload_photos',
      desc: '',
      args: [],
    );
  }

  /// `Use AI Video Effects`
  String get useAIVideoEffects {
    return Intl.message(
      'Use AI Video Effects',
      name: 'useAIVideoEffects',
      desc: '',
      args: [],
    );
  }

  /// `User Not Found`
  String get userNotFound {
    return Intl.message(
      'User Not Found',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `This user account has been disabled.`
  String get user_disabled {
    return Intl.message(
      'This user account has been disabled.',
      name: 'user_disabled',
      desc: '',
      args: [],
    );
  }

  /// `No user found with this email address.`
  String get user_not_found {
    return Intl.message(
      'No user found with this email address.',
      name: 'user_not_found',
      desc: '',
      args: [],
    );
  }

  /// `User Summary Screen`
  String get user_summary_screen {
    return Intl.message(
      'User Summary Screen',
      name: 'user_summary_screen',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle`
  String get vehicle {
    return Intl.message(
      'Vehicle',
      name: 'vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Video Details`
  String get videoDetails {
    return Intl.message(
      'Video Details',
      name: 'videoDetails',
      desc: '',
      args: [],
    );
  }

  /// `Video Generate`
  String get videoGenerate {
    return Intl.message(
      'Video Generate',
      name: 'videoGenerate',
      desc: '',
      args: [],
    );
  }

  /// `Video generation failed. Please try again.`
  String get video_generation_error {
    return Intl.message(
      'Video generation failed. Please try again.',
      name: 'video_generation_error',
      desc: '',
      args: [],
    );
  }

  /// `Video generation started...`
  String get video_generation_started {
    return Intl.message(
      'Video generation started...',
      name: 'video_generation_started',
      desc: '',
      args: [],
    );
  }

  /// `Your video is being created. This process takes 10-60 seconds`
  String get video_generation_success {
    return Intl.message(
      'Your video is being created. This process takes 10-60 seconds',
      name: 'video_generation_success',
      desc: '',
      args: [],
    );
  }

  /// `Preview could not be loaded`
  String get video_preview_error {
    return Intl.message(
      'Preview could not be loaded',
      name: 'video_preview_error',
      desc: '',
      args: [],
    );
  }

  /// `Loading video preview...`
  String get video_preview_loading {
    return Intl.message(
      'Loading video preview...',
      name: 'video_preview_loading',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get videos {
    return Intl.message(
      'Videos',
      name: 'videos',
      desc: '',
      args: [],
    );
  }

  /// `Watch a short video ad to earn 20 credits`
  String get watchAdToEarn {
    return Intl.message(
      'Watch a short video ad to earn 20 credits',
      name: 'watchAdToEarn',
      desc: '',
      args: [],
    );
  }

  /// `Watch Ads`
  String get watchAds {
    return Intl.message(
      'Watch Ads',
      name: 'watchAds',
      desc: '',
      args: [],
    );
  }

  /// `(You can watch up to 3 ads per day)`
  String get watchLimit {
    return Intl.message(
      '(You can watch up to 3 ads per day)',
      name: 'watchLimit',
      desc: '',
      args: [],
    );
  }

  /// `You need to watch 3 ads to claim credits.`
  String get watch_5_ads_to_claim {
    return Intl.message(
      'You need to watch 3 ads to claim credits.',
      name: 'watch_5_ads_to_claim',
      desc: '',
      args: [],
    );
  }

  /// `Email Verification Required`
  String get emailVerificationRequired {
    return Intl.message(
      'Email Verification Required',
      name: 'emailVerificationRequired',
      desc: '',
      args: [],
    );
  }

  /// `You need to verify your email address to continue claiming credits. This helps prevent abuse and ensures account security.`
  String get emailVerificationMessage {
    return Intl.message(
      'You need to verify your email address to continue claiming credits. This helps prevent abuse and ensures account security.',
      name: 'emailVerificationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Verification email sent! Please check your inbox and click the verification link.`
  String get verificationEmailSent {
    return Intl.message(
      'Verification email sent! Please check your inbox and click the verification link.',
      name: 'verificationEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `Send Verification Email`
  String get sendVerificationEmail {
    return Intl.message(
      'Send Verification Email',
      name: 'sendVerificationEmail',
      desc: '',
      args: [],
    );
  }

  /// `Check Verification`
  String get checkVerification {
    return Intl.message(
      'Check Verification',
      name: 'checkVerification',
      desc: '',
      args: [],
    );
  }

  /// `Error sending verification email. Please try again.`
  String get errorSendingVerificationEmail {
    return Intl.message(
      'Error sending verification email. Please try again.',
      name: 'errorSendingVerificationEmail',
      desc: '',
      args: [],
    );
  }

  /// `Email verified successfully! You can now claim your credits.`
  String get emailVerifiedSuccessfully {
    return Intl.message(
      'Email verified successfully! You can now claim your credits.',
      name: 'emailVerifiedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Email not verified yet. Please check your inbox and click the verification link.`
  String get emailNotVerifiedYet {
    return Intl.message(
      'Email not verified yet. Please check your inbox and click the verification link.',
      name: 'emailNotVerifiedYet',
      desc: '',
      args: [],
    );
  }

  /// `Error checking verification status. Please try again.`
  String get errorCheckingVerification {
    return Intl.message(
      'Error checking verification status. Please try again.',
      name: 'errorCheckingVerification',
      desc: '',
      args: [],
    );
  }

  /// `Watch Ad to Earn Credits`
  String get watch_ad {
    return Intl.message(
      'Watch Ad to Earn Credits',
      name: 'watch_ad',
      desc: '',
      args: [],
    );
  }

  /// `The password you entered is too weak. Please choose a stronger password.`
  String get weak_password {
    return Intl.message(
      'The password you entered is too weak. Please choose a stronger password.',
      name: 'weak_password',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Plan`
  String get weeklyPlan {
    return Intl.message(
      'Weekly Plan',
      name: 'weeklyPlan',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password.`
  String get wrong_password {
    return Intl.message(
      'Incorrect password.',
      name: 'wrong_password',
      desc: '',
      args: [],
    );
  }

  /// `Yearly Plan`
  String get yearlyPlan {
    return Intl.message(
      'Yearly Plan',
      name: 'yearlyPlan',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Realtime AI`
  String get realtimeAI {
    return Intl.message(
      'Realtime AI',
      name: 'realtimeAI',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Category`
  String get filterByCategoryTooltip {
    return Intl.message(
      'Filter by Category',
      name: 'filterByCategoryTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Toggle Grid Layout`
  String get toggleGridLayoutTooltip {
    return Intl.message(
      'Toggle Grid Layout',
      name: 'toggleGridLayoutTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Effects`
  String get effects {
    return Intl.message(
      'Effects',
      name: 'effects',
      desc: '',
      args: [],
    );
  }

  /// `Delete Video`
  String get deleteVideo {
    return Intl.message(
      'Delete Video',
      name: 'deleteVideo',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this video?`
  String get deleteVideoConfirmation {
    return Intl.message(
      'Are you sure you want to delete this video?',
      name: 'deleteVideoConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Video deleted successfully`
  String get videoDeletedSuccessfully {
    return Intl.message(
      'Video deleted successfully',
      name: 'videoDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Template regeneration started with seed: {seed}`
  String templateRegenerationStarted(Object seed) {
    return Intl.message(
      'Template regeneration started with seed: $seed',
      name: 'templateRegenerationStarted',
      desc: '',
      args: [seed],
    );
  }

  /// `Failed to regenerate template`
  String get failedToRegenerateTemplate {
    return Intl.message(
      'Failed to regenerate template',
      name: 'failedToRegenerateTemplate',
      desc: '',
      args: [],
    );
  }

  /// `No input data found for template regeneration`
  String get noInputDataForTemplateRegeneration {
    return Intl.message(
      'No input data found for template regeneration',
      name: 'noInputDataForTemplateRegeneration',
      desc: '',
      args: [],
    );
  }

  /// `Generating different version of video`
  String get videoRegenerationStarted {
    return Intl.message(
      'Generating different version of video',
      name: 'videoRegenerationStarted',
      desc: '',
      args: [],
    );
  }

  /// `Failed to regenerate video`
  String get failedToRegenerateVideo {
    return Intl.message(
      'Failed to regenerate video',
      name: 'failedToRegenerateVideo',
      desc: '',
      args: [],
    );
  }

  /// `No input data found for regeneration`
  String get noInputDataForRegeneration {
    return Intl.message(
      'No input data found for regeneration',
      name: 'noInputDataForRegeneration',
      desc: '',
      args: [],
    );
  }

  /// `Sending report...`
  String get reportSending {
    return Intl.message(
      'Sending report...',
      name: 'reportSending',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send report. Please try again.`
  String get reportFailedToSend {
    return Intl.message(
      'Failed to send report. Please try again.',
      name: 'reportFailedToSend',
      desc: '',
      args: [],
    );
  }

  /// `Delete Image`
  String get deleteImage {
    return Intl.message(
      'Delete Image',
      name: 'deleteImage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this image?`
  String get deleteImageConfirmation {
    return Intl.message(
      'Are you sure you want to delete this image?',
      name: 'deleteImageConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Video ID copied!`
  String get videoIdCopied {
    return Intl.message(
      'Video ID copied!',
      name: 'videoIdCopied',
      desc: '',
      args: [],
    );
  }

  /// `Prompt copied!`
  String get promptCopied {
    return Intl.message(
      'Prompt copied!',
      name: 'promptCopied',
      desc: '',
      args: [],
    );
  }

  /// `Email copied to clipboard!`
  String get emailCopied {
    return Intl.message(
      'Email copied to clipboard!',
      name: 'emailCopied',
      desc: '',
      args: [],
    );
  }

  /// `File size too large (max 10MB)`
  String get fileSizeTooLarge {
    return Intl.message(
      'File size too large (max 10MB)',
      name: 'fileSizeTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pick image: {error}`
  String failedToPickImage(Object error) {
    return Intl.message(
      'Failed to pick image: $error',
      name: 'failedToPickImage',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to submit feedback`
  String get failedToSubmitFeedback {
    return Intl.message(
      'Failed to submit feedback',
      name: 'failedToSubmitFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Video Generation Failed`
  String get videoGenerationFailed {
    return Intl.message(
      'Video Generation Failed',
      name: 'videoGenerationFailed',
      desc: '',
      args: [],
    );
  }

  /// `To avoid being filtered, please enter your entries with a different wording?`
  String get videoGenerationFailedDescription {
    return Intl.message(
      'To avoid being filtered, please enter your entries with a different wording?',
      name: 'videoGenerationFailedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get processing {
    return Intl.message(
      'Processing...',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `Refund Credit`
  String get refundCredit {
    return Intl.message(
      'Refund Credit',
      name: 'refundCredit',
      desc: '',
      args: [],
    );
  }

  /// `Contact Support`
  String get contactSupport {
    return Intl.message(
      'Contact Support',
      name: 'contactSupport',
      desc: '',
      args: [],
    );
  }

  /// `To avoid filtering, copy the command and explain it slightly differently.`
  String get toAvoidFiltering {
    return Intl.message(
      'To avoid filtering, copy the command and explain it slightly differently.',
      name: 'toAvoidFiltering',
      desc: '',
      args: [],
    );
  }

  /// `Error processing refund. Please try again.`
  String get errorProcessingRefund {
    return Intl.message(
      'Error processing refund. Please try again.',
      name: 'errorProcessingRefund',
      desc: '',
      args: [],
    );
  }

  /// `Credit requirements not loaded. Please try again.`
  String get creditRequirementsNotLoaded {
    return Intl.message(
      'Credit requirements not loaded. Please try again.',
      name: 'creditRequirementsNotLoaded',
      desc: '',
      args: [],
    );
  }

  /// `Refund processed successfully!`
  String get refundProcessedSuccessfully {
    return Intl.message(
      'Refund processed successfully!',
      name: 'refundProcessedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Refund failed. Please try again.`
  String get refundFailed {
    return Intl.message(
      'Refund failed. Please try again.',
      name: 'refundFailed',
      desc: '',
      args: [],
    );
  }

  /// `Refund processed successfully!`
  String get refundProcessedSuccessfullyWithMessage {
    return Intl.message(
      'Refund processed successfully!',
      name: 'refundProcessedSuccessfullyWithMessage',
      desc: '',
      args: [],
    );
  }

  /// `Name Surname`
  String get nameSurname {
    return Intl.message(
      'Name Surname',
      name: 'nameSurname',
      desc: '',
      args: [],
    );
  }

  /// `Search effect...`
  String get effectSearch {
    return Intl.message(
      'Search effect...',
      name: 'effectSearch',
      desc: '',
      args: [],
    );
  }

  /// `Clear Search`
  String get clearSearch {
    return Intl.message(
      'Clear Search',
      name: 'clearSearch',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `UID copied`
  String get uidCopied {
    return Intl.message(
      'UID copied',
      name: 'uidCopied',
      desc: '',
      args: [],
    );
  }

  /// `UID`
  String get uid {
    return Intl.message(
      'UID',
      name: 'uid',
      desc: '',
      args: [],
    );
  }

  /// `Negative Prompt`
  String get negativePrompt {
    return Intl.message(
      'Negative Prompt',
      name: 'negativePrompt',
      desc: '',
      args: [],
    );
  }

  /// `Enter negative prompt to avoid unwanted elements...`
  String get negativePromptHint {
    return Intl.message(
      'Enter negative prompt to avoid unwanted elements...',
      name: 'negativePromptHint',
      desc: '',
      args: [],
    );
  }

  /// `Check out this image I created on Comby! Download App: app.comby.ai`
  String get shareText {
    return Intl.message(
      'Check out this image I created on Comby! Download App: app.comby.ai',
      name: 'shareText',
      desc: '',
      args: [],
    );
  }

  /// `Check out this image I created on Comby!\nDownload App: app.comby.ai`
  String get shareTextFromUrl {
    return Intl.message(
      'Check out this image I created on Comby!\nDownload App: app.comby.ai',
      name: 'shareTextFromUrl',
      desc: '',
      args: [],
    );
  }

  /// `Check out this video I created on Comby AI! Download App: app.comby.ai`
  String get shareVideoText {
    return Intl.message(
      'Check out this video I created on Comby AI! Download App: app.comby.ai',
      name: 'shareVideoText',
      desc: '',
      args: [],
    );
  }

  /// `Unlock 2nd Video`
  String get reviewRequiredTitle {
    return Intl.message(
      'Unlock 2nd Video',
      name: 'reviewRequiredTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please rate our app to create your 2nd video!`
  String get reviewRequiredMessage {
    return Intl.message(
      'Please rate our app to create your 2nd video!',
      name: 'reviewRequiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `Rate 5 Stars & Create 2nd Video`
  String get reviewRequiredButton {
    return Intl.message(
      'Rate 5 Stars & Create 2nd Video',
      name: 'reviewRequiredButton',
      desc: '',
      args: [],
    );
  }

  /// `Unlock 2nd Video!`
  String get reviewRequiredBonus {
    return Intl.message(
      'Unlock 2nd Video!',
      name: 'reviewRequiredBonus',
      desc: '',
      args: [],
    );
  }

  /// `Error loading credits`
  String get errorLoadingCredits {
    return Intl.message(
      'Error loading credits',
      name: 'errorLoadingCredits',
      desc: '',
      args: [],
    );
  }

  /// `Upload Photo`
  String get uploadPhoto {
    return Intl.message(
      'Upload Photo',
      name: 'uploadPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Refund Credit`
  String get refundCreditTitle {
    return Intl.message(
      'Refund Credit',
      name: 'refundCreditTitle',
      desc: '',
      args: [],
    );
  }

  /// `To avoid being filtered, please enter your entries with a different wording`
  String get refundCreditDescription {
    return Intl.message(
      'To avoid being filtered, please enter your entries with a different wording',
      name: 'refundCreditDescription',
      desc: '',
      args: [],
    );
  }

  /// `Refund processed successfully!`
  String get refundProcessedSuccessfullyDefault {
    return Intl.message(
      'Refund processed successfully!',
      name: 'refundProcessedSuccessfullyDefault',
      desc: '',
      args: [],
    );
  }

  /// `Refund Limit Reached`
  String get refundLimitReached {
    return Intl.message(
      'Refund Limit Reached',
      name: 'refundLimitReached',
      desc: '',
      args: [],
    );
  }

  /// `You have reached the maximum refund limit ({count}/10).`
  String refundLimitReachedDescription(Object count) {
    return Intl.message(
      'You have reached the maximum refund limit ($count/10).',
      name: 'refundLimitReachedDescription',
      desc: '',
      args: [count],
    );
  }

  /// `Subscription successful!`
  String get subscriptionSuccessful {
    return Intl.message(
      'Subscription successful!',
      name: 'subscriptionSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account Warning`
  String get deleteAccountWarning {
    return Intl.message(
      'Delete Account Warning',
      name: 'deleteAccountWarning',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.\n\n• All your usage rights will be reset\n• All generated content will be permanently deleted\n• All credits and subscriptions will be lost\n• Your profile and data will be removed`
  String get deleteAccountWarningDescription {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.\n\n• All your usage rights will be reset\n• All generated content will be permanently deleted\n• All credits and subscriptions will be lost\n• Your profile and data will be removed',
      name: 'deleteAccountWarningDescription',
      desc: '',
      args: [],
    );
  }

  /// `Delete My Account`
  String get deleteMyAccount {
    return Intl.message(
      'Delete My Account',
      name: 'deleteMyAccount',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been successfully deleted!`
  String get accountDeletedSuccessfully {
    return Intl.message(
      'Your account has been successfully deleted!',
      name: 'accountDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginButton {
    return Intl.message(
      'Login',
      name: 'loginButton',
      desc: '',
      args: [],
    );
  }

  /// `Purchase`
  String get purchaseButton {
    return Intl.message(
      'Purchase',
      name: 'purchaseButton',
      desc: '',
      args: [],
    );
  }

  /// `Deleted User`
  String get deletedUser {
    return Intl.message(
      'Deleted User',
      name: 'deletedUser',
      desc: '',
      args: [],
    );
  }

  /// `Counter completed`
  String get counterCompleted {
    return Intl.message(
      'Counter completed',
      name: 'counterCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Offerings empty`
  String get offeringsEmpty {
    return Intl.message(
      'Offerings empty',
      name: 'offeringsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Comby`
  String get appName {
    return Intl.message(
      'Comby',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get fileLabel {
    return Intl.message(
      'File',
      name: 'fileLabel',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get sizeLabel {
    return Intl.message(
      'Size',
      name: 'sizeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String errorWithSnapshot(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'errorWithSnapshot',
      desc: '',
      args: [error],
    );
  }

  /// `File: {fileName}`
  String fileText(Object fileName) {
    return Intl.message(
      'File: $fileName',
      name: 'fileText',
      desc: '',
      args: [fileName],
    );
  }

  /// `Size: {fileSize}`
  String sizeText(Object fileSize) {
    return Intl.message(
      'Size: $fileSize',
      name: 'sizeText',
      desc: '',
      args: [fileSize],
    );
  }

  /// `HISTED, TXVSTERPLAYA - MASHA ULTRAFUNK`
  String get artistCredit {
    return Intl.message(
      'HISTED, TXVSTERPLAYA - MASHA ULTRAFUNK',
      name: 'artistCredit',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient credits`
  String get insufficientCredits {
    return Intl.message(
      'Insufficient credits',
      name: 'insufficientCredits',
      desc: '',
      args: [],
    );
  }

  /// `Viral Effects On Tiktok`
  String get viralEffectsOnTiktok {
    return Intl.message(
      'Viral Effects On Tiktok',
      name: 'viralEffectsOnTiktok',
      desc: '',
      args: [],
    );
  }

  /// `Viral on TikTok`
  String get viralOnTiktok {
    return Intl.message(
      'Viral on TikTok',
      name: 'viralOnTiktok',
      desc: '',
      args: [],
    );
  }

  /// `WTF Effects`
  String get wtfEffects {
    return Intl.message(
      'WTF Effects',
      name: 'wtfEffects',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get videoTab {
    return Intl.message(
      'Video',
      name: 'videoTab',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get imageTab {
    return Intl.message(
      'Image',
      name: 'imageTab',
      desc: '',
      args: [],
    );
  }

  /// `HEIF Format Uyarısı`
  String get heifFormatWarning {
    return Intl.message(
      'HEIF Format Uyarısı',
      name: 'heifFormatWarning',
      desc: '',
      args: [],
    );
  }

  /// `Pixverse Uyumluluğu`
  String get pixverseCompatibility {
    return Intl.message(
      'Pixverse Uyumluluğu',
      name: 'pixverseCompatibility',
      desc: '',
      args: [],
    );
  }

  /// `İptal`
  String get cancelButton {
    return Intl.message(
      'İptal',
      name: 'cancelButton',
      desc: '',
      args: [],
    );
  }

  /// `Person 1`
  String get person1 {
    return Intl.message(
      'Person 1',
      name: 'person1',
      desc: '',
      args: [],
    );
  }

  /// `Person 2`
  String get person2 {
    return Intl.message(
      'Person 2',
      name: 'person2',
      desc: '',
      args: [],
    );
  }

  /// `Tap to select`
  String get tapToSelect {
    return Intl.message(
      'Tap to select',
      name: 'tapToSelect',
      desc: '',
      args: [],
    );
  }

  /// `Prompt: `
  String get promptLabel {
    return Intl.message(
      'Prompt: ',
      name: 'promptLabel',
      desc: '',
      args: [],
    );
  }

  /// `ID: `
  String get idLabel {
    return Intl.message(
      'ID: ',
      name: 'idLabel',
      desc: '',
      args: [],
    );
  }

  /// `Duration: `
  String get durationLabel {
    return Intl.message(
      'Duration: ',
      name: 'durationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Started At: `
  String get startedAtLabel {
    return Intl.message(
      'Started At: ',
      name: 'startedAtLabel',
      desc: '',
      args: [],
    );
  }

  /// `Completed At: `
  String get completedAtLabel {
    return Intl.message(
      'Completed At: ',
      name: 'completedAtLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error: `
  String get errorLabel {
    return Intl.message(
      'Error: ',
      name: 'errorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Web: `
  String get webLabel {
    return Intl.message(
      'Web: ',
      name: 'webLabel',
      desc: '',
      args: [],
    );
  }

  /// `Stream: `
  String get streamLabel {
    return Intl.message(
      'Stream: ',
      name: 'streamLabel',
      desc: '',
      args: [],
    );
  }

  /// `Get: `
  String get getLabel {
    return Intl.message(
      'Get: ',
      name: 'getLabel',
      desc: '',
      args: [],
    );
  }

  /// `Logs: `
  String get logsLabel {
    return Intl.message(
      'Logs: ',
      name: 'logsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Regenerate`
  String get regenerateButton {
    return Intl.message(
      'Regenerate',
      name: 'regenerateButton',
      desc: '',
      args: [],
    );
  }

  /// `Guest Purchase`
  String get guestPurchase {
    return Intl.message(
      'Guest Purchase',
      name: 'guestPurchase',
      desc: '',
      args: [],
    );
  }

  /// `You can purchase as a guest user. However, creating an account will enable you to:`
  String get guestPurchaseDescription {
    return Intl.message(
      'You can purchase as a guest user. However, creating an account will enable you to:',
      name: 'guestPurchaseDescription',
      desc: '',
      args: [],
    );
  }

  /// `• Access purchased content from any of your supported devices`
  String get guestBenefit1 {
    return Intl.message(
      '• Access purchased content from any of your supported devices',
      name: 'guestBenefit1',
      desc: '',
      args: [],
    );
  }

  /// `• Sync your data across devices`
  String get guestBenefit2 {
    return Intl.message(
      '• Sync your data across devices',
      name: 'guestBenefit2',
      desc: '',
      args: [],
    );
  }

  /// `• Secure your purchases and content`
  String get guestBenefit3 {
    return Intl.message(
      '• Secure your purchases and content',
      name: 'guestBenefit3',
      desc: '',
      args: [],
    );
  }

  /// `You can create an account at any time to extend access to additional devices.`
  String get guestPurchaseFooter {
    return Intl.message(
      'You can create an account at any time to extend access to additional devices.',
      name: 'guestPurchaseFooter',
      desc: '',
      args: [],
    );
  }

  /// `Continue as Guest`
  String get continueAsGuest {
    return Intl.message(
      'Continue as Guest',
      name: 'continueAsGuest',
      desc: '',
      args: [],
    );
  }

  /// `Rate Our App`
  String get rateOurApp {
    return Intl.message(
      'Rate Our App',
      name: 'rateOurApp',
      desc: '',
      args: [],
    );
  }

  /// `How was your experience with Comby AI?`
  String get howWasYourExperience {
    return Intl.message(
      'How was your experience with Comby AI?',
      name: 'howWasYourExperience',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Maybe Later`
  String get maybeLater {
    return Intl.message(
      'Maybe Later',
      name: 'maybeLater',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `Guest User`
  String get guestUser {
    return Intl.message(
      'Guest User',
      name: 'guestUser',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade to Full Account`
  String get upgradeToFullAccount {
    return Intl.message(
      'Upgrade to Full Account',
      name: 'upgradeToFullAccount',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade Your Account`
  String get upgradeYourAccount {
    return Intl.message(
      'Upgrade Your Account',
      name: 'upgradeYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Convert your guest account to a full account:\n• Keep all your credits ({credits})\n• Keep all your videos and content\n• Sync data across devices\n• Secure your account with password`
  String upgradeAccountDescription(Object credits) {
    return Intl.message(
      'Convert your guest account to a full account:\n• Keep all your credits ($credits)\n• Keep all your videos and content\n• Sync data across devices\n• Secure your account with password',
      name: 'upgradeAccountDescription',
      desc: '',
      args: [credits],
    );
  }

  /// `✅ Your data will be preserved!`
  String get dataWillBePreserved {
    return Intl.message(
      '✅ Your data will be preserved!',
      name: 'dataWillBePreserved',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade Account`
  String get upgradeAccount {
    return Intl.message(
      'Upgrade Account',
      name: 'upgradeAccount',
      desc: '',
      args: [],
    );
  }

  /// `Comby AI Plus Plan`
  String get combyAiPlusPlan {
    return Intl.message(
      'Comby AI Plus Plan',
      name: 'combyAiPlusPlan',
      desc: '',
      args: [],
    );
  }

  /// `Comby AI Pro Plan`
  String get combyAiProPlan {
    return Intl.message(
      'Comby AI Pro Plan',
      name: 'combyAiProPlan',
      desc: '',
      args: [],
    );
  }

  /// `Comby AI Ultra Plan`
  String get combyAiUltraPlan {
    return Intl.message(
      'Comby AI Ultra Plan',
      name: 'combyAiUltraPlan',
      desc: '',
      args: [],
    );
  }

  /// `Select photos for both people`
  String get selectPhotosForBothPeople {
    return Intl.message(
      'Select photos for both people',
      name: 'selectPhotosForBothPeople',
      desc: '',
      args: [],
    );
  }

  /// `Upload First\nphoto`
  String get uploadFirstPhoto {
    return Intl.message(
      'Upload First\nphoto',
      name: 'uploadFirstPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Upload Secondary\nphoto`
  String get uploadSecondaryPhoto {
    return Intl.message(
      'Upload Secondary\nphoto',
      name: 'uploadSecondaryPhoto',
      desc: '',
      args: [],
    );
  }

  /// `You need an active subscription to purchase extra credits`
  String get subscriptionRequiredForCredits {
    return Intl.message(
      'You need an active subscription to purchase extra credits',
      name: 'subscriptionRequiredForCredits',
      desc: '',
      args: [],
    );
  }

  /// `Get Subscription First`
  String get getSubscriptionFirst {
    return Intl.message(
      'Get Subscription First',
      name: 'getSubscriptionFirst',
      desc: '',
      args: [],
    );
  }

  /// `Select a single photo`
  String get selectASinglePhoto {
    return Intl.message(
      'Select a single photo',
      name: 'selectASinglePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Extra credits are available only for premium subscribers. Get a subscription to unlock unlimited possibilities!`
  String get extraCreditsDescription {
    return Intl.message(
      'Extra credits are available only for premium subscribers. Get a subscription to unlock unlimited possibilities!',
      name: 'extraCreditsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Free Credit`
  String get freeCredit {
    return Intl.message(
      'Free Credit',
      name: 'freeCredit',
      desc: '',
      args: [],
    );
  }

  /// `Earn Free Credits`
  String get earnFreeCredits {
    return Intl.message(
      'Earn Free Credits',
      name: 'earnFreeCredits',
      desc: '',
      args: [],
    );
  }

  /// `Ways to Earn Free Credits`
  String get freeCreditWays {
    return Intl.message(
      'Ways to Earn Free Credits',
      name: 'freeCreditWays',
      desc: '',
      args: [],
    );
  }

  /// `Follow these simple steps to earn free credits`
  String get freeCreditDescription {
    return Intl.message(
      'Follow these simple steps to earn free credits',
      name: 'freeCreditDescription',
      desc: '',
      args: [],
    );
  }

  /// `Watch Ads`
  String get watchAdEarnCredit {
    return Intl.message(
      'Watch Ads',
      name: 'watchAdEarnCredit',
      desc: '',
      args: [],
    );
  }

  /// `Earn credits by watching video ads`
  String get watchAdSubtitle {
    return Intl.message(
      'Earn credits by watching video ads',
      name: 'watchAdSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Rate Our App`
  String get rateAppEarnCredit {
    return Intl.message(
      'Rate Our App',
      name: 'rateAppEarnCredit',
      desc: '',
      args: [],
    );
  }

  /// `Rate 5 stars, write a review and unlock 2nd video`
  String get rateAppSubtitle {
    return Intl.message(
      'Rate 5 stars, write a review and unlock 2nd video',
      name: 'rateAppSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Info`
  String get freeCreditInfo {
    return Intl.message(
      'Info',
      name: 'freeCreditInfo',
      desc: '',
      args: [],
    );
  }

  /// `Earned credits will be added automatically.`
  String get freeCreditInfoDescription {
    return Intl.message(
      'Earned credits will be added automatically.',
      name: 'freeCreditInfoDescription',
      desc: '',
      args: [],
    );
  }

  /// `Review`
  String get reviewConfirmationTitle {
    return Intl.message(
      'Review',
      name: 'reviewConfirmationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Did you rate our app?`
  String get reviewConfirmationMessage {
    return Intl.message(
      'Did you rate our app?',
      name: 'reviewConfirmationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Did you rate our app in the App Store?`
  String get reviewConfirmationMessageIOS {
    return Intl.message(
      'Did you rate our app in the App Store?',
      name: 'reviewConfirmationMessageIOS',
      desc: '',
      args: [],
    );
  }

  /// `Did you rate our app in the Play Store?`
  String get reviewConfirmationMessageAndroid {
    return Intl.message(
      'Did you rate our app in the Play Store?',
      name: 'reviewConfirmationMessageAndroid',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Yes, I Rated`
  String get yesIRated {
    return Intl.message(
      'Yes, I Rated',
      name: 'yesIRated',
      desc: '',
      args: [],
    );
  }

  /// `✅ Thank you! You can now create your 2nd video.`
  String get reviewThanksWithCredit {
    return Intl.message(
      '✅ Thank you! You can now create your 2nd video.',
      name: 'reviewThanksWithCredit',
      desc: '',
      args: [],
    );
  }

  /// `😊 Thank you! We appreciate your feedback.`
  String get reviewThanksWithoutCredit {
    return Intl.message(
      '😊 Thank you! We appreciate your feedback.',
      name: 'reviewThanksWithoutCredit',
      desc: '',
      args: [],
    );
  }

  /// `✅ Review completed! Now you can create your 2nd video.`
  String get reviewCompletedNoCredit {
    return Intl.message(
      '✅ Review completed! Now you can create your 2nd video.',
      name: 'reviewCompletedNoCredit',
      desc: '',
      args: [],
    );
  }

  /// `Could not open review page. Please try again.`
  String get reviewPageError {
    return Intl.message(
      'Could not open review page. Please try again.',
      name: 'reviewPageError',
      desc: '',
      args: [],
    );
  }

  /// `Very Poor`
  String get veryPoor {
    return Intl.message(
      'Very Poor',
      name: 'veryPoor',
      desc: '',
      args: [],
    );
  }

  /// `Poor`
  String get poor {
    return Intl.message(
      'Poor',
      name: 'poor',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get good {
    return Intl.message(
      'Good',
      name: 'good',
      desc: '',
      args: [],
    );
  }

  /// `Very Good`
  String get veryGood {
    return Intl.message(
      'Very Good',
      name: 'veryGood',
      desc: '',
      args: [],
    );
  }

  /// `Excellent`
  String get excellent {
    return Intl.message(
      'Excellent',
      name: 'excellent',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your rating!`
  String get ratingSubmitted {
    return Intl.message(
      'Thank you for your rating!',
      name: 'ratingSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Redirecting to feedback page...`
  String get redirectingToFeedback {
    return Intl.message(
      'Redirecting to feedback page...',
      name: 'redirectingToFeedback',
      desc: '',
      args: [],
    );
  }

  /// `You have already claimed your review credit!`
  String get reviewCreditAlreadyClaimed {
    return Intl.message(
      'You have already claimed your review credit!',
      name: 'reviewCreditAlreadyClaimed',
      desc: '',
      args: [],
    );
  }

  /// `To claim 60 free credits, please upgrade your account first`
  String get upgradeAccountForReviewCredit {
    return Intl.message(
      'To claim 60 free credits, please upgrade your account first',
      name: 'upgradeAccountForReviewCredit',
      desc: '',
      args: [],
    );
  }

  /// `Account Upgrade Required`
  String get upgradeAccountRequired {
    return Intl.message(
      'Account Upgrade Required',
      name: 'upgradeAccountRequired',
      desc: '',
      args: [],
    );
  }

  /// `You need to upgrade your account to claim free credits. Upgrade now to unlock this feature!`
  String get upgradeAccountMessage {
    return Intl.message(
      'You need to upgrade your account to claim free credits. Upgrade now to unlock this feature!',
      name: 'upgradeAccountMessage',
      desc: '',
      args: [],
    );
  }

  /// `This device has already completed the review!`
  String get deviceAlreadyClaimedReviewCredit {
    return Intl.message(
      'This device has already completed the review!',
      name: 'deviceAlreadyClaimedReviewCredit',
      desc: '',
      args: [],
    );
  }

  /// `Review has already been completed on this device. Each device can only review once.`
  String get deviceReviewCreditMessage {
    return Intl.message(
      'Review has already been completed on this device. Each device can only review once.',
      name: 'deviceReviewCreditMessage',
      desc: '',
      args: [],
    );
  }

  /// `Guest`
  String get guest {
    return Intl.message(
      'Guest',
      name: 'guest',
      desc: '',
      args: [],
    );
  }

  /// `Google`
  String get google {
    return Intl.message(
      'Google',
      name: 'google',
      desc: '',
      args: [],
    );
  }

  /// `Apple`
  String get apple {
    return Intl.message(
      'Apple',
      name: 'apple',
      desc: '',
      args: [],
    );
  }

  /// `Redirecting to payment...`
  String get redirectingToPayment {
    return Intl.message(
      'Redirecting to payment...',
      name: 'redirectingToPayment',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Comby...`
  String get initializing {
    return Intl.message(
      'Welcome to Comby...',
      name: 'initializing',
      desc: '',
      args: [],
    );
  }

  /// `Preparing magic...`
  String get loadingThemes {
    return Intl.message(
      'Preparing magic...',
      name: 'loadingThemes',
      desc: '',
      args: [],
    );
  }

  /// `Getting creative...`
  String get settingLanguage {
    return Intl.message(
      'Getting creative...',
      name: 'settingLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Unleashing AI power...`
  String get loadingAds {
    return Intl.message(
      'Unleashing AI power...',
      name: 'loadingAds',
      desc: '',
      args: [],
    );
  }

  /// `Almost there...`
  String get configuringPayments {
    return Intl.message(
      'Almost there...',
      name: 'configuringPayments',
      desc: '',
      args: [],
    );
  }

  /// `Ready to create...`
  String get almostReady {
    return Intl.message(
      'Ready to create...',
      name: 'almostReady',
      desc: '',
      args: [],
    );
  }

  /// `Let's go!`
  String get ready {
    return Intl.message(
      'Let\'s go!',
      name: 'ready',
      desc: '',
      args: [],
    );
  }

  /// `AI Video Effects`
  String get aiVideoEffects {
    return Intl.message(
      'AI Video Effects',
      name: 'aiVideoEffects',
      desc: '',
      args: [],
    );
  }

  /// `Inappropriate Content Detected`
  String get bannedContentDetected {
    return Intl.message(
      'Inappropriate Content Detected',
      name: 'bannedContentDetected',
      desc: '',
      args: [],
    );
  }

  /// `Inappropriate content was detected in your prompt. Please use a more appropriate expression.`
  String get bannedContentMessage {
    return Intl.message(
      'Inappropriate content was detected in your prompt. Please use a more appropriate expression.',
      name: 'bannedContentMessage',
      desc: '',
      args: [],
    );
  }

  /// `Detected word: `
  String get detectedWord {
    return Intl.message(
      'Detected word: ',
      name: 'detectedWord',
      desc: '',
      args: [],
    );
  }

  /// `Please edit your prompt and try again.`
  String get pleaseEditPrompt {
    return Intl.message(
      'Please edit your prompt and try again.',
      name: 'pleaseEditPrompt',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Library refreshed`
  String get libraryRefreshed {
    return Intl.message(
      'Library refreshed',
      name: 'libraryRefreshed',
      desc: '',
      args: [],
    );
  }

  /// `Image size is too large. Maximum size is 4000x4000 pixels.`
  String get image_size_too_large {
    return Intl.message(
      'Image size is too large. Maximum size is 4000x4000 pixels.',
      name: 'image_size_too_large',
      desc: '',
      args: [],
    );
  }

  /// `Deneme`
  String get deneme {
    return Intl.message(
      'Deneme',
      name: 'deneme',
      desc: '',
      args: [],
    );
  }

  /// `Hot`
  String get ticket_hot {
    return Intl.message(
      'Hot',
      name: 'ticket_hot',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get ticket_new {
    return Intl.message(
      'New',
      name: 'ticket_new',
      desc: '',
      args: [],
    );
  }

  /// `Trend`
  String get ticket_trend {
    return Intl.message(
      'Trend',
      name: 'ticket_trend',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get ticket_popular {
    return Intl.message(
      'Popular',
      name: 'ticket_popular',
      desc: '',
      args: [],
    );
  }

  /// `Update Required`
  String get forceUpdateTitle {
    return Intl.message(
      'Update Required',
      name: 'forceUpdateTitle',
      desc: '',
      args: [],
    );
  }

  /// `You need to update to the latest version to continue using the app.`
  String get forceUpdateMessage {
    return Intl.message(
      'You need to update to the latest version to continue using the app.',
      name: 'forceUpdateMessage',
      desc: '',
      args: [],
    );
  }

  /// `New features and improvements await you!`
  String get forceUpdateInfo {
    return Intl.message(
      'New features and improvements await you!',
      name: 'forceUpdateInfo',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get updateButton {
    return Intl.message(
      'Update',
      name: 'updateButton',
      desc: '',
      args: [],
    );
  }

  /// `Premium Template`
  String get premiumTemplateTitle {
    return Intl.message(
      'Premium Template',
      name: 'premiumTemplateTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have used your free trial for this premium template.`
  String get premiumTemplateUsedMessage {
    return Intl.message(
      'You have used your free trial for this premium template.',
      name: 'premiumTemplateUsedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited Usage`
  String get unlimitedUsage {
    return Intl.message(
      'Unlimited Usage',
      name: 'unlimitedUsage',
      desc: '',
      args: [],
    );
  }

  /// `Get unlimited access to premium templates by subscribing or purchasing credit packages.`
  String get premiumTemplateUnlimitedInfo {
    return Intl.message(
      'Get unlimited access to premium templates by subscribing or purchasing credit packages.',
      name: 'premiumTemplateUnlimitedInfo',
      desc: '',
      args: [],
    );
  }

  /// `Buy Subscription/Credits`
  String get buySubscriptionOrCredits {
    return Intl.message(
      'Buy Subscription/Credits',
      name: 'buySubscriptionOrCredits',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Other Templates`
  String get continueWithOtherTemplates {
    return Intl.message(
      'Continue with Other Templates',
      name: 'continueWithOtherTemplates',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `How do you want to look today?`
  String get welcome_messages {
    return Intl.message(
      'How do you want to look today?',
      name: 'welcome_messages',
      desc: '',
      args: [],
    );
  }

  /// `Guest Account`
  String get guestAccountTitle {
    return Intl.message(
      'Guest Account',
      name: 'guestAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `You need to create an account to watch ads and earn credits.`
  String get guestAccountWatchAdsMessage {
    return Intl.message(
      'You need to create an account to watch ads and earn credits.',
      name: 'guestAccountWatchAdsMessage',
      desc: '',
      args: [],
    );
  }

  /// `Account Benefits:`
  String get guestAccountBenefits {
    return Intl.message(
      'Account Benefits:',
      name: 'guestAccountBenefits',
      desc: '',
      args: [],
    );
  }

  /// `Watch ads and earn free credits`
  String get benefitWatchAds {
    return Intl.message(
      'Watch ads and earn free credits',
      name: 'benefitWatchAds',
      desc: '',
      args: [],
    );
  }

  /// `Cloud sync and backup`
  String get benefitCloudSync {
    return Intl.message(
      'Cloud sync and backup',
      name: 'benefitCloudSync',
      desc: '',
      args: [],
    );
  }

  /// `Access to premium features`
  String get benefitPremiumFeatures {
    return Intl.message(
      'Access to premium features',
      name: 'benefitPremiumFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign In with Account`
  String get signInWithAccount {
    return Intl.message(
      'Sign In with Account',
      name: 'signInWithAccount',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
