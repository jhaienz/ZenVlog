# MediaPipe (flutter_gemma) references proto classes not shipped in tasks-genai
-dontwarn com.google.auto.value.extension.memoized.Memoized
-dontwarn com.google.mediapipe.proto.**
-keep class com.google.mediapipe.** { *; }
