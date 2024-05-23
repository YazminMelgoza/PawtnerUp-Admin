// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:pawtnerup_admin/app/utils/data.dart';
// import 'package:pawtnerup_admin/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:pawtnerup_admin/models/shelter_model.dart';
import 'package:pawtnerup_admin/services/shelter_service.dart';
import 'package:pawtnerup_admin/shared/shared.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
//Utils for Google Login
import 'package:pawtnerup_admin/utils/login_google_utils.dart';

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil ', style: TextStyle(fontFamily: 'outfit'),),
        backgroundColor: AppColor.yellow,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColor.appBarColor,
            pinned: true,
            snap: true,
            floating: true,
            title: _buildAppBar(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBody(),
              childCount: 1,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    SizedBox(
                      height: 10,
                      width: 5,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: Future.wait([LoginGoogleUtils().isUserLoggedIn(), getShelter()]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            String userId = user.uid;
            print('User ID: $userId');
          } else {
            print('User ID: ');
          }
          String? email = FirebaseAuth.instance.currentUser?.email;
          String? name = FirebaseAuth.instance.currentUser?.displayName;
          ShelterModel? shelter = snapshot.data?[1] as ShelterModel?;
          String? profilePhoto = shelter?.imageURL;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(name.toString()),
                  colocarImagen(profilePhoto.toString()),
                  Text(email.toString()),
                  if (shelter != null) ...[
                    Text('Shelter Info:'),
                    Text('Name: ${shelter.name}'),
                    Text('Location: ${shelter.address}'),
                    // Add more fields as needed
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
                    child: CustomFilledButton(
                      text: "Cerrar Sesión",
                      buttonColor: AppColor.darker,
                      onPressed: () async {
                        await LoginGoogleUtils().signOutGoogle();
                        await LoginGoogleUtils().singOutWithEmail();
                        if (FirebaseAuth.instance.currentUser == null) {
                          if (context.mounted) {
                            context.go("/login");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}


colocarImagen(String url) {
  if (url == 'null') {
    return Image.network(
      'https://cdn-icons-png.flaticon.com/512/3541/3541871.png',
      width: 100,
      height: 100,
    );
  } else {
    return Image.network(
      url,
      width: 100,
      height: 100,
    );
  }
}