import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3FVf7ffj9-jtpSjUwLwATpBNA10Z88IQ',
    appId: '1:672413418618:android:409ea634fb6cfe5466e7c3',
    messagingSenderId: '672413418618',
    projectId: 'estatecrm-3e55a',
    storageBucket: 'estatecrm-3e55a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPehlhNqcVL0-BknRwdbjLeEuq-BHkNk0',
    appId: '1:672413418618:ios:4c7155052e7bbb3b66e7c3',
    messagingSenderId: '672413418618',
    projectId: 'estatecrm-3e55a',
    storageBucket: 'estatecrm-3e55a.firebasestorage.app',
    iosBundleId: 'com.sultan.estatecrm',
  );
}
