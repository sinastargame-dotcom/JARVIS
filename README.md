# JARVIS Mobile 1.0

A bilingual Persian/English Flutter voice-assistant starter app.

## Current features
- Futuristic dark cyan interface
- Speech recognition through the Android speech service
- Persian and English text-to-speech (depends on voices installed on the phone)
- Basic local commands: greeting, time, date, help, assistant name
- Text chat input

## Important limitations
This first version is not connected to a generative AI service yet. Unknown questions receive a clear fallback response. The speech recognition package is intended for short commands, not always-on listening. The app does not secretly listen in the background.

## Build APK with Codemagic
1. Upload this project to a GitHub repository (keep the folder structure).
2. Sign in to Codemagic and connect the GitHub repository.
3. Add the app and select the `jarvis-android` workflow from `codemagic.yaml`.
4. Start the build.
5. Download `app-release.apk` from the build artifacts.
6. Transfer it to the Android phone and install it. Allow microphone permission when asked.

For an unsigned test APK, the workflow can be changed to `flutter build apk --debug`, but the provided workflow builds a release APK.

## Local Android setup
The workflow generates the Android platform folder before building. The custom manifest in `tool/AndroidManifest.xml` is copied into the generated Android project.
