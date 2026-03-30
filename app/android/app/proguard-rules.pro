# Play Core (referenced by Flutter engine, not used in direct installs)
-dontwarn com.google.android.play.core.**

# Keep BouncyCastle provider for HTTPS/TLS connections
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep Conscrypt (Android TLS provider)
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep OkHttp internals (used by some Flutter plugins)
-dontwarn okhttp3.**
-dontwarn okio.**
