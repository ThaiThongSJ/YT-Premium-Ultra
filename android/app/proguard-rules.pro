# =========================================================================
# BẢN CẤU HÌNH PROGUARD CHUẨN - FIX LỖI R8 PLAY CORE & WEBVIEW
# =========================================================================

# 1. Bỏ qua các cảnh báo thiếu class của Google Play Core (Sửa lỗi R8 Missing Classes)
-dontwarn com.google.android.play.core.**

# 2. Giữ lại toàn bộ các class cốt lõi của Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# 3. Bảo vệ WebView & Javascript Interface cho Engine V3.0
-keepattributes InclosingMethod,InnerClasses,Signature,Annotation,*Annotation*,EnclosingMethod
-keepattributes JavascriptInterface

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keep class android.webkit.** { *; }