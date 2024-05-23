// import 'package:pawtnerup_admin/Json/users.dart';
// import 'package:pawtnerup_admin/auth/db/sqlite.dart';
import 'package:pawtnerup_admin/auth/screens/register_data.dart';
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

class AddPet extends StatelessWidget {
  const AddPet({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo con tus mascotas

            // Imagen de mascota sin fondo posicionada estratégicamen
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Container(
                    height: MediaQuery.of(context).size.height - 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                      ),
                    ),
                    child: const _AddPet(),
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


class _AddPet extends StatefulWidget {
  const _AddPet();

  @override
  _AddPetState createState() => _AddPetState();
}

class _AddPetState extends State<_AddPet> {
  final name  = TextEditingController();
  final raza = TextEditingController();
  final edad = TextEditingController();
  final sexo = TextEditingController();
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
            label: 'Nombre',
            keyboardType: TextInputType.emailAddress,
            controller: name,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Raza',
            keyboardType: TextInputType.emailAddress,
            controller: raza,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Edad',
            obscureText: true,
            controller: edad,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Sexo',
            obscureText: true,
            controller: sexo,
          ),
          const SizedBox(height: 20),
          //Button to create user using email and password


          /*SizedBox(
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
          ),*/
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

          const Spacer(flex: 1),
        ],
      ),
    );
  }

  bool areFieldsValid() {
    if (name.text.isEmpty) {
      showSnackBar(context, 'Por favor, ingresa tu nombre');
      return false;
    }
    if (edad.text.isEmpty) {
      showSnackBar(context, 'Por favor, ingresa tu correo');
      return false;
    }
    if (raza.text.isEmpty) {
      showSnackBar(context, 'Por favor, ingresa tu contraseña');
      return false;
    }
    if (sexo.text.isEmpty) {
      showSnackBar(context, 'Por favor, repite tu contraseña');
      return false;
    }

    return true;

  }
}

