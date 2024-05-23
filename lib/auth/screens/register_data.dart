import 'dart:io';
import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:pawtnerup_admin/services/firebase_service.dart';
import 'package:pawtnerup_admin/services/shelter_service.dart';
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
  final descripcion = TextEditingController();
  final adoptionFormURL = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Address? selectedAddress; // Add this line
  Coords? selectedCoords; // Add this line
  late final String reference;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(40));

    const borderRadius = Radius.circular(15);
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
            keyboardType: TextInputType.text,
            controller: website,
          ),
          const SizedBox(height: 15),
          CustomTextFormField(
            label: 'URL del forms de adopcion',
            keyboardType: TextInputType.text,
            controller: adoptionFormURL,
          ),
          const SizedBox(height: 15),
          Column(
            children: [
              SizedBox(
                height: 55,
                child: Example(
                  onAddressSelected: (Address address) {
                    setState(() {
                      selectedAddress = address;
                      selectedCoords = GiveAddress(address);
                      reference = address.reference!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 15),
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: borderRadius,
                bottomLeft: borderRadius,
                bottomRight: borderRadius),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ]),
        height: 100.0,
        child: TextFormField(
          controller: descripcion, // Utilizar controller
          keyboardType: TextInputType.multiline, // Allow multiple lines
          maxLines: null, // No limit on lines (optional)
          style: const TextStyle(fontSize: 16, color: Colors.black54),
          decoration: InputDecoration(
            floatingLabelStyle: const TextStyle(
              color: AppColor.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            enabledBorder: border,
            focusedBorder: border,
            errorBorder: border.copyWith(
                borderSide: BorderSide(color: Colors.red.shade800)),
            focusedErrorBorder: border.copyWith(
                borderSide: BorderSide(color: Colors.red.shade800)),
            isDense: true,
            hintText: "Descripcion",
            focusColor: colors.primary,
          ),
        ),
      )
              /*if (selectedAddress != null) ...[
                Text('Selected Address: ${selectedAddress!.toString()}'), // Update this line
                if (selectedCoords != null)
                  Text('Coordinates: ${selectedCoords!.latitude}, ${selectedCoords!.longitude}'),
              ],*/
            ],
          ),
          const SizedBox(height: 20),
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
                  await ShelterService().createUser(
                    phone.text,
                    reference,
                    selectedCoords?.latitude,
                    selectedCoords?.longitude,
                    descripcion.text,
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

Coords? GiveAddress(Address shelterAddress) {
  return shelterAddress.coords;
}



