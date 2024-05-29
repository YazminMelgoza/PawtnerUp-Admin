// Debes eliminar esta importación
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//Data
import 'package:geolocator/geolocator.dart';
import '../../../config/theme/color.dart';
import '../../../models/location_model.dart';
import '../../../models/pet_model.dart';

import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/location_provider.dart';
import '../../../services/location_service.dart';
import '../../../services/pet_service.dart';
import '../../../shared/widgets/category_box.dart';
import '../../../shared/widgets/pet_item.dart';
import '../../../shared/widgets/status_box.dart';
import '../../../utils/location_utils.dart';
import '../../utils/data.dart';
import 'Pet/add_pet.dart';
import 'Pet/petprofile.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authProvider =
    Provider.of<AuthenticationProvider>(context, listen: false);
    String nameToShow = "Hola!";
    String name = "";
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        String? fullName = authProvider.user?.name;
        if (fullName != null) {
          List<String> nameParts = fullName.split(" ");
          name = nameParts.first;
        }
        nameToShow = "$nameToShow $name";
      }
    } catch (e) {
      nameToShow = "Ha ocurrido un problema, reinicia la aplicación";
    }

    return Scaffold(
     /*appBar: AppBar(
        title: Text(
          nameToShow,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFFF8D00),

      ),*/
      body: const _MenuView(),
    );
  }
}

class _MenuView extends StatefulWidget {

  const _MenuView();
  @override
  __MenuViewState createState() => __MenuViewState();
}

class __MenuViewState extends State<_MenuView> {
  //Comprueba Ubicacion
  String ubicacion = "Ubicacion Desconocida";
  Position? location = null;
  LocationProvider? lp = null;
  void obtenerYActualizarUbicacion() async {
    await LocationService().defineLocation(context);

    LocationModel loc = Provider.of<LocationProvider>(
        context,
        listen: false)
        .location!;
    String ubi = await LocationUtils().getAdressFromCoordinates(loc.ubicacion);
    setState(() {
      location = loc.ubicacion;
      ubicacion = ubi;
    });
    //Forma inicial de obtener ubicación
    //String ubi = await LocationUtils().obtenerLocalizacion();
  }

  @override
  void initState() {
    super.initState();
    obtenerYActualizarUbicacion();
  }
  List<String> sizes = ['Chiquito', 'Mediano','Grandote'];

  @override
  Widget build(BuildContext context) {


    AuthenticationProvider authProvider =
    Provider.of<AuthenticationProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(height: 40,),
          _buildAppBar(ubicacion),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  scrollDirection: Axis.horizontal,
                  child: _categoriesWidget(),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            [
              _statusWidget(),
            ],
          ),
          FutureBuilder<List<PetModel>>(
              future: PetService().getPetsByShelterId(authProvider.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No hay mascotas a mostrar'),
                  );
                } else {
                  final List<PetModel> pets = snapshot.data!;
                  List<PetModel> filteredPets     = [];
                  List<PetModel> typeFilteredPets = [];

                  if (_selectedCategory == 0) {
                    typeFilteredPets.addAll(pets);
                  } else if (_selectedCategory == 1) {
                    typeFilteredPets.addAll(pets.where((pet) => pet.type == 'dog'));
                  } else if (_selectedCategory == 2) {
                    typeFilteredPets.addAll(pets.where((pet) => pet.type == 'cat'));
                  }
                  if(_selectedStatus==0)
                  {
                    filteredPets.addAll(typeFilteredPets.where((pet) => pet.adoptionStatus == 'available'));
                  }else if(_selectedStatus==1)
                  {
                    filteredPets.addAll(typeFilteredPets.where((pet) => pet.adoptionStatus == 'adopted'));
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GridView.builder(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredPets.length,
                        itemBuilder: (context, index) {
                          return PetItem(
                            data: filteredPets[index].toMap(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetProfilePage(
                                    key: UniqueKey(),
                                    pet: filteredPets[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  int _selectedCategory = 0;
  Widget _categoriesWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        categories.length,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0),
          child: CategoryItem(
            data: categories[index],
            selected: index == _selectedCategory,
            onTap: () {
              setState(() {
                _selectedCategory = index;
              });
            },
          ),
        ),
      ),
    );
  }
  int _selectedStatus = 0;
  Widget _statusWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        listStatus.length,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0), // Espaciado vertical entre elementos
          child: StatusItem(
            data: listStatus[index],
            selected: index == _selectedStatus,
            onTap: () {
              setState(() {
                _selectedStatus = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(String location) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place,
                      color: Color(0xFFFF8D00),
                      size: 30,
                    ),
                    const SizedBox(
                      height: 10,
                      width: 5,
                    ),
                    Text(
                      location,
                      style: const TextStyle(
                        color: AppColor.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 3,
              ),
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                              [

                                Text(
                                  "Tus",
                                  style: TextStyle(
                                    color: AppColor.textColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 40,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  "mascotas",
                                  style: TextStyle(
                                    color: Color(0xFFFF8D00),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 40,
                                    height: 1.0,
                                  ),
                                ),
                              ]
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Your code here, like navigating to a new screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPet(
                                    key: UniqueKey(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Make ElevatedButton background transparent
                            ),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black, // Set button color here
                                  borderRadius: BorderRadius.circular(10.0), // Set desired corner roundness
                                  border: Border.all(color: Colors.black),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.shadowColor.withOpacity(0.1),
                                      spreadRadius: .5,
                                      blurRadius: .5,
                                      offset: const Offset(0, 1), // changes position of shadow
                                    ),
                                  ],
                                ),
                                height: 50.0,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/addpet.png',
                                  width: 30, // Establece el ancho de la imagen a 50 píxeles
                                ),

                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(height: 10),

                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
