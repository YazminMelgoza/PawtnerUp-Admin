import  'package:flutter/material.dart';  
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:pawtnerup_admin/provider/auth_provider.dart';
import 'package:pawtnerup_admin/services/shelter_service.dart';
import 'package:pawtnerup_admin/services/user_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() async {
      if (FirebaseAuth.instance.currentUser != null) {
      Provider.of<AuthenticationProvider>(context, listen: false).user = await ShelterService().getShelterById(FirebaseAuth.instance.currentUser!.uid);
      if (mounted) {
        context.go('/Root');
      }
    } else {
        context.go('/login');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColor.blue,
        ),
        child: const Center(
          child: Text(
            'PawtnerUp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'PottaOne',
            ),
          ),
        ),
      ),  
    );
  }
}