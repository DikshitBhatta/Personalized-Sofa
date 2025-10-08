import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/wrapper.dart';
import 'package:timberr/role/role_access.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize role system after Firebase
  try {
    await RoleBasedAccessControl.initializeRoleSystem();
    print('✅ Role system initialized successfully');
  } catch (e) {
    print('⚠️ Role system initialization failed: $e');
    print('📋 App will continue with fallback role handling');
  }
  
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
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: "NunitoSans",
        appBarTheme: const AppBarTheme(color: kLynxWhite, elevation: 0),
        scaffoldBackgroundColor: kLynxWhite,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kOffBlack),
        ),
      ),
      home: const Wrapper(),
    );
  }
}
