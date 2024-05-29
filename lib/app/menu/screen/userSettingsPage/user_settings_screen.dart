import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pawtnerup_admin/models/shelter_model.dart';
import 'package:pawtnerup_admin/services/shelter_service.dart';
import 'package:pawtnerup_admin/shared/shared.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Utils for Google Login
import 'package:pawtnerup_admin/utils/login_google_utils.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';
import 'edit_screen.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle( color: Colors.white, fontFamily: 'outfit')),
        backgroundColor: Color.fromRGBO(255, 141, 0, 100),
        actions: [
          IconButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                String userId = user.uid;
                ShelterModel? shelter = await ShelterService().getShelterById(userId);
                if (shelter != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditScreen(shelter: shelter),
                    ),
                  );
                }
              }

            },
            icon: const Icon(Icons.edit, color: Colors.white,),


          )],
        toolbarHeight: 35.0, // Adjust toolbar height if necessary
      ),
      body: const _UserSettingsView(),
    );
  }
}

class _UserSettingsView extends StatefulWidget {
  const _UserSettingsView();

  @override
  __UserSettingsState createState() => __UserSettingsState();
}

class __UserSettingsState extends State<_UserSettingsView> {
  String getuid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      return userId;
    } else {
      return '';
    }
  }

  Future<ShelterModel?> getShelter() {
    return ShelterService().getShelterById(getuid());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      body: FutureBuilder(
        future: Future.wait(
            [LoginGoogleUtils().isUserLoggedIn(), getShelter()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              String userId = user.uid;
              print('User ID: $userId');
            } else {
              print('User ID: ');
            }
            const radius = Radius.circular(10);
            String? email = FirebaseAuth.instance.currentUser?.email;
            String? name = FirebaseAuth.instance.currentUser?.displayName;
            ShelterModel? shelter = snapshot.data?[1] as ShelterModel?;
            String? profilePhoto = shelter?.imageURL;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProfileImage(profilePhoto.toString()),
                        if (shelter != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            shelter.name,
                            style: const TextStyle(
                                color: Color.fromRGBO(255, 141, 0, 100),
                                fontFamily: 'outfit',
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: AppColor.yellow,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  shelter.address,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          _buildDescriptionCard(shelter.description),
                        ],
                        const SizedBox(height: 5),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Correo Electronico",
                          style: TextStyle(
                              fontFamily: 'outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
          const Text(
          "Link de Adopcion",
          style: TextStyle(
          fontFamily: 'outfit',
          fontSize: 16,
          fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
          shelter?.adoptionFormURL ?? 'Actualmente no hay link de adopcion',
          style: const TextStyle(
          fontFamily: 'outfit',
          fontSize: 16,
          fontWeight: FontWeight.w300),
          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sitio Web/Link de Adopcion",
                          style: TextStyle(
                              fontFamily: 'outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          shelter?.adoptionFormURL ?? 'No website available',
                          style: const TextStyle(
                              fontFamily: 'outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(70, 0, 15, 25),
                    child: Container(

                      width: 253, // Set the desired width here
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 141, 0, 100),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              // Define your radius value
                              bottomRight: Radius.circular(8.0),
                              topLeft: Radius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await LoginGoogleUtils().signOutGoogle();
                          await LoginGoogleUtils().singOutWithEmail();
                          if (FirebaseAuth.instance.currentUser == null) {
                            if (context.mounted) {
                              context.go("/login");
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 6),
                            // Espacio entre el icono y el texto
                            Text("Cerrar Sesion"),
                          ],
                        ),
                      ),
                    ),),
                ],),);
          }
        },
      ),
    );
  }

  Widget _buildProfileImage(String url) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.yellow,
          width: 4.0,
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            url == 'null'
                ? 'https://cdn-icons-png.flaticon.com/512/3541/3541871.png'
                : url,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(String? description) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        description ?? 'No description available',
        style: const TextStyle(
          fontSize: 15.0,
        ),
      ),
    );
  }
}