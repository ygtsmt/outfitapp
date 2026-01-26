// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m9(category) => "✨ AI Analysis Complete! Found: ${category}";

  static String m10(error) => "AI Analysis Failed: ${error}";

  static String m11(count) => "${count} Day Streak";

  static String m12(error) => "Data processing error: ${error}";

  static String m13(count) => "${count} Day Streak";

  static String m14(count) => "${count} days ago";

  static String m0(error) => "Error: ${error}";

  static String m1(error) => "Error: ${error}";

  static String m15(count) => "Failed: ${count}";

  static String m16(current, total) => "Failed Models (${current}/${total})";

  static String m17(current, total) => "Failed Photos (${current}/${total})";

  static String m2(error) => "Failed to pick image: ${error}";

  static String m3(fileName) => "File: ${fileName}";

  static String m18(name) => "Good afternoon ${name} 👋";

  static String m19(name) => "Good evening ${name} 🌙";

  static String m20(name) => "Good morning ${name} ☀️";

  static String m4(required, available) =>
      "Insufficient credits. Required: ${required}, Available: ${available}";

  static String m21(count) => "${count} items";

  static String m22(level) => "Lvl ${level}";

  static String m23(count) => "You can select a maximum of ${count} photos";

  static String m24(count) => "${count} minutes ago";

  static String m25(count, total) =>
      "${count} of ${total} models added successfully!";

  static String m26(count) =>
      "${count} photos could not be recognized as models";

  static String m27(count) => "${count} months ago";

  static String m28(count, total) => "${count} / ${total} selected";

  static String m29(count) => "${count} selected";

  static String m30(count, total) =>
      "${count} of ${total} photos added successfully!";

  static String m31(count) =>
      "${count} photos could not be identified as fashion items";

  static String m32(count) => "${count} Pieces";

  static String m33(error) => "Processing error: ${error}";

  static String m5(count) =>
      "You have reached the maximum refund limit (${count}/10).";

  static String m34(query) =>
      "🔍 Searching for information for \"${query}\"...";

  static String m35(category) => "Select Category: ${category}";

  static String m36(value) => "Selected: ${value}";

  static String m37(count) => "Selected Media (${count})";

  static String m6(fileSize) => "Size: ${fileSize}";

  static String m38(count) => "Successful: ${count}";

  static String m7(seed) => "Template regeneration started with seed: ${seed}";

  static String m39(id) => "ID: ${id}";

  static String m8(credits) =>
      "Convert your guest account to a full account:\n• Keep all your credits (${credits})\n• Keep all your videos and content\n• Sync data across devices\n• Secure your account with password";

  static String m40(version) => "Version ${version}";

  static String m41(count) => "${count} weeks ago";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accessories": MessageLookupByLibrary.simpleMessage("Accessories"),
        "accountAndSecurity":
            MessageLookupByLibrary.simpleMessage("Account & Security"),
        "accountDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Your account has been successfully deleted!"),
        "accountDeletionError":
            MessageLookupByLibrary.simpleMessage("Account deletion error"),
        "accountInformation":
            MessageLookupByLibrary.simpleMessage("Account Information"),
        "accountOperations":
            MessageLookupByLibrary.simpleMessage("Account Operations"),
        "account_exists_with_different_credential":
            MessageLookupByLibrary.simpleMessage(
                "This email address is already associated with a different login method."),
        "addClosetItem":
            MessageLookupByLibrary.simpleMessage("Add Closet Item"),
        "addImageOptional":
            MessageLookupByLibrary.simpleMessage("Add Image (Optional)"),
        "addModel": MessageLookupByLibrary.simpleMessage("Add Model"),
        "addNew": MessageLookupByLibrary.simpleMessage("Add New"),
        "aiAnalysis": MessageLookupByLibrary.simpleMessage("AI Analysis"),
        "aiAnalysisComplete": m9,
        "aiAnalysisFailed": m10,
        "aiCombine": MessageLookupByLibrary.simpleMessage("AI Combine"),
        "aiStyleConsultant":
            MessageLookupByLibrary.simpleMessage("AI Style Consultant"),
        "aiStyleConsultantSubtitle": MessageLookupByLibrary.simpleMessage(
            "Rate your outfit and get suggestions with Gemini 3 ✨"),
        "aiVideoEffects":
            MessageLookupByLibrary.simpleMessage("AI Video Effects"),
        "ai_video_generation":
            MessageLookupByLibrary.simpleMessage("AI Video Generation"),
        "alignFaceAndBody":
            MessageLookupByLibrary.simpleMessage("Align your face and body"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "allEffects": MessageLookupByLibrary.simpleMessage("All Effects"),
        "allImages": MessageLookupByLibrary.simpleMessage("All Images"),
        "allModelsAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "All models added successfully!"),
        "allPhotosAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "All photos added successfully!"),
        "allSeasons": MessageLookupByLibrary.simpleMessage("All Seasons"),
        "allTabs": MessageLookupByLibrary.simpleMessage("All >"),
        "almostReady":
            MessageLookupByLibrary.simpleMessage("Ready to create..."),
        "analysisLoadFailed": MessageLookupByLibrary.simpleMessage(
            "Analysis could not be loaded. Please check your internet connection."),
        "analyzeButton": MessageLookupByLibrary.simpleMessage("Analyze"),
        "analyzeWithAI":
            MessageLookupByLibrary.simpleMessage("Analyze with AI"),
        "analyzedWithGemini":
            MessageLookupByLibrary.simpleMessage("Analyzed with Gemini 3"),
        "analyzing": MessageLookupByLibrary.simpleMessage("Analyzing..."),
        "analyzingEllipsis":
            MessageLookupByLibrary.simpleMessage("Analyzing..."),
        "analyzingModel":
            MessageLookupByLibrary.simpleMessage("Analyzing model..."),
        "analyzingOutfit":
            MessageLookupByLibrary.simpleMessage("Analyzing Outfit..."),
        "analyzingOutfitWithGemini": MessageLookupByLibrary.simpleMessage(
            "Gemini AI is examining your style, colors and harmony."),
        "analyzingWithGemini3":
            MessageLookupByLibrary.simpleMessage("Analyzing with Gemini 3..."),
        "and": MessageLookupByLibrary.simpleMessage("and"),
        "anime_style": MessageLookupByLibrary.simpleMessage("Anime Style"),
        "anime_style_description":
            MessageLookupByLibrary.simpleMessage("Japanese anime art style"),
        "appName": MessageLookupByLibrary.simpleMessage("Comby"),
        "appPreferences":
            MessageLookupByLibrary.simpleMessage("App Preferences"),
        "app_settings": MessageLookupByLibrary.simpleMessage("App Settings"),
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "apple": MessageLookupByLibrary.simpleMessage("Apple"),
        "appleEula":
            MessageLookupByLibrary.simpleMessage("Apple Standard EULA"),
        "appleSignIn": MessageLookupByLibrary.simpleMessage("Apple Sign-In"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "artistCredit": MessageLookupByLibrary.simpleMessage(
            "HISTED, TXVSTERPLAYA - MASHA ULTRAFUNK"),
        "askSomethingToAi": MessageLookupByLibrary.simpleMessage(
            "Ask something to AI Assistant!"),
        "aspectRatio": MessageLookupByLibrary.simpleMessage("Aspect Ratio"),
        "aspect_ratio": MessageLookupByLibrary.simpleMessage("Aspect Ratio"),
        "auction": MessageLookupByLibrary.simpleMessage("Auction"),
        "authMethod":
            MessageLookupByLibrary.simpleMessage("Authentication Method"),
        "autoRenewable": MessageLookupByLibrary.simpleMessage(
            "Auto-renewable, cancel anytime"),
        "auto_style": MessageLookupByLibrary.simpleMessage("Auto Style"),
        "auto_style_description": MessageLookupByLibrary.simpleMessage(
            "Automatic style selection for best results"),
        "autumn": MessageLookupByLibrary.simpleMessage("Autumn"),
        "back_to_login": MessageLookupByLibrary.simpleMessage("Back"),
        "bannedContentDetected": MessageLookupByLibrary.simpleMessage(
            "Inappropriate Content Detected"),
        "bannedContentMessage": MessageLookupByLibrary.simpleMessage(
            "Inappropriate content was detected in your prompt. Please use a more appropriate expression."),
        "beginning_of_video":
            MessageLookupByLibrary.simpleMessage("(Beginning of video)"),
        "benefitCloudSync":
            MessageLookupByLibrary.simpleMessage("Cloud sync and backup"),
        "benefitPremiumFeatures":
            MessageLookupByLibrary.simpleMessage("Access to premium features"),
        "benefitWatchAds": MessageLookupByLibrary.simpleMessage(
            "Watch ads and earn free credits"),
        "bestPrice": MessageLookupByLibrary.simpleMessage("Best Price"),
        "bestValue": MessageLookupByLibrary.simpleMessage("BEST VALUE"),
        "bodyMapImageNotFound":
            MessageLookupByLibrary.simpleMessage("Body Map Image Not Found"),
        "bodyType": MessageLookupByLibrary.simpleMessage("Body Type"),
        "brandOptional":
            MessageLookupByLibrary.simpleMessage("Brand (Optional)"),
        "buySubscriptionOrCredits":
            MessageLookupByLibrary.simpleMessage("Buy Subscription/Credits"),
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
            "Camera permission is required"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancelButton": MessageLookupByLibrary.simpleMessage("İptal"),
        "capsuleClosetScore":
            MessageLookupByLibrary.simpleMessage("Capsule Closet Score"),
        "capsuleStatusBeginner": MessageLookupByLibrary.simpleMessage(
            "You\'re just at the beginning, simplify your closet."),
        "capsuleStatusGood": MessageLookupByLibrary.simpleMessage(
            "Good start, needs a bit more balance."),
        "capsuleStatusGreat": MessageLookupByLibrary.simpleMessage(
            "You\'re doing great, very balanced."),
        "capsuleStatusPerfect": MessageLookupByLibrary.simpleMessage(
            "Excellent! You\'re a true capsule closet expert."),
        "captureClothes":
            MessageLookupByLibrary.simpleMessage("Capture Clothes"),
        "captureYourCombine":
            MessageLookupByLibrary.simpleMessage("Capture Your Combine"),
        "captureYourself":
            MessageLookupByLibrary.simpleMessage("Capture Yourself"),
        "categoriesEffects":
            MessageLookupByLibrary.simpleMessage("Categories Effects"),
        "categoryLabel": MessageLookupByLibrary.simpleMessage("Category"),
        "centerTheClothes":
            MessageLookupByLibrary.simpleMessage("Center the clothes"),
        "centerYourCombine":
            MessageLookupByLibrary.simpleMessage("Center your combine"),
        "change": MessageLookupByLibrary.simpleMessage("Change"),
        "changeLanguage":
            MessageLookupByLibrary.simpleMessage("Change Language"),
        "change_password":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "check": MessageLookupByLibrary.simpleMessage("Check"),
        "checkVerification":
            MessageLookupByLibrary.simpleMessage("Check Verification"),
        "checks": MessageLookupByLibrary.simpleMessage("Checks"),
        "claim_earned_credits":
            MessageLookupByLibrary.simpleMessage("Claim Earned Credits"),
        "clay_style": MessageLookupByLibrary.simpleMessage("Clay Style"),
        "clay_style_description":
            MessageLookupByLibrary.simpleMessage("Claymation art style"),
        "clearAll": MessageLookupByLibrary.simpleMessage("Clear All"),
        "clearSearch": MessageLookupByLibrary.simpleMessage("Clear Search"),
        "clearSelection":
            MessageLookupByLibrary.simpleMessage("Clear Selection"),
        "clickButtonAboveToAddModel": MessageLookupByLibrary.simpleMessage(
            "Click the button above to add a new model"),
        "clickButtonAboveToCreateCombine": MessageLookupByLibrary.simpleMessage(
            "Click the button above to create a new combine"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "closet": MessageLookupByLibrary.simpleMessage("Closet"),
        "closetAccessDescription": MessageLookupByLibrary.simpleMessage(
            "You need to log in to view your closet content."),
        "closetAccessRequired":
            MessageLookupByLibrary.simpleMessage("Closet Access Required"),
        "closetAnalysis":
            MessageLookupByLibrary.simpleMessage("Closet Analysis"),
        "closetEmptyMessage": MessageLookupByLibrary.simpleMessage(
            "Closet content not found\nClick the button above to add a new item"),
        "closet_welcome_messages": MessageLookupByLibrary.simpleMessage(
            "Wow! Your pieces are amazing ✨|Your closet looks great 👗|What will you wear today? 🤔|Your style speaks 🗣️|Time to make an outfit! 🎨|Show your style! 💃|You picked great pieces 👌|You look very stylish today 😎|Your closet is full of stars ⭐|Your outfits are inspiring 💡|Unique pieces! 💎|You are the style icon 👑"),
        "clothes": MessageLookupByLibrary.simpleMessage("Clothes"),
        "colorLabel": MessageLookupByLibrary.simpleMessage("Color"),
        "colorMatch": MessageLookupByLibrary.simpleMessage("Color Match"),
        "colorOptional":
            MessageLookupByLibrary.simpleMessage("Color (Optional)"),
        "colorsTitle": MessageLookupByLibrary.simpleMessage("Colors"),
        "combineCritiqueSaved":
            MessageLookupByLibrary.simpleMessage("Combine critique saved!"),
        "combineDetail": MessageLookupByLibrary.simpleMessage("Combine Detail"),
        "combineDetails":
            MessageLookupByLibrary.simpleMessage("Combine Details"),
        "combineResult": MessageLookupByLibrary.simpleMessage("Combine Result"),
        "combines": MessageLookupByLibrary.simpleMessage("Combines"),
        "combyAiPlusPlan":
            MessageLookupByLibrary.simpleMessage("Comby AI Plus Plan"),
        "combyAiProPlan":
            MessageLookupByLibrary.simpleMessage("Comby AI Pro Plan"),
        "combyAiUltraPlan":
            MessageLookupByLibrary.simpleMessage("Comby AI Ultra Plan"),
        "comic_style": MessageLookupByLibrary.simpleMessage("Comic Style"),
        "comic_style_description":
            MessageLookupByLibrary.simpleMessage("Comic book art style"),
        "common_error":
            MessageLookupByLibrary.simpleMessage("Oops! Something went wrong!"),
        "completedAtLabel":
            MessageLookupByLibrary.simpleMessage("Completed At: "),
        "configuringPayments":
            MessageLookupByLibrary.simpleMessage("Almost there..."),
        "confirm_password":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "confirm_password_error":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "contactSupport":
            MessageLookupByLibrary.simpleMessage("Contact Support"),
        "continueAsGuest":
            MessageLookupByLibrary.simpleMessage("Continue as Guest"),
        "continueButton": MessageLookupByLibrary.simpleMessage("Continue"),
        "continueManually":
            MessageLookupByLibrary.simpleMessage("Continue Manually"),
        "continueWithOtherTemplates": MessageLookupByLibrary.simpleMessage(
            "Continue with Other Templates"),
        "copied": MessageLookupByLibrary.simpleMessage("Copied"),
        "couldNotBeViewed":
            MessageLookupByLibrary.simpleMessage("Could not be viewed."),
        "counterCompleted":
            MessageLookupByLibrary.simpleMessage("Counter completed"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
        "createCombine": MessageLookupByLibrary.simpleMessage("Create Combine"),
        "createImage": MessageLookupByLibrary.simpleMessage("Create Image"),
        "create_account":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "create_account_form": MessageLookupByLibrary.simpleMessage(
            "Please fill in the form below to create an account"),
        "create_videos_with_prompt_and_image":
            MessageLookupByLibrary.simpleMessage(
                "Create videos with your prompt and image"),
        "createdAt": MessageLookupByLibrary.simpleMessage("Created at"),
        "credential_already_in_use": MessageLookupByLibrary.simpleMessage(
            "This credential is already in use by another account."),
        "credit": MessageLookupByLibrary.simpleMessage("credit"),
        "creditEarned": MessageLookupByLibrary.simpleMessage("Credits earned"),
        "creditPackages": MessageLookupByLibrary.simpleMessage("Credits"),
        "creditRequirementsNotLoaded": MessageLookupByLibrary.simpleMessage(
            "Credit requirements not loaded. Please try again."),
        "credits": MessageLookupByLibrary.simpleMessage("Credits"),
        "creditsAddedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Credits added successfully!"),
        "creditsPackPerWeek":
            MessageLookupByLibrary.simpleMessage("credits pack/week"),
        "credits_added_successfully": MessageLookupByLibrary.simpleMessage(
            "Earned credits have been added to your account!"),
        "critiques": MessageLookupByLibrary.simpleMessage("Critiques"),
        "crop_image": MessageLookupByLibrary.simpleMessage("Crop"),
        "crop_image_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "crop_image_done": MessageLookupByLibrary.simpleMessage("Done"),
        "crop_image_flip": MessageLookupByLibrary.simpleMessage("Flip"),
        "crop_image_flip_horizontal":
            MessageLookupByLibrary.simpleMessage("Flip Horizontal"),
        "crop_image_flip_vertical":
            MessageLookupByLibrary.simpleMessage("Flip Vertical"),
        "crop_image_reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "crop_image_rotate": MessageLookupByLibrary.simpleMessage("Rotate"),
        "crop_image_rotate_left":
            MessageLookupByLibrary.simpleMessage("Rotate Left"),
        "crop_image_rotate_right":
            MessageLookupByLibrary.simpleMessage("Rotate Right"),
        "cropped": MessageLookupByLibrary.simpleMessage("Cropped"),
        "currentLanguageName":
            MessageLookupByLibrary.simpleMessage("English (US)"),
        "currentStreak": MessageLookupByLibrary.simpleMessage("Current Streak"),
        "current_password":
            MessageLookupByLibrary.simpleMessage("Current Password"),
        "customCreate": MessageLookupByLibrary.simpleMessage("Custom Create"),
        "cyberpunk_style":
            MessageLookupByLibrary.simpleMessage("Cyberpunk Style"),
        "cyberpunk_style_description": MessageLookupByLibrary.simpleMessage(
            "Futuristic cyberpunk aesthetic"),
        "dailyFitCheck":
            MessageLookupByLibrary.simpleMessage("Daily Fit Check"),
        "dailyFitCheckSubtitle": MessageLookupByLibrary.simpleMessage(
            "What did you wear today? Let Gemini 3 comment."),
        "dailyStreakCount": m11,
        "daily_ads_earned": MessageLookupByLibrary.simpleMessage(
            "Daily ad credits earned. Come back tomorrow to watch more ads"),
        "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "dataProcessingError": m12,
        "dataWillBePreserved": MessageLookupByLibrary.simpleMessage(
            "✅ Your data will be preserved!"),
        "dateLabel": MessageLookupByLibrary.simpleMessage("Date"),
        "dateTitle": MessageLookupByLibrary.simpleMessage("Date"),
        "day": MessageLookupByLibrary.simpleMessage("Day"),
        "dayStreak": m13,
        "days": MessageLookupByLibrary.simpleMessage("Days"),
        "daysAgo": m14,
        "debugMode": MessageLookupByLibrary.simpleMessage("Debug Mode"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
        "deleteAccountWarning":
            MessageLookupByLibrary.simpleMessage("Delete Account Warning"),
        "deleteAccountWarningDescription": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete your account? This action cannot be undone.\n\n• All your usage rights will be reset\n• All generated content will be permanently deleted\n• All credits and subscriptions will be lost\n• Your profile and data will be removed"),
        "deleteConfirmationTitle":
            MessageLookupByLibrary.simpleMessage("Do you want to delete?"),
        "deleteImage": MessageLookupByLibrary.simpleMessage("Delete Image"),
        "deleteImageConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this image?"),
        "deleteModelConfirmationTitle":
            MessageLookupByLibrary.simpleMessage("Delete Model?"),
        "deleteMyAccount":
            MessageLookupByLibrary.simpleMessage("Delete My Account"),
        "deleteVideo": MessageLookupByLibrary.simpleMessage("Delete Video"),
        "deleteVideoConfirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this video?"),
        "deletedUser": MessageLookupByLibrary.simpleMessage("Deleted User"),
        "deneme": MessageLookupByLibrary.simpleMessage("Deneme"),
        "describeWhatYouWantToSee": MessageLookupByLibrary.simpleMessage(
            "Describe what you want to see..."),
        "describe_video_hint": MessageLookupByLibrary.simpleMessage(
            "Describe the video you want to create..."),
        "describe_your_video":
            MessageLookupByLibrary.simpleMessage("Describe Your Video"),
        "detectedWord": MessageLookupByLibrary.simpleMessage("Detected word: "),
        "deviceAlreadyClaimedReviewCredit":
            MessageLookupByLibrary.simpleMessage(
                "This device has already completed the review!"),
        "deviceReviewCreditMessage": MessageLookupByLibrary.simpleMessage(
            "Review has already been completed on this device. Each device can only review once."),
        "done": MessageLookupByLibrary.simpleMessage("Done"),
        "download": MessageLookupByLibrary.simpleMessage("Download"),
        "durationLabel": MessageLookupByLibrary.simpleMessage("Duration: "),
        "earnFreeCredits":
            MessageLookupByLibrary.simpleMessage("Earn Free Credits"),
        "earn_credits": MessageLookupByLibrary.simpleMessage("Earn Credits"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editUsername": MessageLookupByLibrary.simpleMessage("Edit Username"),
        "effect": MessageLookupByLibrary.simpleMessage("Effect"),
        "effectSearch":
            MessageLookupByLibrary.simpleMessage("Search effect..."),
        "effects": MessageLookupByLibrary.simpleMessage("Effects"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "emailCopied":
            MessageLookupByLibrary.simpleMessage("Email copied to clipboard!"),
        "emailNotVerifiedYet": MessageLookupByLibrary.simpleMessage(
            "Email not verified yet. Please check your inbox and click the verification link."),
        "emailPasswordLogin":
            MessageLookupByLibrary.simpleMessage("Email & Password"),
        "emailVerificationMessage": MessageLookupByLibrary.simpleMessage(
            "You need to verify your email address to continue claiming credits. This helps prevent abuse and ensures account security."),
        "emailVerificationRequired":
            MessageLookupByLibrary.simpleMessage("Email Verification Required"),
        "emailVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Email verified successfully! You can now claim your credits."),
        "email_already_in_use": MessageLookupByLibrary.simpleMessage(
            "This email address is already in use by another account."),
        "email_error": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid email address."),
        "empty_error":
            MessageLookupByLibrary.simpleMessage("Please fill out this field."),
        "end_of_video": MessageLookupByLibrary.simpleMessage("(End of video)"),
        "enterNewUsername":
            MessageLookupByLibrary.simpleMessage("Enter new username"),
        "enterReportReason":
            MessageLookupByLibrary.simpleMessage("Enter your report reason..."),
        "enterYourEmail":
            MessageLookupByLibrary.simpleMessage("Enter your e-mail address"),
        "errorCheckingVerification": MessageLookupByLibrary.simpleMessage(
            "Error checking verification status. Please try again."),
        "errorLabel": MessageLookupByLibrary.simpleMessage("Error: "),
        "errorLoadingCredits":
            MessageLookupByLibrary.simpleMessage("Error loading credits"),
        "errorLoadingPdf":
            MessageLookupByLibrary.simpleMessage("Error loading PDF"),
        "errorOccurred": m0,
        "errorOccurredChat":
            MessageLookupByLibrary.simpleMessage("Error occurred"),
        "errorProcessingRefund": MessageLookupByLibrary.simpleMessage(
            "Error processing refund. Please try again."),
        "errorSendingVerificationEmail": MessageLookupByLibrary.simpleMessage(
            "Error sending verification email. Please try again."),
        "errorWithSnapshot": m1,
        "error_adding_credit": MessageLookupByLibrary.simpleMessage(
            "An error occurred, credit could not be added."),
        "excellent": MessageLookupByLibrary.simpleMessage("Excellent"),
        "extraCreditPackages":
            MessageLookupByLibrary.simpleMessage("Extra Credit Packages"),
        "extraCreditsDescription": MessageLookupByLibrary.simpleMessage(
            "Extra credits are available only for premium subscribers. Get a subscription to unlock unlimited possibilities!"),
        "fabricOptional":
            MessageLookupByLibrary.simpleMessage("Fabric (Optional)"),
        "faceOnly": MessageLookupByLibrary.simpleMessage("Face Only"),
        "failCountLabel": m15,
        "failed": MessageLookupByLibrary.simpleMessage("Failed"),
        "failedModelsTitle": m16,
        "failedPhotosTitle": m17,
        "failedToPickImage": m2,
        "failedToRegenerateTemplate": MessageLookupByLibrary.simpleMessage(
            "Failed to regenerate template"),
        "failedToRegenerateVideo":
            MessageLookupByLibrary.simpleMessage("Failed to regenerate video"),
        "failedToSubmitFeedback":
            MessageLookupByLibrary.simpleMessage("Failed to submit feedback"),
        "fast_mode": MessageLookupByLibrary.simpleMessage("Fast Mode"),
        "fast_mode_description": MessageLookupByLibrary.simpleMessage(
            "Faster generation with optimized quality"),
        "fast_mode_incompatible": MessageLookupByLibrary.simpleMessage(
            "Fast mode is not compatible with 1080p resolution or 8s video length"),
        "fasterGenerationSpeed":
            MessageLookupByLibrary.simpleMessage("Faster generation speed"),
        "favoriteColors":
            MessageLookupByLibrary.simpleMessage("Favorite Colors"),
        "favoriteStyle": MessageLookupByLibrary.simpleMessage("Favorite Style"),
        "feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "feedbackDescription": MessageLookupByLibrary.simpleMessage(
            "We\'d love to hear your thoughts! Share your feedback, suggestions, or report any issues you\'ve encountered."),
        "feedbackHint": MessageLookupByLibrary.simpleMessage(
            "Tell us what you think about the app, what features you\'d like to see, or any problems you\'ve experienced..."),
        "feedbackMinLength": MessageLookupByLibrary.simpleMessage(
            "Feedback must be at least 10 characters long"),
        "feedbackRequired":
            MessageLookupByLibrary.simpleMessage("Please enter your feedback"),
        "feedbackSubmitted": MessageLookupByLibrary.simpleMessage(
            "Thank you! Your feedback has been submitted successfully."),
        "feet": MessageLookupByLibrary.simpleMessage("Feet"),
        "felt": MessageLookupByLibrary.simpleMessage("Felt"),
        "fileLabel": MessageLookupByLibrary.simpleMessage("File"),
        "fileSize": MessageLookupByLibrary.simpleMessage("Size"),
        "fileSizeTooLarge": MessageLookupByLibrary.simpleMessage(
            "File size too large (max 10MB)"),
        "fileText": m3,
        "filterByCategory":
            MessageLookupByLibrary.simpleMessage("Filter by Category"),
        "filterByCategoryTooltip":
            MessageLookupByLibrary.simpleMessage("Filter by Category"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("Filter"),
        "finish": MessageLookupByLibrary.simpleMessage("Finish"),
        "firstPerson": MessageLookupByLibrary.simpleMessage("First Person"),
        "fitCheckPhoto":
            MessageLookupByLibrary.simpleMessage("Fit Check Photo"),
        "forceUpdateInfo": MessageLookupByLibrary.simpleMessage(
            "New features and improvements await you!"),
        "forceUpdateMessage": MessageLookupByLibrary.simpleMessage(
            "You need to update to the latest version to continue using the app."),
        "forceUpdateTitle":
            MessageLookupByLibrary.simpleMessage("Update Required"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot your password?"),
        "freeCredit": MessageLookupByLibrary.simpleMessage("Free Credit"),
        "freeCreditDescription": MessageLookupByLibrary.simpleMessage(
            "Follow these simple steps to earn free credits"),
        "freeCreditInfo": MessageLookupByLibrary.simpleMessage("Info"),
        "freeCreditInfoDescription": MessageLookupByLibrary.simpleMessage(
            "Earned credits will be added automatically."),
        "freeCreditWays":
            MessageLookupByLibrary.simpleMessage("Ways to Earn Free Credits"),
        "freePlan": MessageLookupByLibrary.simpleMessage("Free Plan"),
        "fullBody": MessageLookupByLibrary.simpleMessage("Full Body"),
        "full_name": MessageLookupByLibrary.simpleMessage("Full Name"),
        "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
        "galleryAccessDescription": MessageLookupByLibrary.simpleMessage(
            "You need to grant gallery access to select your photos. Please go to settings and allow gallery access."),
        "galleryAccessRequired":
            MessageLookupByLibrary.simpleMessage("Gallery Access Required"),
        "gemini3": MessageLookupByLibrary.simpleMessage("Gemini 3"),
        "geminiGeneratingCombine": MessageLookupByLibrary.simpleMessage(
            "Gemini 3 is generating the combine..."),
        "geminiProcessing":
            MessageLookupByLibrary.simpleMessage("Gemini 3 Processing... ✨"),
        "geminiResultTitle":
            MessageLookupByLibrary.simpleMessage("Gemini 3 Outfit Result"),
        "generate": MessageLookupByLibrary.simpleMessage("Generate"),
        "generateImagesInstantly":
            MessageLookupByLibrary.simpleMessage("Generate images instantly"),
        "generateRealtimeImages":
            MessageLookupByLibrary.simpleMessage("Generate realtime images"),
        "generateYourFirstImage":
            MessageLookupByLibrary.simpleMessage("Generate your first image"),
        "generateYourFirstVideo":
            MessageLookupByLibrary.simpleMessage("Generate your first video"),
        "generate_with_pollo":
            MessageLookupByLibrary.simpleMessage("Generate with Pollo 1.6"),
        "getLabel": MessageLookupByLibrary.simpleMessage("Get: "),
        "getPremium": MessageLookupByLibrary.simpleMessage("GET A PREMIUM 🔱"),
        "getSubscriptionFirst":
            MessageLookupByLibrary.simpleMessage("Get Subscription First"),
        "giveLocationPermission":
            MessageLookupByLibrary.simpleMessage("Give Location Permission"),
        "goBack": MessageLookupByLibrary.simpleMessage("Go Back"),
        "goToSettings": MessageLookupByLibrary.simpleMessage("Go to Settings"),
        "goToSubscriptions":
            MessageLookupByLibrary.simpleMessage("Purchase Subscription"),
        "good": MessageLookupByLibrary.simpleMessage("Good"),
        "goodAfternoon": m18,
        "goodEvening": m19,
        "goodMorning": m20,
        "google": MessageLookupByLibrary.simpleMessage("Google"),
        "googleSignIn": MessageLookupByLibrary.simpleMessage("Google Sign-In"),
        "group_photo": MessageLookupByLibrary.simpleMessage("Single Photo"),
        "guest": MessageLookupByLibrary.simpleMessage("Guest"),
        "guestAccountBenefits":
            MessageLookupByLibrary.simpleMessage("Account Benefits:"),
        "guestAccountTitle":
            MessageLookupByLibrary.simpleMessage("Guest Account"),
        "guestAccountWatchAdsMessage": MessageLookupByLibrary.simpleMessage(
            "You need to create an account to watch ads and earn credits."),
        "guestBenefit1": MessageLookupByLibrary.simpleMessage(
            "• Access purchased content from any of your supported devices"),
        "guestBenefit2": MessageLookupByLibrary.simpleMessage(
            "• Sync your data across devices"),
        "guestBenefit3": MessageLookupByLibrary.simpleMessage(
            "• Secure your purchases and content"),
        "guestPurchase": MessageLookupByLibrary.simpleMessage("Guest Purchase"),
        "guestPurchaseDescription": MessageLookupByLibrary.simpleMessage(
            "You can purchase as a guest user. However, creating an account will enable you to:"),
        "guestPurchaseFooter": MessageLookupByLibrary.simpleMessage(
            "You can create an account at any time to extend access to additional devices."),
        "guestUser": MessageLookupByLibrary.simpleMessage("Guest User"),
        "guest_logout_warning": MessageLookupByLibrary.simpleMessage(
            "You are using a guest account. If you logout, all your data will be lost permanently!"),
        "handsWrists": MessageLookupByLibrary.simpleMessage("Hands / Wrists"),
        "headFace": MessageLookupByLibrary.simpleMessage("Head / Face"),
        "heifFormatWarning":
            MessageLookupByLibrary.simpleMessage("HEIF Format Uyarısı"),
        "high_quality": MessageLookupByLibrary.simpleMessage("High"),
        "history": MessageLookupByLibrary.simpleMessage("History"),
        "homeChat": MessageLookupByLibrary.simpleMessage("Chat"),
        "homeCloset": MessageLookupByLibrary.simpleMessage("Closet"),
        "homeDashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
        "homePage": MessageLookupByLibrary.simpleMessage("Home Page"),
        "homeTryOn": MessageLookupByLibrary.simpleMessage("Try-On"),
        "howWasYourExperience": MessageLookupByLibrary.simpleMessage(
            "How was your experience with Comby AI?"),
        "humidity": MessageLookupByLibrary.simpleMessage("Humidity"),
        "iHaveReadAndAgreedTo": MessageLookupByLibrary.simpleMessage(
            "I have read and agreed to the"),
        "idLabel": MessageLookupByLibrary.simpleMessage("ID: "),
        "image": MessageLookupByLibrary.simpleMessage("Image"),
        "imageDeletedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Image deleted successfully"),
        "imageDetails": MessageLookupByLibrary.simpleMessage("Image Details"),
        "imageGenerationFailed": MessageLookupByLibrary.simpleMessage(
            "Image could not be generated."),
        "imageLoadFailed":
            MessageLookupByLibrary.simpleMessage("Image could not be loaded."),
        "imageTab": MessageLookupByLibrary.simpleMessage("Image"),
        "imageTemplates":
            MessageLookupByLibrary.simpleMessage("Image Templates"),
        "image_aspect_ratio_invalid": MessageLookupByLibrary.simpleMessage(
            "Image aspect ratio must be between 1:4 and 4:1 (0.25 to 4.0)"),
        "image_data_error": MessageLookupByLibrary.simpleMessage(
            "Image data could not be retrieved"),
        "image_size_too_large": MessageLookupByLibrary.simpleMessage(
            "Image size is too large. Maximum size is 4000x4000 pixels."),
        "image_to_video":
            MessageLookupByLibrary.simpleMessage("Image to Video"),
        "images": MessageLookupByLibrary.simpleMessage("Images"),
        "improvableAreas":
            MessageLookupByLibrary.simpleMessage("Areas for Improvement"),
        "initializing":
            MessageLookupByLibrary.simpleMessage("Welcome to Comby..."),
        "inputImage": MessageLookupByLibrary.simpleMessage("Input Image"),
        "instructionSelectDay": MessageLookupByLibrary.simpleMessage(
            "Select a day from the calendar to review past combinations 👆"),
        "insufficientCredits": m4,
        "insufficient_credit":
            MessageLookupByLibrary.simpleMessage("Insufficient credit"),
        "invalidPhoto": MessageLookupByLibrary.simpleMessage("Invalid Photo"),
        "invalidPhotoDescription": MessageLookupByLibrary.simpleMessage(
            "Please only upload photos of clothing, shoes, bags, jewelry or accessories."),
        "invalid_credential": MessageLookupByLibrary.simpleMessage(
            "Invalid credential. Please try again."),
        "invalid_email":
            MessageLookupByLibrary.simpleMessage("Invalid email address."),
        "invalid_verification_code": MessageLookupByLibrary.simpleMessage(
            "The verification code is invalid. Please enter the correct code and try again."),
        "invalid_verification_id": MessageLookupByLibrary.simpleMessage(
            "The verification ID is invalid. Try restarting the process."),
        "itemDetailsOptional":
            MessageLookupByLibrary.simpleMessage("Item Details (Optional)"),
        "itemsCount": m21,
        "kombin": MessageLookupByLibrary.simpleMessage("Combine"),
        "kombins": MessageLookupByLibrary.simpleMessage("Combines"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "languageAndRegion":
            MessageLookupByLibrary.simpleMessage("Language & Region"),
        "last30Days": MessageLookupByLibrary.simpleMessage("LAST 30 DAYS"),
        "last7Days": MessageLookupByLibrary.simpleMessage("Last 7 Days"),
        "legalAndInfo": MessageLookupByLibrary.simpleMessage("Legal & Info"),
        "legal_notice": MessageLookupByLibrary.simpleMessage(
            "To protect your legal rights, please read and agree to our"),
        "length": MessageLookupByLibrary.simpleMessage("Length"),
        "length_resolution_incompatible": MessageLookupByLibrary.simpleMessage(
            "8s video and fast mode not supports 1080p resolution"),
        "levelLabel": m22,
        "library": MessageLookupByLibrary.simpleMessage("Library"),
        "libraryRefreshed":
            MessageLookupByLibrary.simpleMessage("Library refreshed"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "loadingAds":
            MessageLookupByLibrary.simpleMessage("Unleashing AI power..."),
        "loadingPdf": MessageLookupByLibrary.simpleMessage("Loading PDF..."),
        "loadingThemes":
            MessageLookupByLibrary.simpleMessage("Preparing magic..."),
        "loadingWeather":
            MessageLookupByLibrary.simpleMessage("Loading weather..."),
        "loading_please_wait":
            MessageLookupByLibrary.simpleMessage("Loading, please wait..."),
        "locationNotReceived":
            MessageLookupByLibrary.simpleMessage("Location not received"),
        "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
            "We need location permission to show the weather for your location."),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
        "loginDescription": MessageLookupByLibrary.simpleMessage(
            "Please enter your credentials to login."),
        "loginRequired":
            MessageLookupByLibrary.simpleMessage("You need to log in"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("login"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logout_confirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to logout?"),
        "logsLabel": MessageLookupByLibrary.simpleMessage("Logs: "),
        "long_video": MessageLookupByLibrary.simpleMessage("Long Video"),
        "low_quality": MessageLookupByLibrary.simpleMessage("Low"),
        "lowerBody": MessageLookupByLibrary.simpleMessage("Lower Body"),
        "lowerBodyPart": MessageLookupByLibrary.simpleMessage("Lower Body"),
        "lowerTorso": MessageLookupByLibrary.simpleMessage("Lower Torso"),
        "mandatoryCategory":
            MessageLookupByLibrary.simpleMessage("Category * (Mandatory)"),
        "manualAdd": MessageLookupByLibrary.simpleMessage("Manual Add"),
        "materialLabel": MessageLookupByLibrary.simpleMessage("Material"),
        "max5ClothesError": MessageLookupByLibrary.simpleMessage(
            "You can select a maximum of 5 clothes."),
        "maxPhotoSelectionLimit": m23,
        "maybeLater": MessageLookupByLibrary.simpleMessage("Maybe Later"),
        "medium_quality": MessageLookupByLibrary.simpleMessage("Medium"),
        "min_6_chars": MessageLookupByLibrary.simpleMessage("Min 6 chars"),
        "minutesAgo": m24,
        "missing_verification_code": MessageLookupByLibrary.simpleMessage(
            "The verification code is missing. Please enter the code."),
        "missing_verification_id": MessageLookupByLibrary.simpleMessage(
            "The verification ID is missing. Try restarting the process."),
        "mode": MessageLookupByLibrary.simpleMessage("Mode"),
        "model": MessageLookupByLibrary.simpleMessage("Model"),
        "modelAddedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Model added successfully"),
        "modelDeleted": MessageLookupByLibrary.simpleMessage("Model deleted"),
        "modelNameHint": MessageLookupByLibrary.simpleMessage(
            "e.g. Summer model, Sport model"),
        "modelNameOptional":
            MessageLookupByLibrary.simpleMessage("Model Name (Optional)"),
        "modelSubtitle": MessageLookupByLibrary.simpleMessage(
            "Select who will try on the clothes"),
        "models": MessageLookupByLibrary.simpleMessage("Models"),
        "modelsAddedSuccessfully": m25,
        "modelsNotRecognized": m26,
        "monthlyPlan": MessageLookupByLibrary.simpleMessage("Monthly Plan"),
        "monthsAgo": m27,
        "motionMode": MessageLookupByLibrary.simpleMessage("Motion Mode"),
        "nOfMaxSelected": m28,
        "nSelected": m29,
        "nameSurname": MessageLookupByLibrary.simpleMessage("Name Surname"),
        "needToAddCloth": MessageLookupByLibrary.simpleMessage(
            "You need to add clothes to your wardrobe"),
        "needToAddModel":
            MessageLookupByLibrary.simpleMessage("You need to add a model"),
        "negativePrompt":
            MessageLookupByLibrary.simpleMessage("Negative Prompt"),
        "negativePromptHint": MessageLookupByLibrary.simpleMessage(
            "Enter negative prompt to avoid unwanted elements..."),
        "negative_prompt":
            MessageLookupByLibrary.simpleMessage("Negative Prompt"),
        "negative_prompt_hint": MessageLookupByLibrary.simpleMessage(
            "Describe what you don\'t want in the video (optional)"),
        "network_request_failed": MessageLookupByLibrary.simpleMessage(
            "Network connection failed. Please check your internet connection."),
        "newUsername": MessageLookupByLibrary.simpleMessage("New Username"),
        "new_password": MessageLookupByLibrary.simpleMessage("New Password"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noAdPermission": MessageLookupByLibrary.simpleMessage(
            "You do not have permission to watch ads."),
        "noCombinesFound":
            MessageLookupByLibrary.simpleMessage("No combines found"),
        "noEffectsFound":
            MessageLookupByLibrary.simpleMessage("No Effects Found"),
        "noFilterResults": MessageLookupByLibrary.simpleMessage(
            "No records found matching filters."),
        "noFitCheckLogsYet":
            MessageLookupByLibrary.simpleMessage("No FitCheck records yet"),
        "noImage": MessageLookupByLibrary.simpleMessage("No image"),
        "noImageGenerated": MessageLookupByLibrary.simpleMessage(
            "You haven\'t generated any image yet"),
        "noImageToShare":
            MessageLookupByLibrary.simpleMessage("No image to share"),
        "noInputDataForRegeneration": MessageLookupByLibrary.simpleMessage(
            "No input data found for regeneration"),
        "noInputDataForTemplateRegeneration":
            MessageLookupByLibrary.simpleMessage(
                "No input data found for template regeneration"),
        "noModelsFound":
            MessageLookupByLibrary.simpleMessage("No model photos found"),
        "noPasswordChange": MessageLookupByLibrary.simpleMessage(
            "This account was not logged in with a password, the password cannot be changed"),
        "noPastRecords":
            MessageLookupByLibrary.simpleMessage("No past records found yet."),
        "noRealtimeImageGenerated": MessageLookupByLibrary.simpleMessage(
            "You haven\'t generated realtime images yet"),
        "noRecordFoundForDate": MessageLookupByLibrary.simpleMessage(
            "No record found for this date."),
        "noStreakYet": MessageLookupByLibrary.simpleMessage(
            "You haven\'t caught a streak yet. Start today!"),
        "noStyleAnalysisYet":
            MessageLookupByLibrary.simpleMessage("No style analysis yet"),
        "noUserDataFound":
            MessageLookupByLibrary.simpleMessage("No user data found"),
        "noVideoGenerated": MessageLookupByLibrary.simpleMessage(
            "You haven\'t generated any video yet"),
        "noWatermarksAds":
            MessageLookupByLibrary.simpleMessage("No watermarks/ads"),
        "nonRenewable": MessageLookupByLibrary.simpleMessage("Non-renewable"),
        "normal_mode": MessageLookupByLibrary.simpleMessage("Normal Mode"),
        "normal_mode_description": MessageLookupByLibrary.simpleMessage(
            "Standard quality with balanced speed"),
        "notAFashionItem": MessageLookupByLibrary.simpleMessage(
            "This photo is not a clothing item or accessory"),
        "notProvided": MessageLookupByLibrary.simpleMessage("Not provided"),
        "notValidModelReason": MessageLookupByLibrary.simpleMessage(
            "This photo is not a model that can be dressed"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "offeringsEmpty":
            MessageLookupByLibrary.simpleMessage("Offerings empty"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "oneTime": MessageLookupByLibrary.simpleMessage("One Time"),
        "oneTimePurchase":
            MessageLookupByLibrary.simpleMessage("One Time Purchase"),
        "operationFailed":
            MessageLookupByLibrary.simpleMessage("Operation failed."),
        "operation_not_allowed": MessageLookupByLibrary.simpleMessage(
            "This operation is currently disabled. Please contact your administrator for more information."),
        "optional": MessageLookupByLibrary.simpleMessage("Optional"),
        "orLoginWith": MessageLookupByLibrary.simpleMessage("Or Login With"),
        "outfitCalendar":
            MessageLookupByLibrary.simpleMessage("Outfit Calendar 📅"),
        "outfitSuggestionFailed": MessageLookupByLibrary.simpleMessage(
            "Could not create outfit suggestion"),
        "pAndE": MessageLookupByLibrary.simpleMessage("P&E"),
        "packagesLoading":
            MessageLookupByLibrary.simpleMessage("Packages loading..."),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordChangedSuccess": MessageLookupByLibrary.simpleMessage(
            "Your password has been changed successfully"),
        "passwordResetLinkSent": MessageLookupByLibrary.simpleMessage(
            "Password reset link sent to your e-mail"),
        "password_error": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid password."),
        "passwords_dont_match":
            MessageLookupByLibrary.simpleMessage("Passwords don\'t match"),
        "pastCombines": MessageLookupByLibrary.simpleMessage("Past Combines"),
        "patternLabel": MessageLookupByLibrary.simpleMessage("Pattern"),
        "patternOptional":
            MessageLookupByLibrary.simpleMessage("Pattern (Optional)"),
        "perWeek": MessageLookupByLibrary.simpleMessage("per week"),
        "permissionRequired": MessageLookupByLibrary.simpleMessage(
            "You need to grant permission to select a photo"),
        "person1": MessageLookupByLibrary.simpleMessage("Person 1"),
        "person2": MessageLookupByLibrary.simpleMessage("Person 2"),
        "personalInformation":
            MessageLookupByLibrary.simpleMessage("Personal Information"),
        "photoAdded": MessageLookupByLibrary.simpleMessage("Photo added!"),
        "photoSavedToGallery":
            MessageLookupByLibrary.simpleMessage("Photo saved to gallery! ✅"),
        "photo_deleted_successfully": MessageLookupByLibrary.simpleMessage(
            "Photo is successfully deleted!"),
        "photo_type": MessageLookupByLibrary.simpleMessage("Photo Type"),
        "photosAddedSuccessfully": m30,
        "photosNotIdentifiedAsClothing": m31,
        "piecesCount": m32,
        "pinchToZoom": MessageLookupByLibrary.simpleMessage("Pinch to zoom"),
        "pixverseCompatibility":
            MessageLookupByLibrary.simpleMessage("Pixverse Uyumluluğu"),
        "pixverse_settings":
            MessageLookupByLibrary.simpleMessage("Customize Video"),
        "plans": MessageLookupByLibrary.simpleMessage("Plans"),
        "pleaseEditPrompt": MessageLookupByLibrary.simpleMessage(
            "Please edit your prompt and try again."),
        "pleaseSelectCategory":
            MessageLookupByLibrary.simpleMessage("Please select a category"),
        "pleaseSelectModelAndCloth": MessageLookupByLibrary.simpleMessage(
            "Please select a model and at least one cloth"),
        "please_enter_video_description": MessageLookupByLibrary.simpleMessage(
            "Please enter a video description"),
        "pollo_settings":
            MessageLookupByLibrary.simpleMessage("Pollo 1.6 Settings"),
        "poor": MessageLookupByLibrary.simpleMessage("Poor"),
        "pose": MessageLookupByLibrary.simpleMessage("Pose"),
        "predictTime": MessageLookupByLibrary.simpleMessage("Predict Time"),
        "premiumPackage":
            MessageLookupByLibrary.simpleMessage("Premium Package"),
        "premiumPlan": MessageLookupByLibrary.simpleMessage("Premium Plan"),
        "premiumTemplateTitle":
            MessageLookupByLibrary.simpleMessage("Premium Template"),
        "premiumTemplateUnlimitedInfo": MessageLookupByLibrary.simpleMessage(
            "Get unlimited access to premium templates by subscribing or purchasing credit packages."),
        "premiumTemplateUsedMessage": MessageLookupByLibrary.simpleMessage(
            "You have used your free trial for this premium template."),
        "preparing": MessageLookupByLibrary.simpleMessage("Preparing..."),
        "preparing_credit_info": MessageLookupByLibrary.simpleMessage(
            "Preparing credit information"),
        "priceNotAvailable":
            MessageLookupByLibrary.simpleMessage("Price Not Available"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "processCompleted":
            MessageLookupByLibrary.simpleMessage("Process Completed"),
        "processEstimatedTime": MessageLookupByLibrary.simpleMessage(
            "This process may take 10-15 seconds"),
        "processing": MessageLookupByLibrary.simpleMessage("Processing..."),
        "processingError": m33,
        "processingImage":
            MessageLookupByLibrary.simpleMessage("Processing image..."),
        "processingItems":
            MessageLookupByLibrary.simpleMessage("Processing Items"),
        "processingModels":
            MessageLookupByLibrary.simpleMessage("Processing Models"),
        "processing_request":
            MessageLookupByLibrary.simpleMessage("Processing your request..."),
        "product": MessageLookupByLibrary.simpleMessage("Product"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "profileAccessDescription": MessageLookupByLibrary.simpleMessage(
            "You need to log in to view and edit your profile."),
        "profileAccessRequired":
            MessageLookupByLibrary.simpleMessage("Profile Access Required"),
        "promptCopied": MessageLookupByLibrary.simpleMessage("Prompt copied!"),
        "promptEmpty":
            MessageLookupByLibrary.simpleMessage("Prompt cannot be empty"),
        "promptLabel": MessageLookupByLibrary.simpleMessage("Prompt: "),
        "purchase": MessageLookupByLibrary.simpleMessage("Purchase"),
        "purchaseButton": MessageLookupByLibrary.simpleMessage("Purchase"),
        "purchaseFailed": MessageLookupByLibrary.simpleMessage(
            "Purchase failed. Please try again."),
        "purchaseNow": MessageLookupByLibrary.simpleMessage("Purchase Now"),
        "purchaseSuccessful": MessageLookupByLibrary.simpleMessage(
            "Purchase successful! Credits will be added shortly."),
        "purchases": MessageLookupByLibrary.simpleMessage("Purchases"),
        "quality": MessageLookupByLibrary.simpleMessage("Quality"),
        "quickTry": MessageLookupByLibrary.simpleMessage("Quick Try"),
        "quickTryOn": MessageLookupByLibrary.simpleMessage("Quick Try-On"),
        "rateAppEarnCredit":
            MessageLookupByLibrary.simpleMessage("Rate Our App"),
        "rateAppSubtitle": MessageLookupByLibrary.simpleMessage(
            "Rate 5 stars, write a review and unlock 2nd video"),
        "rateOurApp": MessageLookupByLibrary.simpleMessage("Rate Our App"),
        "rateUs": MessageLookupByLibrary.simpleMessage("Rate Us"),
        "ratingSubmitted":
            MessageLookupByLibrary.simpleMessage("Thank you for your rating!"),
        "ready": MessageLookupByLibrary.simpleMessage("Let\'s go!"),
        "realtimeAI": MessageLookupByLibrary.simpleMessage("Realtime AI"),
        "realtimeImages":
            MessageLookupByLibrary.simpleMessage("Realtime Images"),
        "redirectingToFeedback": MessageLookupByLibrary.simpleMessage(
            "Redirecting to feedback page..."),
        "redirectingToPayment":
            MessageLookupByLibrary.simpleMessage("Redirecting to payment..."),
        "refundCredit": MessageLookupByLibrary.simpleMessage("Refund Credit"),
        "refundCreditDescription": MessageLookupByLibrary.simpleMessage(
            "To avoid being filtered, please enter your entries with a different wording"),
        "refundCreditTitle":
            MessageLookupByLibrary.simpleMessage("Refund Credit"),
        "refundFailed": MessageLookupByLibrary.simpleMessage(
            "Refund failed. Please try again."),
        "refundLimitReached":
            MessageLookupByLibrary.simpleMessage("Refund Limit Reached"),
        "refundLimitReachedDescription": m5,
        "refundProcessedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Refund processed successfully!"),
        "refundProcessedSuccessfullyDefault":
            MessageLookupByLibrary.simpleMessage(
                "Refund processed successfully!"),
        "refundProcessedSuccessfullyWithMessage":
            MessageLookupByLibrary.simpleMessage(
                "Refund processed successfully!"),
        "regenerate": MessageLookupByLibrary.simpleMessage("Regenerate"),
        "regenerateButton": MessageLookupByLibrary.simpleMessage("Regenerate"),
        "regenerateCombine":
            MessageLookupByLibrary.simpleMessage("Regenerate Combine"),
        "regeneratingCombine":
            MessageLookupByLibrary.simpleMessage("Regenerating..."),
        "removingBackground":
            MessageLookupByLibrary.simpleMessage("Removing background..."),
        "repeat_new_password":
            MessageLookupByLibrary.simpleMessage("Repeat New Password"),
        "reportContent": MessageLookupByLibrary.simpleMessage("Report Content"),
        "reportFailedToSend": MessageLookupByLibrary.simpleMessage(
            "Failed to send report. Please try again."),
        "reportReason": MessageLookupByLibrary.simpleMessage(
            "Please specify why this content is inappropriate"),
        "reportSending":
            MessageLookupByLibrary.simpleMessage("Sending report..."),
        "reportSentSuccessfully":
            MessageLookupByLibrary.simpleMessage("Report sent successfully!"),
        "reportSuccess": MessageLookupByLibrary.simpleMessage(
            "Successfully submitted! It will be reviewed as soon as possible and you will be notified"),
        "requestCreationFailed":
            MessageLookupByLibrary.simpleMessage("Could not create request."),
        "requestSentSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Request sent successfully! Combine is being prepared..."),
        "required": MessageLookupByLibrary.simpleMessage("Required"),
        "requires_recent_login": MessageLookupByLibrary.simpleMessage(
            "You need to log in again to perform this operation."),
        "resetYourPassword":
            MessageLookupByLibrary.simpleMessage("Reset Your Password"),
        "resolution": MessageLookupByLibrary.simpleMessage("Resolution"),
        "restorePurchases":
            MessageLookupByLibrary.simpleMessage("Restore Purchases"),
        "restorePurchasesEmpty": MessageLookupByLibrary.simpleMessage(
            "No purchases found to restore."),
        "restorePurchasesError": MessageLookupByLibrary.simpleMessage(
            "Failed to restore purchases. Please try again."),
        "restorePurchasesSuccess": MessageLookupByLibrary.simpleMessage(
            "Purchases restored successfully!"),
        "result": MessageLookupByLibrary.simpleMessage("Result"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "reviewCompletedNoCredit": MessageLookupByLibrary.simpleMessage(
            "✅ Review completed! Now you can create your 2nd video."),
        "reviewConfirmationMessage":
            MessageLookupByLibrary.simpleMessage("Did you rate our app?"),
        "reviewConfirmationMessageAndroid":
            MessageLookupByLibrary.simpleMessage(
                "Did you rate our app in the Play Store?"),
        "reviewConfirmationMessageIOS": MessageLookupByLibrary.simpleMessage(
            "Did you rate our app in the App Store?"),
        "reviewConfirmationTitle":
            MessageLookupByLibrary.simpleMessage("Review"),
        "reviewCreditAlreadyClaimed": MessageLookupByLibrary.simpleMessage(
            "You have already claimed your review credit!"),
        "reviewFailedPhotos":
            MessageLookupByLibrary.simpleMessage("Review Failed Photos"),
        "reviewPageError": MessageLookupByLibrary.simpleMessage(
            "Could not open review page. Please try again."),
        "reviewRequiredBonus":
            MessageLookupByLibrary.simpleMessage("Unlock 2nd Video!"),
        "reviewRequiredButton": MessageLookupByLibrary.simpleMessage(
            "Rate 5 Stars & Create 2nd Video"),
        "reviewRequiredMessage": MessageLookupByLibrary.simpleMessage(
            "Please rate our app to create your 2nd video!"),
        "reviewRequiredTitle":
            MessageLookupByLibrary.simpleMessage("Unlock 2nd Video"),
        "reviewThanksWithCredit": MessageLookupByLibrary.simpleMessage(
            "✅ Thank you! You can now create your 2nd video."),
        "reviewThanksWithoutCredit": MessageLookupByLibrary.simpleMessage(
            "😊 Thank you! We appreciate your feedback."),
        "save": MessageLookupByLibrary.simpleMessage("SAVE"),
        "saveError": MessageLookupByLibrary.simpleMessage("Save error"),
        "saving": MessageLookupByLibrary.simpleMessage("Saving..."),
        "savingEllipsis": MessageLookupByLibrary.simpleMessage("Saving..."),
        "scoreLabel": MessageLookupByLibrary.simpleMessage("SCORE"),
        "scrollToEnlarge":
            MessageLookupByLibrary.simpleMessage("Scroll to enlarge image"),
        "searchingForInfo": m34,
        "seasonLabel": MessageLookupByLibrary.simpleMessage("Season"),
        "seasonOptional":
            MessageLookupByLibrary.simpleMessage("Season (Optional)"),
        "secondPerson": MessageLookupByLibrary.simpleMessage("Second Person"),
        "secure": MessageLookupByLibrary.simpleMessage("Secure"),
        "selectASinglePhoto":
            MessageLookupByLibrary.simpleMessage("Select a single photo"),
        "selectAll": MessageLookupByLibrary.simpleMessage("Select All"),
        "selectCategory": m35,
        "selectCloth": MessageLookupByLibrary.simpleMessage("Select Cloth"),
        "selectFromGallery":
            MessageLookupByLibrary.simpleMessage("Select from Gallery"),
        "selectItemType":
            MessageLookupByLibrary.simpleMessage("Select Item Type"),
        "selectLanguage":
            MessageLookupByLibrary.simpleMessage("Select Language"),
        "selectMedia": MessageLookupByLibrary.simpleMessage("Select Media"),
        "selectModel": MessageLookupByLibrary.simpleMessage("Select Model"),
        "selectOutfit": MessageLookupByLibrary.simpleMessage("Select Outfit"),
        "selectPhoto": MessageLookupByLibrary.simpleMessage("Select Photo"),
        "selectPhotosForBothPeople": MessageLookupByLibrary.simpleMessage(
            "Select photos for both people"),
        "select_start_image":
            MessageLookupByLibrary.simpleMessage("Select Start Image"),
        "select_tail_image":
            MessageLookupByLibrary.simpleMessage("Select Tail Image"),
        "selectedLabel": m36,
        "selectedMediaCount": m37,
        "selectedModel": MessageLookupByLibrary.simpleMessage("Selected Model"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendVerificationEmail":
            MessageLookupByLibrary.simpleMessage("Send Verification Email"),
        "separate_photos":
            MessageLookupByLibrary.simpleMessage("2 separate photos"),
        "settingLanguage":
            MessageLookupByLibrary.simpleMessage("Getting creative..."),
        "settingsPersonalInfo":
            MessageLookupByLibrary.simpleMessage("Settings and Personal Info"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shareCombineText": MessageLookupByLibrary.simpleMessage(
            "I\'m sharing my combine from Comby! 🌟"),
        "shareError": MessageLookupByLibrary.simpleMessage("Share error"),
        "shareMessageFitCheck": MessageLookupByLibrary.simpleMessage(
            "I analyzed my outfit with Comby! 🌟"),
        "shareText": MessageLookupByLibrary.simpleMessage(
            "Check out this image I created on Comby! Download App: app.comby.ai"),
        "shareTextFromUrl": MessageLookupByLibrary.simpleMessage(
            "Check out this image I created on Comby!\nDownload App: app.comby.ai"),
        "shareVideoText": MessageLookupByLibrary.simpleMessage(
            "Check out this video I created on Comby AI! Download App: app.comby.ai"),
        "short_video": MessageLookupByLibrary.simpleMessage("Short Video"),
        "showAllEffects":
            MessageLookupByLibrary.simpleMessage("Show All Effects"),
        "showMore": MessageLookupByLibrary.simpleMessage("Show More"),
        "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
        "signInWithAccount":
            MessageLookupByLibrary.simpleMessage("Sign In with Account"),
        "signup_button_link": MessageLookupByLibrary.simpleMessage("Sign up"),
        "signup_button_text":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account? "),
        "similarItems": MessageLookupByLibrary.simpleMessage("Similar Items"),
        "sizeLabel": MessageLookupByLibrary.simpleMessage("Size"),
        "sizeText": m6,
        "skinTone": MessageLookupByLibrary.simpleMessage("Skin Tone"),
        "skip": MessageLookupByLibrary.simpleMessage("Skip"),
        "spring": MessageLookupByLibrary.simpleMessage("Spring"),
        "startGenerating":
            MessageLookupByLibrary.simpleMessage("Start Generating"),
        "startStreak": MessageLookupByLibrary.simpleMessage("Start Streak!"),
        "start_image": MessageLookupByLibrary.simpleMessage("Start Image"),
        "startedAtLabel": MessageLookupByLibrary.simpleMessage("Started At: "),
        "streakAwesome": MessageLookupByLibrary.simpleMessage(
            "Awesome! 🔥 A week of consistency"),
        "streakGood":
            MessageLookupByLibrary.simpleMessage("Good start! ✨ Keep it up"),
        "streakLegendary": MessageLookupByLibrary.simpleMessage(
            "Legendary! 🏆 You\'re a true style icon"),
        "streakSuper": MessageLookupByLibrary.simpleMessage(
            "Doing great! 🚀 Keep the streak"),
        "streamLabel": MessageLookupByLibrary.simpleMessage("Stream: "),
        "style": MessageLookupByLibrary.simpleMessage("Style"),
        "styleAnalysisLoadFailed": MessageLookupByLibrary.simpleMessage(
            "Style analysis could not be loaded. Please try again."),
        "styleAnalysisUpdated":
            MessageLookupByLibrary.simpleMessage("Style analysis updated!"),
        "styleDnaTitle": MessageLookupByLibrary.simpleMessage("Style DNA"),
        "styleExplorer": MessageLookupByLibrary.simpleMessage("Style Explorer"),
        "styleJournal": MessageLookupByLibrary.simpleMessage("Style Journal"),
        "styleSuggestions":
            MessageLookupByLibrary.simpleMessage("Style Suggestions"),
        "styleTitle": MessageLookupByLibrary.simpleMessage("Style"),
        "stylistDetailedAnalysis": MessageLookupByLibrary.simpleMessage(
            "Your stylist is doing a detailed analysis"),
        "stylistOpinions":
            MessageLookupByLibrary.simpleMessage("Stylist Opinions"),
        "submit": MessageLookupByLibrary.simpleMessage("Submit"),
        "submitFeedback":
            MessageLookupByLibrary.simpleMessage("Submit Feedback"),
        "submitReport": MessageLookupByLibrary.simpleMessage("Report"),
        "subscribeNow": MessageLookupByLibrary.simpleMessage("Subscribe Now"),
        "subscriptionRequiredForCredits": MessageLookupByLibrary.simpleMessage(
            "You need an active subscription to purchase extra credits"),
        "subscriptionSuccessful":
            MessageLookupByLibrary.simpleMessage("Subscription successful!"),
        "subscriptions": MessageLookupByLibrary.simpleMessage("Subscriptions"),
        "success": MessageLookupByLibrary.simpleMessage("Success"),
        "successCountLabel": m38,
        "successful": MessageLookupByLibrary.simpleMessage("Successful"),
        "successfully": MessageLookupByLibrary.simpleMessage("Successfully"),
        "summer": MessageLookupByLibrary.simpleMessage("Summer"),
        "surpriseMe": MessageLookupByLibrary.simpleMessage("Surprise Me"),
        "tail_image": MessageLookupByLibrary.simpleMessage("Tail Image"),
        "takePhoto": MessageLookupByLibrary.simpleMessage("Take Photo"),
        "tapToChooseFromLibrary":
            MessageLookupByLibrary.simpleMessage("Tap to choose from library"),
        "tapToSelect": MessageLookupByLibrary.simpleMessage("Tap to select"),
        "tapToSelectCategory": MessageLookupByLibrary.simpleMessage(
            "Tap a body part to select category"),
        "templateRegenerationStarted": m7,
        "termsOfService":
            MessageLookupByLibrary.simpleMessage("Terms of Service"),
        "terms_of_service_required": MessageLookupByLibrary.simpleMessage(
            "You must agree to the Terms of Service and Privacy Policy to continue."),
        "text_to_video": MessageLookupByLibrary.simpleMessage("Text to Video"),
        "thisActionCannotBeUndone": MessageLookupByLibrary.simpleMessage(
            "This action cannot be undone."),
        "threeDAnimationStyle":
            MessageLookupByLibrary.simpleMessage("3D Animation"),
        "threeDAnimationStyleDescription": MessageLookupByLibrary.simpleMessage(
            "Three-dimensional animation style"),
        "ticket_hot": MessageLookupByLibrary.simpleMessage("Hot"),
        "ticket_new": MessageLookupByLibrary.simpleMessage("New"),
        "ticket_popular": MessageLookupByLibrary.simpleMessage("Popular"),
        "ticket_premium": MessageLookupByLibrary.simpleMessage("PREMIUM 🔥"),
        "ticket_trend": MessageLookupByLibrary.simpleMessage("Trend"),
        "toAvoidFiltering": MessageLookupByLibrary.simpleMessage(
            "To avoid filtering, copy the command and explain it slightly differently."),
        "today": MessageLookupByLibrary.simpleMessage("Today"),
        "toggleGridLayoutTooltip":
            MessageLookupByLibrary.simpleMessage("Toggle Grid Layout"),
        "too_many_requests": MessageLookupByLibrary.simpleMessage(
            "Access to your account has been temporarily blocked. Please try again later."),
        "total": MessageLookupByLibrary.simpleMessage("Total"),
        "trendingVideoEffects":
            MessageLookupByLibrary.simpleMessage("Trending AI Video Effects"),
        "trialPackageUsed": MessageLookupByLibrary.simpleMessage(
            "You have already used your trial package. You can continue by purchasing a subscription."),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
        "tryNow": MessageLookupByLibrary.simpleMessage("Try Now"),
        "tryOnMode": MessageLookupByLibrary.simpleMessage("Try-On Mode"),
        "typeYourPrompt": MessageLookupByLibrary.simpleMessage(
            "Type your prompt below to generate realtime images"),
        "uid": MessageLookupByLibrary.simpleMessage("UID"),
        "uidCopied": MessageLookupByLibrary.simpleMessage("UID copied!"),
        "uidLabel": m39,
        "ultra_quality": MessageLookupByLibrary.simpleMessage("Ultra"),
        "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "unlimitedUsage":
            MessageLookupByLibrary.simpleMessage("Unlimited Usage"),
        "unlockAllFeatures":
            MessageLookupByLibrary.simpleMessage("Unlock all features"),
        "unnamedModel": MessageLookupByLibrary.simpleMessage("Unnamed Model"),
        "updateButton": MessageLookupByLibrary.simpleMessage("Update"),
        "updatedNow": MessageLookupByLibrary.simpleMessage("Updated now"),
        "updatedToday": MessageLookupByLibrary.simpleMessage("Updated today"),
        "updatedYesterday":
            MessageLookupByLibrary.simpleMessage("Updated yesterday"),
        "upgradeAccount":
            MessageLookupByLibrary.simpleMessage("Upgrade Account"),
        "upgradeAccountDescription": m8,
        "upgradeAccountForReviewCredit": MessageLookupByLibrary.simpleMessage(
            "To claim 60 free credits, please upgrade your account first"),
        "upgradeAccountMessage": MessageLookupByLibrary.simpleMessage(
            "You need to upgrade your account to claim free credits. Upgrade now to unlock this feature!"),
        "upgradeAccountRequired":
            MessageLookupByLibrary.simpleMessage("Account Upgrade Required"),
        "upgradeToFullAccount":
            MessageLookupByLibrary.simpleMessage("Upgrade to Full Account"),
        "upgradeYourAccount":
            MessageLookupByLibrary.simpleMessage("Upgrade Your Account"),
        "uploadFirstPhoto":
            MessageLookupByLibrary.simpleMessage("Upload First\nphoto"),
        "uploadIfSamePhoto": MessageLookupByLibrary.simpleMessage(
            "Upload if both people are in the same photo"),
        "uploadPhoto": MessageLookupByLibrary.simpleMessage("Upload Photo"),
        "uploadSecondaryPhoto":
            MessageLookupByLibrary.simpleMessage("Upload Secondary\nphoto"),
        "upload_images": MessageLookupByLibrary.simpleMessage("Upload Images"),
        "upload_photo": MessageLookupByLibrary.simpleMessage("Upload Photo"),
        "upload_photos": MessageLookupByLibrary.simpleMessage("Upload Photos"),
        "uploading": MessageLookupByLibrary.simpleMessage("Uploading..."),
        "upperBody": MessageLookupByLibrary.simpleMessage("Upper Body"),
        "upperBodyPart": MessageLookupByLibrary.simpleMessage("Upper Body"),
        "upperTorso": MessageLookupByLibrary.simpleMessage("Upper Torso"),
        "useAIVideoEffects":
            MessageLookupByLibrary.simpleMessage("Use AI Video Effects"),
        "useAiPhoto": MessageLookupByLibrary.simpleMessage("Use AI Photo"),
        "useOriginalPhoto":
            MessageLookupByLibrary.simpleMessage("Use Original Photo"),
        "usedItems": MessageLookupByLibrary.simpleMessage("Used Items"),
        "user": MessageLookupByLibrary.simpleMessage("User"),
        "userInfoLoadError": MessageLookupByLibrary.simpleMessage(
            "Failed to load user information"),
        "userNotFound": MessageLookupByLibrary.simpleMessage("User Not Found"),
        "user_disabled": MessageLookupByLibrary.simpleMessage(
            "This user account has been disabled."),
        "user_not_found": MessageLookupByLibrary.simpleMessage(
            "No user found with this email address."),
        "user_summary_screen":
            MessageLookupByLibrary.simpleMessage("User Summary Screen"),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "usernameUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Username updated successfully"),
        "vehicle": MessageLookupByLibrary.simpleMessage("Vehicle"),
        "verificationEmailSent": MessageLookupByLibrary.simpleMessage(
            "Verification email sent! Please check your inbox and click the verification link."),
        "versionInfo": m40,
        "veryGood": MessageLookupByLibrary.simpleMessage("Very Good"),
        "veryPoor": MessageLookupByLibrary.simpleMessage("Very Poor"),
        "verySoon": MessageLookupByLibrary.simpleMessage("Very soon!"),
        "video": MessageLookupByLibrary.simpleMessage("Video"),
        "videoDeletedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Video deleted successfully"),
        "videoDetails": MessageLookupByLibrary.simpleMessage("Video Details"),
        "videoGenerate": MessageLookupByLibrary.simpleMessage("Video Generate"),
        "videoGenerationFailed":
            MessageLookupByLibrary.simpleMessage("Video Generation Failed"),
        "videoGenerationFailedDescription": MessageLookupByLibrary.simpleMessage(
            "To avoid being filtered, please enter your entries with a different wording?"),
        "videoIdCopied":
            MessageLookupByLibrary.simpleMessage("Video ID copied!"),
        "videoLabelUpper": MessageLookupByLibrary.simpleMessage("VIDEO"),
        "videoRegenerationStarted": MessageLookupByLibrary.simpleMessage(
            "Generating different version of video"),
        "videoTab": MessageLookupByLibrary.simpleMessage("Video"),
        "video_generation_error": MessageLookupByLibrary.simpleMessage(
            "Video generation failed. Please try again."),
        "video_generation_started":
            MessageLookupByLibrary.simpleMessage("Video generation started..."),
        "video_generation_success": MessageLookupByLibrary.simpleMessage(
            "Your video is being created. This process takes 10-60 seconds"),
        "video_preview_error":
            MessageLookupByLibrary.simpleMessage("Preview could not be loaded"),
        "video_preview_loading":
            MessageLookupByLibrary.simpleMessage("Loading video preview..."),
        "videos": MessageLookupByLibrary.simpleMessage("Videos"),
        "viewErrorDataNotFound":
            MessageLookupByLibrary.simpleMessage("View Error: Data not found."),
        "viewResults": MessageLookupByLibrary.simpleMessage("View Results"),
        "viralEffectsOnTiktok":
            MessageLookupByLibrary.simpleMessage("Viral Effects On Tiktok"),
        "viralOnTiktok":
            MessageLookupByLibrary.simpleMessage("Viral on TikTok"),
        "virtualCabin": MessageLookupByLibrary.simpleMessage("Virtual Cabin"),
        "wardrobe": MessageLookupByLibrary.simpleMessage("Wardrobe"),
        "wardrobeEmpty": MessageLookupByLibrary.simpleMessage(
            "Your wardrobe is empty! Add items."),
        "wardrobeSubtitle":
            MessageLookupByLibrary.simpleMessage("Pick items to mix & match"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning"),
        "watchAdEarnCredit": MessageLookupByLibrary.simpleMessage("Watch Ads"),
        "watchAdSubtitle": MessageLookupByLibrary.simpleMessage(
            "Earn credits by watching video ads"),
        "watchAdToEarn": MessageLookupByLibrary.simpleMessage(
            "Watch a short video ad to earn 20 credits"),
        "watchAds": MessageLookupByLibrary.simpleMessage("Watch Ads"),
        "watchLimit": MessageLookupByLibrary.simpleMessage(
            "(You can watch up to 3 ads per day)"),
        "watch_5_ads_to_claim": MessageLookupByLibrary.simpleMessage(
            "You need to watch 3 ads to claim credits."),
        "watch_ad":
            MessageLookupByLibrary.simpleMessage("Watch Ad to Earn Credits"),
        "weak_password": MessageLookupByLibrary.simpleMessage(
            "The password you entered is too weak. Please choose a stronger password."),
        "weather": MessageLookupByLibrary.simpleMessage("Weather"),
        "weatherBasedOutfitSuggestion": MessageLookupByLibrary.simpleMessage(
            "Create your best outfit based on weather"),
        "weatherInfoNotReceived":
            MessageLookupByLibrary.simpleMessage("Weather info not received"),
        "weatherRenewed":
            MessageLookupByLibrary.simpleMessage("Weather (Renewed)"),
        "weatherSuggestion":
            MessageLookupByLibrary.simpleMessage("Weather Suggestion"),
        "webLabel": MessageLookupByLibrary.simpleMessage("Web: "),
        "weeklyPlan": MessageLookupByLibrary.simpleMessage("Weekly Plan"),
        "weeksAgo": m41,
        "welcome_messages": MessageLookupByLibrary.simpleMessage(
            "How do you want to look today?"),
        "whyFailed": MessageLookupByLibrary.simpleMessage("Why failed?"),
        "wind": MessageLookupByLibrary.simpleMessage("Wind"),
        "winter": MessageLookupByLibrary.simpleMessage("Winter"),
        "writeYourMessage":
            MessageLookupByLibrary.simpleMessage("Write your message..."),
        "wrong_password":
            MessageLookupByLibrary.simpleMessage("Incorrect password."),
        "wtfEffects": MessageLookupByLibrary.simpleMessage("WTF Effects"),
        "yearlyPlan": MessageLookupByLibrary.simpleMessage("Yearly Plan"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "yesIRated": MessageLookupByLibrary.simpleMessage("Yes, I Rated"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday")
      };
}
