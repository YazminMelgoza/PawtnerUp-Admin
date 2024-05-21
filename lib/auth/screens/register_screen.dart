// import 'package:pawtnerup_admin/Json/users.dart';
// import 'package:pawtnerup_admin/auth/db/sqlite.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:pawtnerup_admin/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawtnerup_admin/shared/shared.dart';

import 'package:firebase_auth/firebase_auth.dart';
//Utils for Google Login
import 'package:pawtnerup_admin/utils/login_google_utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// util for picking image
import 'package:pawtnerup_admin/utils/pick_image.dart';
import 'package:pawtnerup_admin/utils/show_snack_bar.dart';
import 'dart:io';
import 'package:pawtnerup_admin/services/user_service.dart';

// RegisterScreen
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo con tus mascotas
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/BackgroundRegister.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Imagen de mascota sin fondo posicionada estratégicamente
            Positioned(
              top: 35.0,
              left: (MediaQuery.of(context).size.width - 250) / 2,
              child: const Image(
                image: AssetImage("assets/images/mascotasRegister.png"),
                width: 250.0,
                height: 250.0,
              ),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 260),
                  Container(
                    color: Colors.transparent,
                    child: Text(
                      'Registra tu refugio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColor.blue, fontWeight: FontWeight.bold, fontFamily: 'Outfit'
                      ),
                    ),
                  ),                  Container(
                    height: MediaQuery.of(context).size.height - 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                      ),
                    ),
                    child: const _RegisterForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  File? image;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () async {
              image = await pickImage(context);
              setState(() {});
            },
            child: CircleAvatar(
              radius: 45,
              backgroundColor: AppColor.darkblue,
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: Image.file(
                        image!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.add_a_photo,
                      size: 45,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Nombre del refugio',
            keyboardType: TextInputType.emailAddress,
            controller: username,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            controller: email,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Contraseña',
            obscureText: true,
            controller: password,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Repita la contraseña',
            obscureText: true,
            controller: confirmPassword,
          ),
          const SizedBox(height: 20),
          //Button to create user using email and password


          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              text: 'Crear',
              buttonColor: AppColor.blue,
              icon: MdiIcons.fromString("account-multiple-plus"),
              onPressed: () async {
                if (!areFieldsValid()) return;
                try {
                  await UserService().createUser(
                    username.text,
                    email.text,
                    password.text,
                    image
                  );
                  if (context.mounted) context.go("/Root");
                } catch (e) {
                  if (context.mounted) showSnackBar(context, e.toString());
                }
              },
            ),
          ),
          //Login with Google Button
          /*SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              text: "Google",
              buttonColor: AppColor.blue,
              icon: MdiIcons.fromString("google"),
              onPressed: () async {
                try {
                  await LoginGoogleUtils().signInWithGoogle();
                  //if is there a currentUser signed, we will go to the root
                  if (FirebaseAuth.instance.currentUser != null) {
                    if (context.mounted) {
                      context.go("/Root");
                    }
                  }
                } catch (e) {
                  debugPrint("$e");
                }
              },
            ),
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Ya tienes cuenta?'),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Ingresa aquí'),
              ),
            ],
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  bool areFieldsValid() {
    if (username.text.isEmpty) {
      showSnackBar(context, 'Por favor, ingresa tu nombre');
      return false;
    }
    if (email.text.isEmpty) {
      showSnackBar(context, 'Por favor, ingresa tu correo');
      return false;
    }
    if (password.text.isEmpty) {
      showSnackBar(context, 'Por favor, ingresa tu contraseña');
      return false;
    }
    if (confirmPassword.text.isEmpty) {
      showSnackBar(context, 'Por favor, repite tu contraseña');
      return false;
    }
    if (password.text != confirmPassword.text) {
      showSnackBar(context, 'Las contraseñas no coinciden');
      return false;
    }
    return true;

  }
}
