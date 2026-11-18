# AppPulse native code (method channel handler, WorkManager workers).
-keep class dev.basalt.apppulse.** { *; }
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# Flutter deferred components reference Play Core classes that are not shipped.
-dontwarn com.google.android.play.core.**
