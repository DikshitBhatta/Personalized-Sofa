import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/routes/app_routes.dart';
import 'package:timberr/services/init_services.dart';
import 'package:timberr/bindings/initial_binding.dart';

// Background message handler must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background message received: ${message.messageId}');
}

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (must be done before any Firebase operations)
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize all core services before running the app
  // This ensures services are ready before any widget builds - eliminates race conditions
  await initServices();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  
  runApp(const TimberrApp());
}

class TimberrApp extends StatelessWidget {
  const TimberrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      
      // Initial binding ensures global controllers are available from the start
      initialBinding: InitialBinding(),
      
      // Use named routes with proper bindings for each screen
      initialRoute: AppRoutes.wrapper,
      getPages: AppRoutes.routes,
      
      // Smart management handles controller lifecycle automatically
      smartManagement: SmartManagement.full,
      
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: "NunitoSans",
        appBarTheme: const AppBarTheme(color: kLynxWhite, elevation: 0),
        scaffoldBackgroundColor: kLynxWhite,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kOffBlack),
        ),
      ),
    );
  }
}
