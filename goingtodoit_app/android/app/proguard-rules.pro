# flutter_local_notifications relies on Gson reflection; keep its classes so
# release (R8/minified) builds don't strip required types.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Keep generic signature of TypeToken & subclasses (Gson).
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
