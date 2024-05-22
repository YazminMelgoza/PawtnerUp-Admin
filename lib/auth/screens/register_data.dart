import 'dart:io';
import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:pawtnerup_admin/services/firebase_service.dart';
import 'package:pawtnerup_admin/shared/shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pawtnerup_admin/utils/pick_image.dart';
import 'package:pawtnerup_admin/utils/show_snack_bar.dart';
import 'package:pawtnerup_admin/services/user_service.dart';

import 'address_input.dart';

class RegisterData extends StatelessWidget {
  final String email;
  final String username;
  final String password;
  final File? image;

  const RegisterData({
    Key? key,
    required this.email,
    required this.username,
    required this.password,
     required this.image,
  }) : super(key: key);

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
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  Container(
                    color: Colors.transparent,
                    child: Text(
                      'Registra la informacion de tu refugio',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColor.blue,
                          fontSize: 30,

                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit'),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 260,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                      ),
                    ),
                    child: _RegisterForm(
                      email: email,
                      username: username,
                      password: password,
                      image: image,
                    ),
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
  final String email;
  final String username;
  final String password;
  final File? image;

  const _RegisterForm({
    Key? key,
    required this.email,
    required this.username,
    required this.password,
    required this.image,
  }) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final phone = TextEditingController();
  final website = TextEditingController();
  final adoptionFormURL = TextEditingController();

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          const SizedBox(height: 2),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'Numero celular',
            keyboardType: TextInputType.phone,
            controller: phone,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'URL de Pagina Web',
            keyboardType: TextInputType.url,
            controller: website,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'URL del forms de adopcion',
            keyboardType: TextInputType.url,
            controller: adoptionFormURL,
          ),
          const SizedBox(height: 15),

          Column(
          children: [
            SizedBox(
              height: 55, // Define a fixed height for the AddressInput
              child:  FutureBuilder(
              future: _getPosition(),
              builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
              child: CircularProgressIndicator(),
              );
              } else {
              if (snapshot.hasData) {
              return Example(snapshot.data!);
              } else {
    return const Center(
    child: Text('Location not found!'),
    );
    }}}),),

            const SizedBox(height: 15), // Space after AddressInput
          ],
        ), // Add the address input widget here
          const SizedBox(height: 20),
          // Button to create user using email and password
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
                    widget.username,
                    widget.email,
                    widget.password,
                    widget.image,
                  );
                  if (context.mounted) context.go("/Root");
                } catch (e) {
                  if (context.mounted) showSnackBar(context, e.toString());
                }
              },
            ),
          ),
          // Login with Google Button
          /*
          SizedBox(
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
          ),
          */
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
    if (phone.text.isEmpty || website.text.isEmpty || adoptionFormURL.text.isEmpty) {
      showSnackBar(context, 'Por favor, completa todos los campos');
      return false;
    }
    return true;
  }
}
    Future<LatLng> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
    throw 'Location services are disabled';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
    throw 'Location permissions are denied';
    }
    }

    if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
    }
