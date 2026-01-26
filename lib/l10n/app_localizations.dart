import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @account_exists_with_different_credential.
  ///
  /// In en, this message translates to:
  /// **'This email address is already associated with a different login method.'**
  String get account_exists_with_different_credential;

  /// No description provided for @ai_video_generation.
  ///
  /// In en, this message translates to:
  /// **'AI Video Generation'**
  String get ai_video_generation;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @anime_style.
  ///
  /// In en, this message translates to:
  /// **'Anime Style'**
  String get anime_style;

  /// No description provided for @anime_style_description.
  ///
  /// In en, this message translates to:
  /// **'Japanese anime art style'**
  String get anime_style_description;

  /// No description provided for @app_settings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get app_settings;

  /// No description provided for @aspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get aspectRatio;

  /// No description provided for @aspect_ratio.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get aspect_ratio;

  /// No description provided for @auction.
  ///
  /// In en, this message translates to:
  /// **'Auction'**
  String get auction;

  /// No description provided for @autoRenewable.
  ///
  /// In en, this message translates to:
  /// **'Auto-renewable, cancel anytime'**
  String get autoRenewable;

  /// No description provided for @auto_style.
  ///
  /// In en, this message translates to:
  /// **'Auto Style'**
  String get auto_style;

  /// No description provided for @auto_style_description.
  ///
  /// In en, this message translates to:
  /// **'Automatic style selection for best results'**
  String get auto_style_description;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back_to_login;

  /// No description provided for @beginning_of_video.
  ///
  /// In en, this message translates to:
  /// **'(Beginning of video)'**
  String get beginning_of_video;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @claim_earned_credits.
  ///
  /// In en, this message translates to:
  /// **'Claim Earned Credits'**
  String get claim_earned_credits;

  /// No description provided for @clay_style.
  ///
  /// In en, this message translates to:
  /// **'Clay Style'**
  String get clay_style;

  /// No description provided for @clay_style_description.
  ///
  /// In en, this message translates to:
  /// **'Claymation art style'**
  String get clay_style_description;

  /// No description provided for @comic_style.
  ///
  /// In en, this message translates to:
  /// **'Comic Style'**
  String get comic_style;

  /// No description provided for @comic_style_description.
  ///
  /// In en, this message translates to:
  /// **'Comic book art style'**
  String get comic_style_description;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong!'**
  String get common_error;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @confirm_password_error.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get confirm_password_error;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @createImage.
  ///
  /// In en, this message translates to:
  /// **'Create Image'**
  String get createImage;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @create_account_form.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the form below to create an account'**
  String get create_account_form;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @restorePurchasesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get restorePurchasesSuccess;

  /// No description provided for @restorePurchasesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore.'**
  String get restorePurchasesEmpty;

  /// No description provided for @restorePurchasesError.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases. Please try again.'**
  String get restorePurchasesError;

  /// No description provided for @create_videos_with_prompt_and_image.
  ///
  /// In en, this message translates to:
  /// **'Create videos with your prompt and image'**
  String get create_videos_with_prompt_and_image;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @credential_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'This credential is already in use by another account.'**
  String get credential_already_in_use;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'credit'**
  String get credit;

  /// No description provided for @creditEarned.
  ///
  /// In en, this message translates to:
  /// **'Credits earned'**
  String get creditEarned;

  /// No description provided for @creditsPackPerWeek.
  ///
  /// In en, this message translates to:
  /// **'credits pack/week'**
  String get creditsPackPerWeek;

  /// No description provided for @credits_added_successfully.
  ///
  /// In en, this message translates to:
  /// **'Earned credits have been added to your account!'**
  String get credits_added_successfully;

  /// No description provided for @crop_image.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop_image;

  /// No description provided for @crop_image_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get crop_image_done;

  /// No description provided for @crop_image_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get crop_image_cancel;

  /// No description provided for @crop_image_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get crop_image_reset;

  /// No description provided for @crop_image_rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get crop_image_rotate;

  /// No description provided for @crop_image_flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get crop_image_flip;

  /// No description provided for @crop_image_rotate_left.
  ///
  /// In en, this message translates to:
  /// **'Rotate Left'**
  String get crop_image_rotate_left;

  /// No description provided for @crop_image_rotate_right.
  ///
  /// In en, this message translates to:
  /// **'Rotate Right'**
  String get crop_image_rotate_right;

  /// No description provided for @crop_image_flip_horizontal.
  ///
  /// In en, this message translates to:
  /// **'Flip Horizontal'**
  String get crop_image_flip_horizontal;

  /// No description provided for @crop_image_flip_vertical.
  ///
  /// In en, this message translates to:
  /// **'Flip Vertical'**
  String get crop_image_flip_vertical;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get current_password;

  /// No description provided for @customCreate.
  ///
  /// In en, this message translates to:
  /// **'Custom Create'**
  String get customCreate;

  /// No description provided for @cyberpunk_style.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk Style'**
  String get cyberpunk_style;

  /// No description provided for @cyberpunk_style_description.
  ///
  /// In en, this message translates to:
  /// **'Futuristic cyberpunk aesthetic'**
  String get cyberpunk_style_description;

  /// No description provided for @daily_ads_earned.
  ///
  /// In en, this message translates to:
  /// **'Daily ad credits earned. Come back tomorrow to watch more ads'**
  String get daily_ads_earned;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @describeWhatYouWantToSee.
  ///
  /// In en, this message translates to:
  /// **'Describe what you want to see...'**
  String get describeWhatYouWantToSee;

  /// No description provided for @describe_video_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe the video you want to create...'**
  String get describe_video_hint;

  /// No description provided for @describe_your_video.
  ///
  /// In en, this message translates to:
  /// **'Describe Your Video'**
  String get describe_your_video;

  /// No description provided for @earn_credits.
  ///
  /// In en, this message translates to:
  /// **'Earn Credits'**
  String get earn_credits;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit Username'**
  String get editUsername;

  /// No description provided for @effect.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get effect;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use by another account.'**
  String get email_already_in_use;

  /// No description provided for @email_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get email_error;

  /// No description provided for @empty_error.
  ///
  /// In en, this message translates to:
  /// **'Please fill out this field.'**
  String get empty_error;

  /// No description provided for @end_of_video.
  ///
  /// In en, this message translates to:
  /// **'(End of video)'**
  String get end_of_video;

  /// No description provided for @enterNewUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter new username'**
  String get enterNewUsername;

  /// No description provided for @enterReportReason.
  ///
  /// In en, this message translates to:
  /// **'Enter your report reason...'**
  String get enterReportReason;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail address'**
  String get enterYourEmail;

  /// No description provided for @errorLoadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error loading PDF'**
  String get errorLoadingPdf;

  /// No description provided for @error_adding_credit.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, credit could not be added.'**
  String get error_adding_credit;

  /// No description provided for @fast_mode.
  ///
  /// In en, this message translates to:
  /// **'Fast Mode'**
  String get fast_mode;

  /// No description provided for @fast_mode_incompatible.
  ///
  /// In en, this message translates to:
  /// **'Fast mode is not compatible with 1080p resolution or 8s video length'**
  String get fast_mode_incompatible;

  /// No description provided for @fast_mode_description.
  ///
  /// In en, this message translates to:
  /// **'Faster generation with optimized quality'**
  String get fast_mode_description;

  /// No description provided for @fasterGenerationSpeed.
  ///
  /// In en, this message translates to:
  /// **'Faster generation speed'**
  String get fasterGenerationSpeed;

  /// No description provided for @firstPerson.
  ///
  /// In en, this message translates to:
  /// **'First Person'**
  String get firstPerson;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @generateImagesInstantly.
  ///
  /// In en, this message translates to:
  /// **'Generate images instantly'**
  String get generateImagesInstantly;

  /// No description provided for @generateRealtimeImages.
  ///
  /// In en, this message translates to:
  /// **'Generate realtime images'**
  String get generateRealtimeImages;

  /// No description provided for @generateYourFirstImage.
  ///
  /// In en, this message translates to:
  /// **'Generate your first image'**
  String get generateYourFirstImage;

  /// No description provided for @generateYourFirstVideo.
  ///
  /// In en, this message translates to:
  /// **'Generate your first video'**
  String get generateYourFirstVideo;

  /// No description provided for @generate_with_pollo.
  ///
  /// In en, this message translates to:
  /// **'Generate with Pollo 1.6'**
  String get generate_with_pollo;

  /// No description provided for @getPremium.
  ///
  /// In en, this message translates to:
  /// **'GET A PREMIUM 🔱'**
  String get getPremium;

  /// No description provided for @group_photo.
  ///
  /// In en, this message translates to:
  /// **'Single Photo'**
  String get group_photo;

  /// No description provided for @high_quality.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high_quality;

  /// No description provided for @iHaveReadAndAgreedTo.
  ///
  /// In en, this message translates to:
  /// **'I have read and agreed to the'**
  String get iHaveReadAndAgreedTo;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @imageDetails.
  ///
  /// In en, this message translates to:
  /// **'Image Details'**
  String get imageDetails;

  /// No description provided for @image_data_error.
  ///
  /// In en, this message translates to:
  /// **'Image data could not be retrieved'**
  String get image_data_error;

  /// No description provided for @image_to_video.
  ///
  /// In en, this message translates to:
  /// **'Image to Video'**
  String get image_to_video;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @oneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One Time Purchase'**
  String get oneTimePurchase;

  /// No description provided for @priceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Price Not Available'**
  String get priceNotAvailable;

  /// No description provided for @extraCreditPackages.
  ///
  /// In en, this message translates to:
  /// **'Extra Credit Packages'**
  String get extraCreditPackages;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @creditPackages.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditPackages;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @purchaseNow.
  ///
  /// In en, this message translates to:
  /// **'Purchase Now'**
  String get purchaseNow;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One Time'**
  String get oneTime;

  /// No description provided for @nonRenewable.
  ///
  /// In en, this message translates to:
  /// **'Non-renewable'**
  String get nonRenewable;

  /// No description provided for @trialPackageUsed.
  ///
  /// In en, this message translates to:
  /// **'You have already used your trial package. You can continue by purchasing a subscription.'**
  String get trialPackageUsed;

  /// No description provided for @packagesLoading.
  ///
  /// In en, this message translates to:
  /// **'Packages loading...'**
  String get packagesLoading;

  /// No description provided for @goToSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Purchase Subscription'**
  String get goToSubscriptions;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @userInfoLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user information'**
  String get userInfoLoadError;

  /// No description provided for @creditsAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Credits added successfully!'**
  String get creditsAddedSuccessfully;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @imageTemplates.
  ///
  /// In en, this message translates to:
  /// **'Image Templates'**
  String get imageTemplates;

  /// No description provided for @allImages.
  ///
  /// In en, this message translates to:
  /// **'All Images'**
  String get allImages;

  /// No description provided for @noUserDataFound.
  ///
  /// In en, this message translates to:
  /// **'No user data found'**
  String get noUserDataFound;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get fileSize;

  /// No description provided for @accountDeletionError.
  ///
  /// In en, this message translates to:
  /// **'Account deletion error'**
  String get accountDeletionError;

  /// No description provided for @usernameUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Username updated successfully'**
  String get usernameUpdatedSuccessfully;

  /// No description provided for @imageDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image deleted successfully'**
  String get imageDeletedSuccessfully;

  /// No description provided for @reportSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report sent successfully!'**
  String get reportSentSuccessfully;

  /// No description provided for @verySoon.
  ///
  /// In en, this message translates to:
  /// **'Very soon!'**
  String get verySoon;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful! Credits will be added shortly.'**
  String get purchaseSuccessful;

  /// No description provided for @inputImage.
  ///
  /// In en, this message translates to:
  /// **'Input Image'**
  String get inputImage;

  /// No description provided for @insufficient_credit.
  ///
  /// In en, this message translates to:
  /// **'Insufficient credit'**
  String get insufficient_credit;

  /// No description provided for @invalid_credential.
  ///
  /// In en, this message translates to:
  /// **'Invalid credential. Please try again.'**
  String get invalid_credential;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get invalid_email;

  /// No description provided for @invalid_verification_code.
  ///
  /// In en, this message translates to:
  /// **'The verification code is invalid. Please enter the correct code and try again.'**
  String get invalid_verification_code;

  /// No description provided for @invalid_verification_id.
  ///
  /// In en, this message translates to:
  /// **'The verification ID is invalid. Try restarting the process.'**
  String get invalid_verification_id;

  /// No description provided for @legal_notice.
  ///
  /// In en, this message translates to:
  /// **'To protect your legal rights, please read and agree to our'**
  String get legal_notice;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loading_please_wait.
  ///
  /// In en, this message translates to:
  /// **'Loading, please wait...'**
  String get loading_please_wait;

  /// No description provided for @preparing_credit_info.
  ///
  /// In en, this message translates to:
  /// **'Preparing credit information'**
  String get preparing_credit_info;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @bestPrice.
  ///
  /// In en, this message translates to:
  /// **'Best Price'**
  String get bestPrice;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @length_resolution_incompatible.
  ///
  /// In en, this message translates to:
  /// **'8s video and fast mode not supports 1080p resolution'**
  String get length_resolution_incompatible;

  /// No description provided for @image_aspect_ratio_invalid.
  ///
  /// In en, this message translates to:
  /// **'Image aspect ratio must be between 1:4 and 4:1 (0.25 to 4.0)'**
  String get image_aspect_ratio_invalid;

  /// No description provided for @cropped.
  ///
  /// In en, this message translates to:
  /// **'Cropped'**
  String get cropped;

  /// No description provided for @allEffects.
  ///
  /// In en, this message translates to:
  /// **'All Effects'**
  String get allEffects;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noEffectsFound.
  ///
  /// In en, this message translates to:
  /// **'No Effects Found'**
  String get noEffectsFound;

  /// No description provided for @categoriesEffects.
  ///
  /// In en, this message translates to:
  /// **'Categories Effects'**
  String get categoriesEffects;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showAllEffects.
  ///
  /// In en, this message translates to:
  /// **'Show All Effects'**
  String get showAllEffects;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear your thoughts! Share your feedback, suggestions, or report any issues you\'ve encountered.'**
  String get feedbackDescription;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think about the app, what features you\'d like to see, or any problems you\'ve experienced...'**
  String get feedbackHint;

  /// No description provided for @feedbackRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback'**
  String get feedbackRequired;

  /// No description provided for @feedbackMinLength.
  ///
  /// In en, this message translates to:
  /// **'Feedback must be at least 10 characters long'**
  String get feedbackMinLength;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your feedback has been submitted successfully.'**
  String get feedbackSubmitted;

  /// No description provided for @addImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Add Image (Optional)'**
  String get addImageOptional;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @loadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Loading PDF...'**
  String get loadingPdf;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter your credentials to login.'**
  String get loginDescription;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'login'**
  String get loginTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_confirmation;

  /// No description provided for @guest_logout_warning.
  ///
  /// In en, this message translates to:
  /// **'You are using a guest account. If you logout, all your data will be lost permanently!'**
  String get guest_logout_warning;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @long_video.
  ///
  /// In en, this message translates to:
  /// **'Long Video'**
  String get long_video;

  /// No description provided for @low_quality.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low_quality;

  /// No description provided for @medium_quality.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium_quality;

  /// No description provided for @min_6_chars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 chars'**
  String get min_6_chars;

  /// No description provided for @missing_verification_code.
  ///
  /// In en, this message translates to:
  /// **'The verification code is missing. Please enter the code.'**
  String get missing_verification_code;

  /// No description provided for @missing_verification_id.
  ///
  /// In en, this message translates to:
  /// **'The verification ID is missing. Try restarting the process.'**
  String get missing_verification_id;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @motionMode.
  ///
  /// In en, this message translates to:
  /// **'Motion Mode'**
  String get motionMode;

  /// No description provided for @negative_prompt.
  ///
  /// In en, this message translates to:
  /// **'Negative Prompt'**
  String get negative_prompt;

  /// No description provided for @negative_prompt_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you don\'t want in the video (optional)'**
  String get negative_prompt_hint;

  /// No description provided for @network_request_failed.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed. Please check your internet connection.'**
  String get network_request_failed;

  /// No description provided for @newUsername.
  ///
  /// In en, this message translates to:
  /// **'New Username'**
  String get newUsername;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @noImageGenerated.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t generated any image yet'**
  String get noImageGenerated;

  /// No description provided for @noImageToShare.
  ///
  /// In en, this message translates to:
  /// **'No image to share'**
  String get noImageToShare;

  /// No description provided for @noPasswordChange.
  ///
  /// In en, this message translates to:
  /// **'This account was not logged in with a password, the password cannot be changed'**
  String get noPasswordChange;

  /// No description provided for @noRealtimeImageGenerated.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t generated realtime images yet'**
  String get noRealtimeImageGenerated;

  /// No description provided for @noVideoGenerated.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t generated any video yet'**
  String get noVideoGenerated;

  /// No description provided for @noWatermarksAds.
  ///
  /// In en, this message translates to:
  /// **'No watermarks/ads'**
  String get noWatermarksAds;

  /// No description provided for @normal_mode.
  ///
  /// In en, this message translates to:
  /// **'Normal Mode'**
  String get normal_mode;

  /// No description provided for @normal_mode_description.
  ///
  /// In en, this message translates to:
  /// **'Standard quality with balanced speed'**
  String get normal_mode_description;

  /// No description provided for @operation_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'This operation is currently disabled. Please contact your administrator for more information.'**
  String get operation_not_allowed;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or Login With'**
  String get orLoginWith;

  /// No description provided for @pAndE.
  ///
  /// In en, this message translates to:
  /// **'P&E'**
  String get pAndE;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your e-mail'**
  String get passwordResetLinkSent;

  /// No description provided for @password_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid password.'**
  String get password_error;

  /// No description provided for @passwords_dont_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwords_dont_match;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'per week'**
  String get perWeek;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'You need to grant permission to select a photo'**
  String get permissionRequired;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added!'**
  String get photoAdded;

  /// No description provided for @photo_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Photo is successfully deleted!'**
  String get photo_deleted_successfully;

  /// No description provided for @photo_type.
  ///
  /// In en, this message translates to:
  /// **'Photo Type'**
  String get photo_type;

  /// No description provided for @pixverse_settings.
  ///
  /// In en, this message translates to:
  /// **'Customize Video'**
  String get pixverse_settings;

  /// No description provided for @please_enter_video_description.
  ///
  /// In en, this message translates to:
  /// **'Please enter a video description'**
  String get please_enter_video_description;

  /// No description provided for @pollo_settings.
  ///
  /// In en, this message translates to:
  /// **'Pollo 1.6 Settings'**
  String get pollo_settings;

  /// No description provided for @predictTime.
  ///
  /// In en, this message translates to:
  /// **'Predict Time'**
  String get predictTime;

  /// No description provided for @premiumPackage.
  ///
  /// In en, this message translates to:
  /// **'Premium Package'**
  String get premiumPackage;

  /// No description provided for @processing_request.
  ///
  /// In en, this message translates to:
  /// **'Processing your request...'**
  String get processing_request;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @promptEmpty.
  ///
  /// In en, this message translates to:
  /// **'Prompt cannot be empty'**
  String get promptEmpty;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @realtimeImages.
  ///
  /// In en, this message translates to:
  /// **'Realtime Images'**
  String get realtimeImages;

  /// No description provided for @repeat_new_password.
  ///
  /// In en, this message translates to:
  /// **'Repeat New Password'**
  String get repeat_new_password;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContent;

  /// No description provided for @reportReason.
  ///
  /// In en, this message translates to:
  /// **'Please specify why this content is inappropriate'**
  String get reportReason;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully submitted! It will be reviewed as soon as possible and you will be notified'**
  String get reportSuccess;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @requires_recent_login.
  ///
  /// In en, this message translates to:
  /// **'You need to log in again to perform this operation.'**
  String get requires_recent_login;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @secondPerson.
  ///
  /// In en, this message translates to:
  /// **'Second Person'**
  String get secondPerson;

  /// No description provided for @secure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get secure;

  /// No description provided for @select_start_image.
  ///
  /// In en, this message translates to:
  /// **'Select Start Image'**
  String get select_start_image;

  /// No description provided for @select_tail_image.
  ///
  /// In en, this message translates to:
  /// **'Select Tail Image'**
  String get select_tail_image;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @separate_photos.
  ///
  /// In en, this message translates to:
  /// **'2 separate photos'**
  String get separate_photos;

  /// No description provided for @short_video.
  ///
  /// In en, this message translates to:
  /// **'Short Video'**
  String get short_video;

  /// No description provided for @signup_button_link.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup_button_link;

  /// No description provided for @signup_button_text.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get signup_button_text;

  /// No description provided for @startGenerating.
  ///
  /// In en, this message translates to:
  /// **'Start Generating'**
  String get startGenerating;

  /// No description provided for @start_image.
  ///
  /// In en, this message translates to:
  /// **'Start Image'**
  String get start_image;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get submitReport;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully'**
  String get successfully;

  /// No description provided for @tail_image.
  ///
  /// In en, this message translates to:
  /// **'Tail Image'**
  String get tail_image;

  /// No description provided for @terms_of_service_required.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Terms of Service and Privacy Policy to continue.'**
  String get terms_of_service_required;

  /// No description provided for @text_to_video.
  ///
  /// In en, this message translates to:
  /// **'Text to Video'**
  String get text_to_video;

  /// No description provided for @threeDAnimationStyle.
  ///
  /// In en, this message translates to:
  /// **'3D Animation'**
  String get threeDAnimationStyle;

  /// No description provided for @threeDAnimationStyleDescription.
  ///
  /// In en, this message translates to:
  /// **'Three-dimensional animation style'**
  String get threeDAnimationStyleDescription;

  /// No description provided for @too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Access to your account has been temporarily blocked. Please try again later.'**
  String get too_many_requests;

  /// No description provided for @trendingVideoEffects.
  ///
  /// In en, this message translates to:
  /// **'Trending AI Video Effects'**
  String get trendingVideoEffects;

  /// No description provided for @tryNow.
  ///
  /// In en, this message translates to:
  /// **'Try Now'**
  String get tryNow;

  /// No description provided for @typeYourPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type your prompt below to generate realtime images'**
  String get typeYourPrompt;

  /// No description provided for @ultra_quality.
  ///
  /// In en, this message translates to:
  /// **'Ultra'**
  String get ultra_quality;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get unlockAllFeatures;

  /// No description provided for @uploadIfSamePhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload if both people are in the same photo'**
  String get uploadIfSamePhoto;

  /// No description provided for @upload_images.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get upload_images;

  /// No description provided for @upload_photo.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get upload_photo;

  /// No description provided for @upload_photos.
  ///
  /// In en, this message translates to:
  /// **'Upload Photos'**
  String get upload_photos;

  /// No description provided for @useAIVideoEffects.
  ///
  /// In en, this message translates to:
  /// **'Use AI Video Effects'**
  String get useAIVideoEffects;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User Not Found'**
  String get userNotFound;

  /// No description provided for @user_disabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get user_disabled;

  /// No description provided for @user_not_found.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email address.'**
  String get user_not_found;

  /// No description provided for @user_summary_screen.
  ///
  /// In en, this message translates to:
  /// **'User Summary Screen'**
  String get user_summary_screen;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @videoDetails.
  ///
  /// In en, this message translates to:
  /// **'Video Details'**
  String get videoDetails;

  /// No description provided for @videoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Video Generate'**
  String get videoGenerate;

  /// No description provided for @video_generation_error.
  ///
  /// In en, this message translates to:
  /// **'Video generation failed. Please try again.'**
  String get video_generation_error;

  /// No description provided for @video_generation_started.
  ///
  /// In en, this message translates to:
  /// **'Video generation started...'**
  String get video_generation_started;

  /// No description provided for @video_generation_success.
  ///
  /// In en, this message translates to:
  /// **'Your video is being created. This process takes 10-60 seconds'**
  String get video_generation_success;

  /// No description provided for @video_preview_error.
  ///
  /// In en, this message translates to:
  /// **'Preview could not be loaded'**
  String get video_preview_error;

  /// No description provided for @video_preview_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading video preview...'**
  String get video_preview_loading;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @watchAdToEarn.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video ad to earn 20 credits'**
  String get watchAdToEarn;

  /// No description provided for @watchAds.
  ///
  /// In en, this message translates to:
  /// **'Watch Ads'**
  String get watchAds;

  /// No description provided for @watchLimit.
  ///
  /// In en, this message translates to:
  /// **'(You can watch up to 3 ads per day)'**
  String get watchLimit;

  /// No description provided for @watch_5_ads_to_claim.
  ///
  /// In en, this message translates to:
  /// **'You need to watch 3 ads to claim credits.'**
  String get watch_5_ads_to_claim;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequired;

  /// No description provided for @emailVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to verify your email address to continue claiming credits. This helps prevent abuse and ensures account security.'**
  String get emailVerificationMessage;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Please check your inbox and click the verification link.'**
  String get verificationEmailSent;

  /// No description provided for @sendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Email'**
  String get sendVerificationEmail;

  /// No description provided for @checkVerification.
  ///
  /// In en, this message translates to:
  /// **'Check Verification'**
  String get checkVerification;

  /// No description provided for @errorSendingVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Error sending verification email. Please try again.'**
  String get errorSendingVerificationEmail;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully! You can now claim your credits.'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox and click the verification link.'**
  String get emailNotVerifiedYet;

  /// No description provided for @errorCheckingVerification.
  ///
  /// In en, this message translates to:
  /// **'Error checking verification status. Please try again.'**
  String get errorCheckingVerification;

  /// No description provided for @watch_ad.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad to Earn Credits'**
  String get watch_ad;

  /// No description provided for @weak_password.
  ///
  /// In en, this message translates to:
  /// **'The password you entered is too weak. Please choose a stronger password.'**
  String get weak_password;

  /// No description provided for @weeklyPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly Plan'**
  String get weeklyPlan;

  /// No description provided for @wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get wrong_password;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlan;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @realtimeAI.
  ///
  /// In en, this message translates to:
  /// **'Realtime AI'**
  String get realtimeAI;

  /// No description provided for @filterByCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategoryTooltip;

  /// No description provided for @toggleGridLayoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle Grid Layout'**
  String get toggleGridLayoutTooltip;

  /// No description provided for @effects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get effects;

  /// No description provided for @deleteVideo.
  ///
  /// In en, this message translates to:
  /// **'Delete Video'**
  String get deleteVideo;

  /// No description provided for @deleteVideoConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this video?'**
  String get deleteVideoConfirmation;

  /// No description provided for @videoDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Video deleted successfully'**
  String get videoDeletedSuccessfully;

  /// No description provided for @templateRegenerationStarted.
  ///
  /// In en, this message translates to:
  /// **'Template regeneration started with seed: {seed}'**
  String templateRegenerationStarted(Object seed);

  /// No description provided for @failedToRegenerateTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to regenerate template'**
  String get failedToRegenerateTemplate;

  /// No description provided for @noInputDataForTemplateRegeneration.
  ///
  /// In en, this message translates to:
  /// **'No input data found for template regeneration'**
  String get noInputDataForTemplateRegeneration;

  /// No description provided for @videoRegenerationStarted.
  ///
  /// In en, this message translates to:
  /// **'Generating different version of video'**
  String get videoRegenerationStarted;

  /// No description provided for @failedToRegenerateVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to regenerate video'**
  String get failedToRegenerateVideo;

  /// No description provided for @noInputDataForRegeneration.
  ///
  /// In en, this message translates to:
  /// **'No input data found for regeneration'**
  String get noInputDataForRegeneration;

  /// No description provided for @reportSending.
  ///
  /// In en, this message translates to:
  /// **'Sending report...'**
  String get reportSending;

  /// No description provided for @reportFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send report. Please try again.'**
  String get reportFailedToSend;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @deleteImageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get deleteImageConfirmation;

  /// No description provided for @videoIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Video ID copied!'**
  String get videoIdCopied;

  /// No description provided for @promptCopied.
  ///
  /// In en, this message translates to:
  /// **'Prompt copied!'**
  String get promptCopied;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard!'**
  String get emailCopied;

  /// No description provided for @fileSizeTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File size too large (max 10MB)'**
  String get fileSizeTooLarge;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(Object error);

  /// No description provided for @failedToSubmitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit feedback'**
  String get failedToSubmitFeedback;

  /// No description provided for @videoGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Video Generation Failed'**
  String get videoGenerationFailed;

  /// No description provided for @videoGenerationFailedDescription.
  ///
  /// In en, this message translates to:
  /// **'To avoid being filtered, please enter your entries with a different wording?'**
  String get videoGenerationFailedDescription;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @refundCredit.
  ///
  /// In en, this message translates to:
  /// **'Refund Credit'**
  String get refundCredit;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @toAvoidFiltering.
  ///
  /// In en, this message translates to:
  /// **'To avoid filtering, copy the command and explain it slightly differently.'**
  String get toAvoidFiltering;

  /// No description provided for @errorProcessingRefund.
  ///
  /// In en, this message translates to:
  /// **'Error processing refund. Please try again.'**
  String get errorProcessingRefund;

  /// No description provided for @creditRequirementsNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Credit requirements not loaded. Please try again.'**
  String get creditRequirementsNotLoaded;

  /// No description provided for @refundProcessedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Refund processed successfully!'**
  String get refundProcessedSuccessfully;

  /// No description provided for @refundFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund failed. Please try again.'**
  String get refundFailed;

  /// No description provided for @refundProcessedSuccessfullyWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Refund processed successfully!'**
  String get refundProcessedSuccessfullyWithMessage;

  /// No description provided for @nameSurname.
  ///
  /// In en, this message translates to:
  /// **'Name Surname'**
  String get nameSurname;

  /// No description provided for @effectSearch.
  ///
  /// In en, this message translates to:
  /// **'Search effect...'**
  String get effectSearch;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @uidCopied.
  ///
  /// In en, this message translates to:
  /// **'UID copied!'**
  String get uidCopied;

  /// No description provided for @uid.
  ///
  /// In en, this message translates to:
  /// **'UID'**
  String get uid;

  /// No description provided for @negativePrompt.
  ///
  /// In en, this message translates to:
  /// **'Negative Prompt'**
  String get negativePrompt;

  /// No description provided for @negativePromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter negative prompt to avoid unwanted elements...'**
  String get negativePromptHint;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Check out this image I created on Comby! Download App: app.comby.ai'**
  String get shareText;

  /// No description provided for @shareTextFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Check out this image I created on Comby!\nDownload App: app.comby.ai'**
  String get shareTextFromUrl;

  /// No description provided for @shareVideoText.
  ///
  /// In en, this message translates to:
  /// **'Check out this video I created on Comby AI! Download App: app.comby.ai'**
  String get shareVideoText;

  /// No description provided for @reviewRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock 2nd Video'**
  String get reviewRequiredTitle;

  /// No description provided for @reviewRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please rate our app to create your 2nd video!'**
  String get reviewRequiredMessage;

  /// No description provided for @reviewRequiredButton.
  ///
  /// In en, this message translates to:
  /// **'Rate 5 Stars & Create 2nd Video'**
  String get reviewRequiredButton;

  /// No description provided for @reviewRequiredBonus.
  ///
  /// In en, this message translates to:
  /// **'Unlock 2nd Video!'**
  String get reviewRequiredBonus;

  /// No description provided for @errorLoadingCredits.
  ///
  /// In en, this message translates to:
  /// **'Error loading credits'**
  String get errorLoadingCredits;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get uploadPhoto;

  /// No description provided for @refundCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund Credit'**
  String get refundCreditTitle;

  /// No description provided for @refundCreditDescription.
  ///
  /// In en, this message translates to:
  /// **'To avoid being filtered, please enter your entries with a different wording'**
  String get refundCreditDescription;

  /// No description provided for @refundProcessedSuccessfullyDefault.
  ///
  /// In en, this message translates to:
  /// **'Refund processed successfully!'**
  String get refundProcessedSuccessfullyDefault;

  /// No description provided for @refundLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Refund Limit Reached'**
  String get refundLimitReached;

  /// No description provided for @refundLimitReachedDescription.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum refund limit ({count}/10).'**
  String refundLimitReachedDescription(Object count);

  /// No description provided for @subscriptionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Subscription successful!'**
  String get subscriptionSuccessful;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Warning'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountWarningDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.\n\n• All your usage rights will be reset\n• All generated content will be permanently deleted\n• All credits and subscriptions will be lost\n• Your profile and data will be removed'**
  String get deleteAccountWarningDescription;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted!'**
  String get accountDeletedSuccessfully;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @purchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchaseButton;

  /// No description provided for @deletedUser.
  ///
  /// In en, this message translates to:
  /// **'Deleted User'**
  String get deletedUser;

  /// No description provided for @counterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Counter completed'**
  String get counterCompleted;

  /// No description provided for @offeringsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Offerings empty'**
  String get offeringsEmpty;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Comby'**
  String get appName;

  /// No description provided for @fileLabel.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeLabel;

  /// No description provided for @errorWithSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithSnapshot(Object error);

  /// No description provided for @fileText.
  ///
  /// In en, this message translates to:
  /// **'File: {fileName}'**
  String fileText(Object fileName);

  /// No description provided for @sizeText.
  ///
  /// In en, this message translates to:
  /// **'Size: {fileSize}'**
  String sizeText(Object fileSize);

  /// No description provided for @artistCredit.
  ///
  /// In en, this message translates to:
  /// **'HISTED, TXVSTERPLAYA - MASHA ULTRAFUNK'**
  String get artistCredit;

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'Insufficient credits. Required: {required}, Available: {available}'**
  String insufficientCredits(Object available, Object required);

  /// No description provided for @viralEffectsOnTiktok.
  ///
  /// In en, this message translates to:
  /// **'Viral Effects On Tiktok'**
  String get viralEffectsOnTiktok;

  /// No description provided for @viralOnTiktok.
  ///
  /// In en, this message translates to:
  /// **'Viral on TikTok'**
  String get viralOnTiktok;

  /// No description provided for @wtfEffects.
  ///
  /// In en, this message translates to:
  /// **'WTF Effects'**
  String get wtfEffects;

  /// No description provided for @videoTab.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoTab;

  /// No description provided for @imageTab.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageTab;

  /// No description provided for @heifFormatWarning.
  ///
  /// In en, this message translates to:
  /// **'HEIF Format Uyarısı'**
  String get heifFormatWarning;

  /// No description provided for @pixverseCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Pixverse Uyumluluğu'**
  String get pixverseCompatibility;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'İptal'**
  String get cancelButton;

  /// No description provided for @person1.
  ///
  /// In en, this message translates to:
  /// **'Person 1'**
  String get person1;

  /// No description provided for @person2.
  ///
  /// In en, this message translates to:
  /// **'Person 2'**
  String get person2;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @promptLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompt: '**
  String get promptLabel;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: '**
  String get idLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: '**
  String get durationLabel;

  /// No description provided for @startedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Started At: '**
  String get startedAtLabel;

  /// No description provided for @completedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed At: '**
  String get completedAtLabel;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorLabel;

  /// No description provided for @webLabel.
  ///
  /// In en, this message translates to:
  /// **'Web: '**
  String get webLabel;

  /// No description provided for @streamLabel.
  ///
  /// In en, this message translates to:
  /// **'Stream: '**
  String get streamLabel;

  /// No description provided for @getLabel.
  ///
  /// In en, this message translates to:
  /// **'Get: '**
  String get getLabel;

  /// No description provided for @logsLabel.
  ///
  /// In en, this message translates to:
  /// **'Logs: '**
  String get logsLabel;

  /// No description provided for @regenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateButton;

  /// No description provided for @guestPurchase.
  ///
  /// In en, this message translates to:
  /// **'Guest Purchase'**
  String get guestPurchase;

  /// No description provided for @guestPurchaseDescription.
  ///
  /// In en, this message translates to:
  /// **'You can purchase as a guest user. However, creating an account will enable you to:'**
  String get guestPurchaseDescription;

  /// No description provided for @guestBenefit1.
  ///
  /// In en, this message translates to:
  /// **'• Access purchased content from any of your supported devices'**
  String get guestBenefit1;

  /// No description provided for @guestBenefit2.
  ///
  /// In en, this message translates to:
  /// **'• Sync your data across devices'**
  String get guestBenefit2;

  /// No description provided for @guestBenefit3.
  ///
  /// In en, this message translates to:
  /// **'• Secure your purchases and content'**
  String get guestBenefit3;

  /// No description provided for @guestPurchaseFooter.
  ///
  /// In en, this message translates to:
  /// **'You can create an account at any time to extend access to additional devices.'**
  String get guestPurchaseFooter;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @rateOurApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Our App'**
  String get rateOurApp;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with Comby AI?'**
  String get howWasYourExperience;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @upgradeToFullAccount.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Full Account'**
  String get upgradeToFullAccount;

  /// No description provided for @upgradeYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Your Account'**
  String get upgradeYourAccount;

  /// No description provided for @upgradeAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Convert your guest account to a full account:\n• Keep all your credits ({credits})\n• Keep all your videos and content\n• Sync data across devices\n• Secure your account with password'**
  String upgradeAccountDescription(Object credits);

  /// No description provided for @dataWillBePreserved.
  ///
  /// In en, this message translates to:
  /// **'✅ Your data will be preserved!'**
  String get dataWillBePreserved;

  /// No description provided for @upgradeAccount.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Account'**
  String get upgradeAccount;

  /// No description provided for @combyAiPlusPlan.
  ///
  /// In en, this message translates to:
  /// **'Comby AI Plus Plan'**
  String get combyAiPlusPlan;

  /// No description provided for @combyAiProPlan.
  ///
  /// In en, this message translates to:
  /// **'Comby AI Pro Plan'**
  String get combyAiProPlan;

  /// No description provided for @combyAiUltraPlan.
  ///
  /// In en, this message translates to:
  /// **'Comby AI Ultra Plan'**
  String get combyAiUltraPlan;

  /// No description provided for @selectPhotosForBothPeople.
  ///
  /// In en, this message translates to:
  /// **'Select photos for both people'**
  String get selectPhotosForBothPeople;

  /// No description provided for @uploadFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload First\nphoto'**
  String get uploadFirstPhoto;

  /// No description provided for @uploadSecondaryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Secondary\nphoto'**
  String get uploadSecondaryPhoto;

  /// No description provided for @subscriptionRequiredForCredits.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to purchase extra credits'**
  String get subscriptionRequiredForCredits;

  /// No description provided for @getSubscriptionFirst.
  ///
  /// In en, this message translates to:
  /// **'Get Subscription First'**
  String get getSubscriptionFirst;

  /// No description provided for @selectASinglePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select a single photo'**
  String get selectASinglePhoto;

  /// No description provided for @extraCreditsDescription.
  ///
  /// In en, this message translates to:
  /// **'Extra credits are available only for premium subscribers. Get a subscription to unlock unlimited possibilities!'**
  String get extraCreditsDescription;

  /// No description provided for @freeCredit.
  ///
  /// In en, this message translates to:
  /// **'Free Credit'**
  String get freeCredit;

  /// No description provided for @earnFreeCredits.
  ///
  /// In en, this message translates to:
  /// **'Earn Free Credits'**
  String get earnFreeCredits;

  /// No description provided for @freeCreditWays.
  ///
  /// In en, this message translates to:
  /// **'Ways to Earn Free Credits'**
  String get freeCreditWays;

  /// No description provided for @freeCreditDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow these simple steps to earn free credits'**
  String get freeCreditDescription;

  /// No description provided for @watchAdEarnCredit.
  ///
  /// In en, this message translates to:
  /// **'Watch Ads'**
  String get watchAdEarnCredit;

  /// No description provided for @watchAdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn credits by watching video ads'**
  String get watchAdSubtitle;

  /// No description provided for @rateAppEarnCredit.
  ///
  /// In en, this message translates to:
  /// **'Rate Our App'**
  String get rateAppEarnCredit;

  /// No description provided for @rateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate 5 stars, write a review and unlock 2nd video'**
  String get rateAppSubtitle;

  /// No description provided for @freeCreditInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get freeCreditInfo;

  /// No description provided for @freeCreditInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Earned credits will be added automatically.'**
  String get freeCreditInfoDescription;

  /// No description provided for @reviewConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewConfirmationTitle;

  /// No description provided for @reviewConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Did you rate our app?'**
  String get reviewConfirmationMessage;

  /// No description provided for @reviewConfirmationMessageIOS.
  ///
  /// In en, this message translates to:
  /// **'Did you rate our app in the App Store?'**
  String get reviewConfirmationMessageIOS;

  /// No description provided for @reviewConfirmationMessageAndroid.
  ///
  /// In en, this message translates to:
  /// **'Did you rate our app in the Play Store?'**
  String get reviewConfirmationMessageAndroid;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesIRated.
  ///
  /// In en, this message translates to:
  /// **'Yes, I Rated'**
  String get yesIRated;

  /// No description provided for @reviewThanksWithCredit.
  ///
  /// In en, this message translates to:
  /// **'✅ Thank you! You can now create your 2nd video.'**
  String get reviewThanksWithCredit;

  /// No description provided for @reviewThanksWithoutCredit.
  ///
  /// In en, this message translates to:
  /// **'😊 Thank you! We appreciate your feedback.'**
  String get reviewThanksWithoutCredit;

  /// No description provided for @reviewCompletedNoCredit.
  ///
  /// In en, this message translates to:
  /// **'✅ Review completed! Now you can create your 2nd video.'**
  String get reviewCompletedNoCredit;

  /// No description provided for @reviewPageError.
  ///
  /// In en, this message translates to:
  /// **'Could not open review page. Please try again.'**
  String get reviewPageError;

  /// No description provided for @veryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get veryPoor;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @ratingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating!'**
  String get ratingSubmitted;

  /// No description provided for @redirectingToFeedback.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to feedback page...'**
  String get redirectingToFeedback;

  /// No description provided for @reviewCreditAlreadyClaimed.
  ///
  /// In en, this message translates to:
  /// **'You have already claimed your review credit!'**
  String get reviewCreditAlreadyClaimed;

  /// No description provided for @upgradeAccountForReviewCredit.
  ///
  /// In en, this message translates to:
  /// **'To claim 60 free credits, please upgrade your account first'**
  String get upgradeAccountForReviewCredit;

  /// No description provided for @upgradeAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Account Upgrade Required'**
  String get upgradeAccountRequired;

  /// No description provided for @upgradeAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to upgrade your account to claim free credits. Upgrade now to unlock this feature!'**
  String get upgradeAccountMessage;

  /// No description provided for @deviceAlreadyClaimedReviewCredit.
  ///
  /// In en, this message translates to:
  /// **'This device has already completed the review!'**
  String get deviceAlreadyClaimedReviewCredit;

  /// No description provided for @deviceReviewCreditMessage.
  ///
  /// In en, this message translates to:
  /// **'Review has already been completed on this device. Each device can only review once.'**
  String get deviceReviewCreditMessage;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @redirectingToPayment.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to payment...'**
  String get redirectingToPayment;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Comby...'**
  String get initializing;

  /// No description provided for @loadingThemes.
  ///
  /// In en, this message translates to:
  /// **'Preparing magic...'**
  String get loadingThemes;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Getting creative...'**
  String get settingLanguage;

  /// No description provided for @loadingAds.
  ///
  /// In en, this message translates to:
  /// **'Unleashing AI power...'**
  String get loadingAds;

  /// No description provided for @configuringPayments.
  ///
  /// In en, this message translates to:
  /// **'Almost there...'**
  String get configuringPayments;

  /// No description provided for @almostReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to create...'**
  String get almostReady;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get ready;

  /// No description provided for @aiVideoEffects.
  ///
  /// In en, this message translates to:
  /// **'AI Video Effects'**
  String get aiVideoEffects;

  /// No description provided for @bannedContentDetected.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Content Detected'**
  String get bannedContentDetected;

  /// No description provided for @bannedContentMessage.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content was detected in your prompt. Please use a more appropriate expression.'**
  String get bannedContentMessage;

  /// No description provided for @detectedWord.
  ///
  /// In en, this message translates to:
  /// **'Detected word: '**
  String get detectedWord;

  /// No description provided for @pleaseEditPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please edit your prompt and try again.'**
  String get pleaseEditPrompt;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @libraryRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Library refreshed'**
  String get libraryRefreshed;

  /// No description provided for @image_size_too_large.
  ///
  /// In en, this message translates to:
  /// **'Image size is too large. Maximum size is 4000x4000 pixels.'**
  String get image_size_too_large;

  /// No description provided for @deneme.
  ///
  /// In en, this message translates to:
  /// **'Deneme'**
  String get deneme;

  /// No description provided for @ticket_hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get ticket_hot;

  /// No description provided for @ticket_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ticket_new;

  /// No description provided for @ticket_trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get ticket_trend;

  /// No description provided for @ticket_popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get ticket_popular;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to update to the latest version to continue using the app.'**
  String get forceUpdateMessage;

  /// No description provided for @forceUpdateInfo.
  ///
  /// In en, this message translates to:
  /// **'New features and improvements await you!'**
  String get forceUpdateInfo;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @premiumTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Template'**
  String get premiumTemplateTitle;

  /// No description provided for @premiumTemplateUsedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used your free trial for this premium template.'**
  String get premiumTemplateUsedMessage;

  /// No description provided for @unlimitedUsage.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Usage'**
  String get unlimitedUsage;

  /// No description provided for @premiumTemplateUnlimitedInfo.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited access to premium templates by subscribing or purchasing credit packages.'**
  String get premiumTemplateUnlimitedInfo;

  /// No description provided for @buySubscriptionOrCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy Subscription/Credits'**
  String get buySubscriptionOrCredits;

  /// No description provided for @continueWithOtherTemplates.
  ///
  /// In en, this message translates to:
  /// **'Continue with Other Templates'**
  String get continueWithOtherTemplates;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @welcome_messages.
  ///
  /// In en, this message translates to:
  /// **'How do you want to look today?'**
  String get welcome_messages;

  /// No description provided for @closet_welcome_messages.
  ///
  /// In en, this message translates to:
  /// **'Wow! Your pieces are amazing ✨|Your closet looks great 👗|What will you wear today? 🤔|Your style speaks 🗣️|Time to make an outfit! 🎨|Show your style! 💃|You picked great pieces 👌|You look very stylish today 😎|Your closet is full of stars ⭐|Your outfits are inspiring 💡|Unique pieces! 💎|You are the style icon 👑'**
  String get closet_welcome_messages;

  /// No description provided for @guestAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest Account'**
  String get guestAccountTitle;

  /// No description provided for @guestAccountWatchAdsMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to create an account to watch ads and earn credits.'**
  String get guestAccountWatchAdsMessage;

  /// No description provided for @guestAccountBenefits.
  ///
  /// In en, this message translates to:
  /// **'Account Benefits:'**
  String get guestAccountBenefits;

  /// No description provided for @benefitWatchAds.
  ///
  /// In en, this message translates to:
  /// **'Watch ads and earn free credits'**
  String get benefitWatchAds;

  /// No description provided for @benefitCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync and backup'**
  String get benefitCloudSync;

  /// No description provided for @benefitPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Access to premium features'**
  String get benefitPremiumFeatures;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInWithAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Account'**
  String get signInWithAccount;

  /// No description provided for @combineDetail.
  ///
  /// In en, this message translates to:
  /// **'Combine Detail'**
  String get combineDetail;

  /// No description provided for @aiCombine.
  ///
  /// In en, this message translates to:
  /// **'AI Combine'**
  String get aiCombine;

  /// No description provided for @tryOnMode.
  ///
  /// In en, this message translates to:
  /// **'Try-On Mode'**
  String get tryOnMode;

  /// No description provided for @quickTryOn.
  ///
  /// In en, this message translates to:
  /// **'Quick Try-On'**
  String get quickTryOn;

  /// No description provided for @weatherSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Weather Suggestion'**
  String get weatherSuggestion;

  /// No description provided for @weatherRenewed.
  ///
  /// In en, this message translates to:
  /// **'Weather (Renewed)'**
  String get weatherRenewed;

  /// No description provided for @usedItems.
  ///
  /// In en, this message translates to:
  /// **'Used Items'**
  String get usedItems;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @gemini3.
  ///
  /// In en, this message translates to:
  /// **'Gemini 3'**
  String get gemini3;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImage;

  /// No description provided for @shareCombineText.
  ///
  /// In en, this message translates to:
  /// **'I\'m sharing my combine from Comby! 🌟'**
  String get shareCombineText;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Share error'**
  String get shareError;

  /// No description provided for @photoSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo saved to gallery! ✅'**
  String get photoSavedToGallery;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Save error'**
  String get saveError;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed.'**
  String get operationFailed;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @imageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image could not be loaded.'**
  String get imageLoadFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'You need to log in'**
  String get loginRequired;

  /// No description provided for @modelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Model deleted'**
  String get modelDeleted;

  /// No description provided for @imageGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Image could not be generated.'**
  String get imageGenerationFailed;

  /// No description provided for @combineCritiqueSaved.
  ///
  /// In en, this message translates to:
  /// **'Combine critique saved!'**
  String get combineCritiqueSaved;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @styleAnalysisUpdated.
  ///
  /// In en, this message translates to:
  /// **'Style analysis updated!'**
  String get styleAnalysisUpdated;

  /// No description provided for @styleAnalysisLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Style analysis could not be loaded. Please try again.'**
  String get styleAnalysisLoadFailed;

  /// No description provided for @pastCombines.
  ///
  /// In en, this message translates to:
  /// **'Past Combines'**
  String get pastCombines;

  /// No description provided for @wardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobe;

  /// No description provided for @models.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get models;

  /// No description provided for @combines.
  ///
  /// In en, this message translates to:
  /// **'Combines'**
  String get combines;

  /// No description provided for @critiques.
  ///
  /// In en, this message translates to:
  /// **'Critiques'**
  String get critiques;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @addModel.
  ///
  /// In en, this message translates to:
  /// **'Add Model'**
  String get addModel;

  /// No description provided for @modelAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Model added successfully'**
  String get modelAddedSuccessfully;

  /// No description provided for @processCompleted.
  ///
  /// In en, this message translates to:
  /// **'Process Completed'**
  String get processCompleted;

  /// No description provided for @noAdPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to watch ads.'**
  String get noAdPermission;

  /// No description provided for @requestSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully! Combine is being prepared...'**
  String get requestSentSuccessfully;

  /// No description provided for @pleaseSelectModelAndCloth.
  ///
  /// In en, this message translates to:
  /// **'Please select a model and at least one cloth'**
  String get pleaseSelectModelAndCloth;

  /// No description provided for @surpriseMe.
  ///
  /// In en, this message translates to:
  /// **'Surprise Me'**
  String get surpriseMe;

  /// No description provided for @felt.
  ///
  /// In en, this message translates to:
  /// **'Felt'**
  String get felt;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @wardrobeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wardrobe is empty! Add items.'**
  String get wardrobeEmpty;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @favoriteStyle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Style'**
  String get favoriteStyle;

  /// No description provided for @noRecordFoundForDate.
  ///
  /// In en, this message translates to:
  /// **'No record found for this date.'**
  String get noRecordFoundForDate;

  /// No description provided for @colorOptional.
  ///
  /// In en, this message translates to:
  /// **'Color (Optional)'**
  String get colorOptional;

  /// No description provided for @patternOptional.
  ///
  /// In en, this message translates to:
  /// **'Pattern (Optional)'**
  String get patternOptional;

  /// No description provided for @seasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Season (Optional)'**
  String get seasonOptional;

  /// No description provided for @fabricOptional.
  ///
  /// In en, this message translates to:
  /// **'Fabric (Optional)'**
  String get fabricOptional;

  /// No description provided for @bodyMapImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Body Map Image Not Found'**
  String get bodyMapImageNotFound;

  /// No description provided for @addClosetItem.
  ///
  /// In en, this message translates to:
  /// **'Add Closet Item'**
  String get addClosetItem;

  /// No description provided for @itemDetailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Item Details (Optional)'**
  String get itemDetailsOptional;

  /// No description provided for @combineResult.
  ///
  /// In en, this message translates to:
  /// **'Combine Result'**
  String get combineResult;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparing;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @photosAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} photos added successfully!'**
  String photosAddedSuccessfully(int count, int total);

  /// No description provided for @allPhotosAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'All photos added successfully!'**
  String get allPhotosAddedSuccessfully;

  /// No description provided for @modelsAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} models added successfully!'**
  String modelsAddedSuccessfully(int count, int total);

  /// No description provided for @allModelsAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'All models added successfully!'**
  String get allModelsAddedSuccessfully;

  /// No description provided for @aiAnalysisComplete.
  ///
  /// In en, this message translates to:
  /// **'✨ AI Analysis Complete! Found: {category}'**
  String aiAnalysisComplete(String category);

  /// No description provided for @aiAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Failed: {error}'**
  String aiAnalysisFailed(String error);

  /// No description provided for @noStreakYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t caught a streak yet. Start today!'**
  String get noStreakYet;

  /// No description provided for @headFace.
  ///
  /// In en, this message translates to:
  /// **'Head / Face'**
  String get headFace;

  /// No description provided for @upperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBody;

  /// No description provided for @lowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBody;

  /// No description provided for @feet.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get feet;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @analysisLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis could not be loaded. Please check your internet connection.'**
  String get analysisLoadFailed;

  /// No description provided for @styleExplorer.
  ///
  /// In en, this message translates to:
  /// **'Style Explorer'**
  String get styleExplorer;

  /// No description provided for @analyzingWithGemini3.
  ///
  /// In en, this message translates to:
  /// **'Analyzing with Gemini 3...'**
  String get analyzingWithGemini3;

  /// No description provided for @removingBackground.
  ///
  /// In en, this message translates to:
  /// **'Removing background...'**
  String get removingBackground;

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @analyzingModel.
  ///
  /// In en, this message translates to:
  /// **'Analyzing model...'**
  String get analyzingModel;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @notAFashionItem.
  ///
  /// In en, this message translates to:
  /// **'This photo is not a clothing item or accessory'**
  String get notAFashionItem;

  /// No description provided for @brandOptional.
  ///
  /// In en, this message translates to:
  /// **'Brand (Optional)'**
  String get brandOptional;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category: {category}'**
  String selectCategory(String category);

  /// No description provided for @handsWrists.
  ///
  /// In en, this message translates to:
  /// **'Hands / Wrists'**
  String get handsWrists;

  /// No description provided for @upperTorso.
  ///
  /// In en, this message translates to:
  /// **'Upper Torso'**
  String get upperTorso;

  /// No description provided for @lowerTorso.
  ///
  /// In en, this message translates to:
  /// **'Lower Torso'**
  String get lowerTorso;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @checks.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get checks;

  /// No description provided for @colorMatch.
  ///
  /// In en, this message translates to:
  /// **'Color Match'**
  String get colorMatch;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning {name} ☀️'**
  String goodMorning(String name);

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon {name} 👋'**
  String goodAfternoon(String name);

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening {name} 🌙'**
  String goodEvening(String name);

  /// No description provided for @homeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeDashboard;

  /// No description provided for @homeCloset.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get homeCloset;

  /// No description provided for @homeChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get homeChat;

  /// No description provided for @homeTryOn.
  ///
  /// In en, this message translates to:
  /// **'Try-On'**
  String get homeTryOn;

  /// No description provided for @locationNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Location not received'**
  String get locationNotReceived;

  /// No description provided for @weatherInfoNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Weather info not received'**
  String get weatherInfoNotReceived;

  /// No description provided for @needToAddModel.
  ///
  /// In en, this message translates to:
  /// **'You need to add a model'**
  String get needToAddModel;

  /// No description provided for @needToAddCloth.
  ///
  /// In en, this message translates to:
  /// **'You need to add clothes to your wardrobe'**
  String get needToAddCloth;

  /// No description provided for @outfitSuggestionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create outfit suggestion'**
  String get outfitSuggestionFailed;

  /// No description provided for @loadingWeather.
  ///
  /// In en, this message translates to:
  /// **'Loading weather...'**
  String get loadingWeather;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'We need location permission to show the weather for your location.'**
  String get locationPermissionRequired;

  /// No description provided for @giveLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Give Location Permission'**
  String get giveLocationPermission;

  /// No description provided for @weatherBasedOutfitSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Create your best outfit based on weather'**
  String get weatherBasedOutfitSuggestion;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @selectOutfit.
  ///
  /// In en, this message translates to:
  /// **'Select Outfit'**
  String get selectOutfit;

  /// No description provided for @aiStyleConsultant.
  ///
  /// In en, this message translates to:
  /// **'AI Style Consultant'**
  String get aiStyleConsultant;

  /// No description provided for @aiStyleConsultantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your outfit and get suggestions with Gemini 3 ✨'**
  String get aiStyleConsultantSubtitle;

  /// No description provided for @viewErrorDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'View Error: Data not found.'**
  String get viewErrorDataNotFound;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @dataProcessingError.
  ///
  /// In en, this message translates to:
  /// **'Data processing error: {error}'**
  String dataProcessingError(Object error);

  /// No description provided for @improvableAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas for Improvement'**
  String get improvableAreas;

  /// No description provided for @stylistOpinions.
  ///
  /// In en, this message translates to:
  /// **'Stylist Opinions'**
  String get stylistOpinions;

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homePage;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get scoreLabel;

  /// No description provided for @requestCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create request.'**
  String get requestCreationFailed;

  /// No description provided for @max5ClothesError.
  ///
  /// In en, this message translates to:
  /// **'You can select a maximum of 5 clothes.'**
  String get max5ClothesError;

  /// No description provided for @geminiResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Gemini 3 Outfit Result'**
  String get geminiResultTitle;

  /// No description provided for @combineDetails.
  ///
  /// In en, this message translates to:
  /// **'Combine Details'**
  String get combineDetails;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @clothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get clothes;

  /// No description provided for @regeneratingCombine.
  ///
  /// In en, this message translates to:
  /// **'Regenerating...'**
  String get regeneratingCombine;

  /// No description provided for @regenerateCombine.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Combine'**
  String get regenerateCombine;

  /// No description provided for @geminiGeneratingCombine.
  ///
  /// In en, this message translates to:
  /// **'Gemini 3 is generating the combine...'**
  String get geminiGeneratingCombine;

  /// No description provided for @processEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'This process may take 10-15 seconds'**
  String get processEstimatedTime;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @selectedModel.
  ///
  /// In en, this message translates to:
  /// **'Selected Model'**
  String get selectedModel;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get cameraPermissionRequired;

  /// No description provided for @captureYourCombine.
  ///
  /// In en, this message translates to:
  /// **'Capture Your Combine'**
  String get captureYourCombine;

  /// No description provided for @centerYourCombine.
  ///
  /// In en, this message translates to:
  /// **'Center your combine'**
  String get centerYourCombine;

  /// No description provided for @fitCheckPhoto.
  ///
  /// In en, this message translates to:
  /// **'Fit Check Photo'**
  String get fitCheckPhoto;

  /// No description provided for @dailyFitCheck.
  ///
  /// In en, this message translates to:
  /// **'Daily Fit Check'**
  String get dailyFitCheck;

  /// No description provided for @dailyFitCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What did you wear today? Let Gemini 3 comment.'**
  String get dailyFitCheckSubtitle;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @closetAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Closet Analysis'**
  String get closetAnalysis;

  /// No description provided for @piecesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Pieces'**
  String piecesCount(Object count);

  /// No description provided for @capsuleClosetScore.
  ///
  /// In en, this message translates to:
  /// **'Capsule Closet Score'**
  String get capsuleClosetScore;

  /// No description provided for @favoriteColors.
  ///
  /// In en, this message translates to:
  /// **'Favorite Colors'**
  String get favoriteColors;

  /// No description provided for @capsuleStatusPerfect.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You\'re a true capsule closet expert.'**
  String get capsuleStatusPerfect;

  /// No description provided for @capsuleStatusGreat.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great, very balanced.'**
  String get capsuleStatusGreat;

  /// No description provided for @capsuleStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good start, needs a bit more balance.'**
  String get capsuleStatusGood;

  /// No description provided for @capsuleStatusBeginner.
  ///
  /// In en, this message translates to:
  /// **'You\'re just at the beginning, simplify your closet.'**
  String get capsuleStatusBeginner;

  /// No description provided for @ticket_premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM 🔥'**
  String get ticket_premium;

  /// No description provided for @dailyStreakCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String dailyStreakCount(Object count);

  /// No description provided for @startStreak.
  ///
  /// In en, this message translates to:
  /// **'Start Streak!'**
  String get startStreak;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @closetEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Closet content not found\nClick the button above to add a new item'**
  String get closetEmptyMessage;

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete?'**
  String get deleteConfirmationTitle;

  /// No description provided for @deleteModelConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Model?'**
  String get deleteModelConfirmationTitle;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @scrollToEnlarge.
  ///
  /// In en, this message translates to:
  /// **'Scroll to enlarge image'**
  String get scrollToEnlarge;

  /// No description provided for @pinchToZoom.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom'**
  String get pinchToZoom;

  /// No description provided for @analyzedWithGemini.
  ///
  /// In en, this message translates to:
  /// **'Analyzed with Gemini 3'**
  String get analyzedWithGemini;

  /// No description provided for @similarItems.
  ///
  /// In en, this message translates to:
  /// **'Similar Items'**
  String get similarItems;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(Object count);

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @patternLabel.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get patternLabel;

  /// No description provided for @materialLabel.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get materialLabel;

  /// No description provided for @seasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get seasonLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @summer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get summer;

  /// No description provided for @winter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get winter;

  /// No description provided for @spring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get spring;

  /// No description provided for @autumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get autumn;

  /// No description provided for @allSeasons.
  ///
  /// In en, this message translates to:
  /// **'All Seasons'**
  String get allSeasons;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @bodyType.
  ///
  /// In en, this message translates to:
  /// **'Body Type'**
  String get bodyType;

  /// No description provided for @skinTone.
  ///
  /// In en, this message translates to:
  /// **'Skin Tone'**
  String get skinTone;

  /// No description provided for @pose.
  ///
  /// In en, this message translates to:
  /// **'Pose'**
  String get pose;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @fullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get fullBody;

  /// No description provided for @upperBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBodyPart;

  /// No description provided for @lowerBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBodyPart;

  /// No description provided for @faceOnly.
  ///
  /// In en, this message translates to:
  /// **'Face Only'**
  String get faceOnly;

  /// No description provided for @unnamedModel.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Model'**
  String get unnamedModel;

  /// No description provided for @analyzingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzingEllipsis;

  /// No description provided for @analyzeWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get analyzeWithAI;

  /// No description provided for @selectItemType.
  ///
  /// In en, this message translates to:
  /// **'Select Item Type'**
  String get selectItemType;

  /// No description provided for @debugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get debugMode;

  /// No description provided for @selectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected: {value}'**
  String selectedLabel(Object value);

  /// No description provided for @tapToSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap a body part to select category'**
  String get tapToSelectCategory;

  /// No description provided for @mandatoryCategory.
  ///
  /// In en, this message translates to:
  /// **'Category * (Mandatory)'**
  String get mandatoryCategory;

  /// No description provided for @invalidPhoto.
  ///
  /// In en, this message translates to:
  /// **'Invalid Photo'**
  String get invalidPhoto;

  /// No description provided for @invalidPhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Please only upload photos of clothing, shoes, bags, jewelry or accessories.'**
  String get invalidPhotoDescription;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @continueManually.
  ///
  /// In en, this message translates to:
  /// **'Continue Manually'**
  String get continueManually;

  /// No description provided for @noCombinesFound.
  ///
  /// In en, this message translates to:
  /// **'No combines found'**
  String get noCombinesFound;

  /// No description provided for @clickButtonAboveToCreateCombine.
  ///
  /// In en, this message translates to:
  /// **'Click the button above to create a new combine'**
  String get clickButtonAboveToCreateCombine;

  /// No description provided for @noStyleAnalysisYet.
  ///
  /// In en, this message translates to:
  /// **'No style analysis yet'**
  String get noStyleAnalysisYet;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @noModelsFound.
  ///
  /// In en, this message translates to:
  /// **'No model photos found'**
  String get noModelsFound;

  /// No description provided for @clickButtonAboveToAddModel.
  ///
  /// In en, this message translates to:
  /// **'Click the button above to add a new model'**
  String get clickButtonAboveToAddModel;

  /// No description provided for @createCombine.
  ///
  /// In en, this message translates to:
  /// **'Create Combine'**
  String get createCombine;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// No description provided for @selectCloth.
  ///
  /// In en, this message translates to:
  /// **'Select Cloth'**
  String get selectCloth;

  /// No description provided for @modelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select who will try on the clothes'**
  String get modelSubtitle;

  /// No description provided for @wardrobeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick items to mix & match'**
  String get wardrobeSubtitle;

  /// No description provided for @nSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String nSelected(Object count);

  /// No description provided for @geminiProcessing.
  ///
  /// In en, this message translates to:
  /// **'Gemini 3 Processing... ✨'**
  String get geminiProcessing;

  /// No description provided for @tapToChooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose from library'**
  String get tapToChooseFromLibrary;

  /// No description provided for @useOriginalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use Original Photo'**
  String get useOriginalPhoto;

  /// No description provided for @useAiPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use AI Photo'**
  String get useAiPhoto;

  /// No description provided for @captureYourself.
  ///
  /// In en, this message translates to:
  /// **'Capture Yourself'**
  String get captureYourself;

  /// No description provided for @captureClothes.
  ///
  /// In en, this message translates to:
  /// **'Capture Clothes'**
  String get captureClothes;

  /// No description provided for @alignFaceAndBody.
  ///
  /// In en, this message translates to:
  /// **'Align your face and body'**
  String get alignFaceAndBody;

  /// No description provided for @centerTheClothes.
  ///
  /// In en, this message translates to:
  /// **'Center the clothes'**
  String get centerTheClothes;

  /// No description provided for @modelNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Model Name (Optional)'**
  String get modelNameOptional;

  /// No description provided for @modelNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Summer model, Sport model'**
  String get modelNameHint;

  /// No description provided for @virtualCabin.
  ///
  /// In en, this message translates to:
  /// **'Virtual Cabin'**
  String get virtualCabin;

  /// No description provided for @quickTry.
  ///
  /// In en, this message translates to:
  /// **'Quick Try'**
  String get quickTry;

  /// No description provided for @closetAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Closet Access Required'**
  String get closetAccessRequired;

  /// No description provided for @closetAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to view your closet content.'**
  String get closetAccessDescription;

  /// No description provided for @outfitCalendar.
  ///
  /// In en, this message translates to:
  /// **'Outfit Calendar 📅'**
  String get outfitCalendar;

  /// No description provided for @kombin.
  ///
  /// In en, this message translates to:
  /// **'Combine'**
  String get kombin;

  /// No description provided for @kombins.
  ///
  /// In en, this message translates to:
  /// **'Combines'**
  String get kombins;

  /// No description provided for @streakLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary! 🏆 You\'re a true style icon'**
  String get streakLegendary;

  /// No description provided for @streakAwesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome! 🔥 A week of consistency'**
  String get streakAwesome;

  /// No description provided for @streakSuper.
  ///
  /// In en, this message translates to:
  /// **'Doing great! 🚀 Keep the streak'**
  String get streakSuper;

  /// No description provided for @streakGood.
  ///
  /// In en, this message translates to:
  /// **'Good start! ✨ Keep it up'**
  String get streakGood;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'LAST 30 DAYS'**
  String get last30Days;

  /// No description provided for @allTabs.
  ///
  /// In en, this message translates to:
  /// **'All >'**
  String get allTabs;

  /// No description provided for @noFitCheckLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No FitCheck records yet'**
  String get noFitCheckLogsYet;

  /// No description provided for @noPastRecords.
  ///
  /// In en, this message translates to:
  /// **'No past records found yet.'**
  String get noPastRecords;

  /// No description provided for @noFilterResults.
  ///
  /// In en, this message translates to:
  /// **'No records found matching filters.'**
  String get noFilterResults;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @wardrobeLabel.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobeLabel;

  /// No description provided for @capsuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsuleLabel;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @dateTitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateTitle;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @styleTitle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get styleTitle;

  /// No description provided for @colorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colorsTitle;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @galleryAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Gallery Access Required'**
  String get galleryAccessRequired;

  /// No description provided for @galleryAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'You need to grant gallery access to select your photos. Please go to settings and allow gallery access.'**
  String get galleryAccessDescription;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @maxPhotoSelectionLimit.
  ///
  /// In en, this message translates to:
  /// **'You can select a maximum of {count} photos'**
  String maxPhotoSelectionLimit(Object count);

  /// No description provided for @nOfMaxSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} / {total} selected'**
  String nOfMaxSelected(Object count, Object total);

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// No description provided for @savingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingEllipsis;

  /// No description provided for @analyzingOutfit.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Outfit...'**
  String get analyzingOutfit;

  /// No description provided for @stylistDetailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Your stylist is doing a detailed analysis'**
  String get stylistDetailedAnalysis;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// No description provided for @couldNotBeViewed.
  ///
  /// In en, this message translates to:
  /// **'Could not be viewed.'**
  String get couldNotBeViewed;

  /// No description provided for @shareMessageFitCheck.
  ///
  /// In en, this message translates to:
  /// **'I analyzed my outfit with Comby! 🌟'**
  String get shareMessageFitCheck;

  /// No description provided for @analyzingOutfitWithGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI is examining your style, colors and harmony.'**
  String get analyzingOutfitWithGemini;

  /// No description provided for @styleSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Style Suggestions'**
  String get styleSuggestions;

  /// No description provided for @instructionSelectDay.
  ///
  /// In en, this message translates to:
  /// **'Select a day from the calendar to review past combinations 👆'**
  String get instructionSelectDay;

  /// No description provided for @analyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyzeButton;

  /// No description provided for @selectMedia.
  ///
  /// In en, this message translates to:
  /// **'Select Media'**
  String get selectMedia;

  /// No description provided for @errorOccurredChat.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurredChat;

  /// No description provided for @askSomethingToAi.
  ///
  /// In en, this message translates to:
  /// **'Ask something to AI Assistant!'**
  String get askSomethingToAi;

  /// No description provided for @writeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Write your message...'**
  String get writeYourMessage;

  /// No description provided for @selectedMediaCount.
  ///
  /// In en, this message translates to:
  /// **'Selected Media ({count})'**
  String selectedMediaCount(Object count);

  /// No description provided for @videoLabelUpper.
  ///
  /// In en, this message translates to:
  /// **'VIDEO'**
  String get videoLabelUpper;

  /// No description provided for @closet.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get closet;

  /// No description provided for @settingsPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Settings and Personal Info'**
  String get settingsPersonalInfo;

  /// No description provided for @authMethod.
  ///
  /// In en, this message translates to:
  /// **'Authentication Method'**
  String get authMethod;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In'**
  String get googleSignIn;

  /// No description provided for @appleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In'**
  String get appleSignIn;

  /// No description provided for @emailPasswordLogin.
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get emailPasswordLogin;

  /// No description provided for @searchingForInfo.
  ///
  /// In en, this message translates to:
  /// **'🔍 Searching for information for \"{query}\"...'**
  String searchingForInfo(Object query);

  /// No description provided for @profileAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile Access Required'**
  String get profileAccessRequired;

  /// No description provided for @profileAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to view and edit your profile.'**
  String get profileAccessDescription;

  /// No description provided for @styleDnaTitle.
  ///
  /// In en, this message translates to:
  /// **'Style DNA'**
  String get styleDnaTitle;

  /// No description provided for @updatedNow.
  ///
  /// In en, this message translates to:
  /// **'Updated now'**
  String get updatedNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(Object count);

  /// No description provided for @updatedToday.
  ///
  /// In en, this message translates to:
  /// **'Updated today'**
  String get updatedToday;

  /// No description provided for @updatedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Updated yesterday'**
  String get updatedYesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgo(Object count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(Object count);

  /// No description provided for @styleJournal.
  ///
  /// In en, this message translates to:
  /// **'Style Journal'**
  String get styleJournal;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String dayStreak(Object count);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Lvl {level}'**
  String levelLabel(Object level);

  /// No description provided for @uidLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String uidLabel(Object id);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @accountAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountAndSecurity;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @legalAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Legal & Info'**
  String get legalAndInfo;

  /// No description provided for @appleEula.
  ///
  /// In en, this message translates to:
  /// **'Apple Standard EULA'**
  String get appleEula;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @languageAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get languageAndRegion;

  /// No description provided for @currentLanguageName.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get currentLanguageName;

  /// No description provided for @accountOperations.
  ///
  /// In en, this message translates to:
  /// **'Account Operations'**
  String get accountOperations;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionInfo(Object version);

  /// No description provided for @processingModels.
  ///
  /// In en, this message translates to:
  /// **'Processing Models'**
  String get processingModels;

  /// No description provided for @successCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Successful: {count}'**
  String successCountLabel(Object count);

  /// No description provided for @failCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Failed: {count}'**
  String failCountLabel(Object count);

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get viewResults;

  /// No description provided for @notValidModelReason.
  ///
  /// In en, this message translates to:
  /// **'This photo is not a model that can be dressed'**
  String get notValidModelReason;

  /// No description provided for @processingError.
  ///
  /// In en, this message translates to:
  /// **'Processing error: {error}'**
  String processingError(Object error);

  /// No description provided for @modelsNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'{count} photos could not be recognized as models'**
  String modelsNotRecognized(Object count);

  /// No description provided for @reviewFailedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Review Failed Photos'**
  String get reviewFailedPhotos;

  /// No description provided for @failedModelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed Models ({current}/{total})'**
  String failedModelsTitle(Object current, Object total);

  /// No description provided for @whyFailed.
  ///
  /// In en, this message translates to:
  /// **'Why failed?'**
  String get whyFailed;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @manualAdd.
  ///
  /// In en, this message translates to:
  /// **'Manual Add'**
  String get manualAdd;

  /// No description provided for @processingItems.
  ///
  /// In en, this message translates to:
  /// **'Processing Items'**
  String get processingItems;

  /// No description provided for @failedPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed Photos ({current}/{total})'**
  String failedPhotosTitle(Object current, Object total);

  /// No description provided for @photosNotIdentifiedAsClothing.
  ///
  /// In en, this message translates to:
  /// **'{count} photos could not be identified as fashion items'**
  String photosNotIdentifiedAsClothing(Object count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'hi', 'id', 'pt', 'ru', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'id': return AppLocalizationsId();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
