import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:medlytic/screens/splash_screen.dart';
import 'package:medlytic/theme/app_theme.dart';

import 'controllers/app_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/firebase_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/voice_assistant_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue without Firebase for demo mode
  }

  // Initialize controllers before app starts
  Get.put(AuthController(), permanent: true);
  Get.put(FirebaseController(), permanent: true);
  Get.put(AppController(), permanent: true);
  Get.put(VoiceAssistantController(), permanent: true);
  Get.put(NavigationController());


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediHelper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      defaultTransition: Transition.fade,
    );
  }
}
