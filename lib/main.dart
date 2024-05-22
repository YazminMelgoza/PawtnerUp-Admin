import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:pawtnerup_admin/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:pawtnerup_admin/config/router/app_router.dart';

// Firebase Imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(riverpod.ProviderScope(
    child: MyApp(), // Replace MyApp with your main app widget
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return riverpod.ProviderScope(
      child: MaterialApp.router(
        title: 'Pawtner Up',
        routerConfig: appRouter,
        theme: AppTheme().getTheme(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}