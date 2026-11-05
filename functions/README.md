# Gemini mood-insights function

This Firebase Functions scaffold sends only the `correlations` and
`outlier_samples` from `MoodAnalysis.toAiMap()` to Gemini. Journal notes and
other analysis fields are not included. The Gemini API key stays in Firebase
Secret Manager; it must not be added to the Flutter app.

The function uses the stable, cost-efficient `gemini-3.1-flash-lite` model.
Review the [current Gemini API pricing](https://ai.google.dev/gemini-api/docs/pricing)
before production use because model pricing and availability can change.

## Setup and deployment

1. Create a Firebase project and register the Android/iOS apps. Configure
   FlutterFire and initialize Firebase in the app.
2. Enable **Anonymous** sign-in in Firebase Authentication. The function
   rejects unauthenticated calls.
3. Configure Firebase App Check for the platforms you ship. The function
   enforces App Check, so unverified requests are rejected.
4. Install the Firebase CLI, sign in, and select your Firebase project from the
   repository root:

   ```sh
   firebase login
   firebase use --add
   ```

5. Add a Gemini API key to Firebase Secret Manager and deploy:

   ```sh
   firebase functions:secrets:set GEMINI_API_KEY
   firebase deploy --only functions:generateMoodInsights
   ```

Cloud Functions deployment requires a Firebase project with billing enabled.
Set a Firebase budget alert and function quotas before enabling this in a
released app.

## Client call after Firebase setup

Add `firebase_core`, `firebase_auth`, and `cloud_functions` to the Flutter
project and initialize Firebase using the generated FlutterFire options. Sign
the user in anonymously and initialize App Check before calling the function.
Then pass the privacy-filtered map:

```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('generateMoodInsights')
    .call(<String, Object>{'analysis': analysis.toAiMap()});
```

The callable returns `primary_drivers` and exactly one `Continue` and one
`Adjust` recommendation. If the analysis has no supporting correlation for one
of those categories, the model is instructed to say that evidence is
insufficient rather than inventing a trigger or generic advice.
