 ## Flutter wrapper
 -keep class io.flutter.app.** { *; }
 -keep class io.flutter.plugin.** { *; }
 -keep class io.flutter.util.** { *; }
 -keep class io.flutter.view.** { *; }
 -keep class io.flutter.** { *; }
 -keep class io.flutter.plugins.** { *; }
 -keep class com.google.firebase.** { *; }
 -dontwarn io.flutter.embedding.**
 -keep class * {
    @com.example.envied_annotations.Envied *;
}
 -ignorewarnings

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.auth.api.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.tasks.Task { *; }
-keep class com.google.android.gms.tasks.TaskCompletionSource { *; }

# RevenueCat
-keep class com.revenuecat.** { *; }
-keep class com.android.billingclient.** { *; }