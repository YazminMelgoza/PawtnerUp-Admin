// import 'package:pawtnerup_admin/Json/users.dart';
// import 'package:pawtnerup_admin/auth/db/sqlite.dart';
import 'package:pawtnerup_admin/auth/screens/register_data.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pawtnerup_admin/shared/shared.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pawtnerup_admin/utils/pick_image.dart';
import 'package:pawtnerup_admin/utils/snackbar.dart';
import 'dart:io';

// RegisterScreen

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
                  const SizedBox(height: 255),
                  Container(
                    color: Colors.transparent,
                    child: Text(
                      'Registra tu refugio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColor.blue, fontWeight: FontWeight.bold, fontFamily: 'Outfit'
                      ),
                    ),
                  ),                  Container(
                    height: MediaQuery.of(context).size.height - 300,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
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
          const SizedBox(height: 0),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterData(
                      email: email.text,
                      username: username.text,
                      password: password.text,
                      image: image,
                    ),
                  ),
                );

                }
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
    if (image == null) {
      showSnackbar(context, 'Por favor, selecciona una imagen');
      return false;
    }
    if (username.text.isEmpty) {
      showSnackbar(context, 'Por favor, ingresa tu nombre');
      return false;
    }
    if (email.text.isEmpty) {
      showSnackbar(context, 'Por favor, ingresa tu correo');
      return false;
    }
    if (password.text.isEmpty) {
      showSnackbar(context, 'Por favor, ingresa tu contraseña');
      return false;
    }
    if (confirmPassword.text.isEmpty) {
      showSnackbar(context, 'Por favor, repite tu contraseña');
      return false;
    }
    if (password.text != confirmPassword.text) {
      showSnackbar(context, 'Las contraseñas no coinciden');
      return false;
    }
    return true;

  }
}
