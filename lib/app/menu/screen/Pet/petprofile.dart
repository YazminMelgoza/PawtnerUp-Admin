import 'dart:ui';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/color.dart';
import '../../../../models/chat_model.dart';
import '../../../../models/pet_model.dart';
import '../../../../models/shelter_model.dart';
import '../../../../provider/location_provider.dart';
import '../../../../services/chat_service.dart';
import '../../../../services/pet_service.dart';
import '../../../../services/shelter_service.dart';
import '../../../../shared/widgets/custom_image.dart';
import '../../../../utils/location_utils.dart';
import '../chat/chat.dart';
import '../chat/chat_detail.dart';
import 'edit_pet.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PetProfilePage extends StatefulWidget {
  final PetModel pet;
  const PetProfilePage({super.key, required this.pet});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    String imgFondo = widget.pet.imageURLs[0];
    int providerBool = 0;
    double prueba = 0;
    //Comprueba si se puede acceder el provider, es decir, si sí se puede usar el gps.
    LocationProvider lp = Provider.of<LocationProvider>(context, listen: false);
    try {
      prueba = lp.location!.ubicacion!.latitude;
      providerBool = 3;
    } catch (e) {
      providerBool = 2;
    }
    return FutureBuilder<ShelterModel?>(
      future: ShelterService().getShelterById(widget.pet.shelterId),
      builder: (context, AsyncSnapshot<ShelterModel?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          var shelter = snapshot.data!;
          String colorsString = widget.pet.colors.join(',');
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/fondoblue.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(children: [
                      PageView.builder(
                        itemCount: widget.pet.imageURLs.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Image.network(
                                      widget.pet.imageURLs[index],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image.network(
                              widget.pet.imageURLs[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 40,
                        left: 15,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.white,
                        ),
                      ),
                    ]),
                  ),
                  //Info de la mascota
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Primer elemento (3/4 del espacio)
                            Expanded(
                              flex: 4, // 3 partes de 4
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pet.name ,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8D00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Segundo elemento (1/4 del espacio)
                            Expanded(
                              flex: 2, // 1 parte de 4
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on, // Icono de ubicación
                                    color: Color(0xFFFF8D00),
                                  ),
                                  Text(
                                    (providerBool == 3)
                                        ? LocationUtils().calcularKilometros(shelter.latitude!, shelter.longitude!, lp.location!.ubicacion!.latitude, lp.location!.ubicacion!.longitude)
                                        : "NA" ,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFBC00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildInfoContainer(
                                label: 'Edad',
                                value:
                                '${widget.pet.ageInYears ?? 'Unknown Age'} años',
                              ),

                              const SizedBox(width: 20),
                              _buildInfoContainer(
                                label: 'Sexo',
                                value: widget.pet.sex,
                              ),
                              const SizedBox(width: 20),
                              _buildInfoContainer(
                                label: 'Tamaño',
                                value: widget.pet.size,
                              ),
                              const SizedBox(width: 20),
                              _buildInfoContainer(
                                label: 'Raza',
                                value: widget.pet.breed,
                              ),
                              const SizedBox(width: 20),
                              _buildInfoContainerColor(
                                label: 'Color',
                                value: colorsString,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Descripción",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.pet.story!,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Ubicación",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              shelter.address,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Características",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                            Wrap(
                              children: widget.pet.features.map((feature) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10, bottom: 0),
                                  child: ChoiceChip(
                                    label: Text(
                                      feature,
                                      style: const TextStyle(
                                        color: Color(0xFF084065),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    selected: false,
                                    onSelected: null,
                                    side: const BorderSide(
                                      color: Color(0xFF084065),
                                      width: 1,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //Info del refugio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {

                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomImage(
                                      shelter.imageURL,
                                      borderRadius: BorderRadius.circular(50),
                                      isShadow: true,
                                      width: 60,
                                      height: 60,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            shelter.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF084065),
                                            ),
                                          ),
                                          const Text(
                                            "Ver Perfil",
                                            style: TextStyle(
                                              fontSize: 16, // Tamaño de letra 16
                                              color: Colors.blue, // Color azul
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        SizedBox(
                          width: double.infinity,
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                              onTap: (){},
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn,
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                                margin: const EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * .4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (widget.pet.adoptionStatus=="available")? Color(0xFFFFF5D6):AppColor.cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color(0xFFFFBC00),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.shadowColor.withOpacity(0.1),
                                      spreadRadius: .5,
                                      blurRadius: .5,
                                      offset: const Offset(0, 1), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20,),
                                    SvgPicture.asset(
                                      'assets/images/disponible.svg',
                                      width: 30, // Ancho deseado
                                      height: 20, // Altura deseada
                                    ),
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: Text(
                                        "Disponible",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color:  Color(0xFFFF8D00) ,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ),
                              GestureDetector(
                                  onTap: () async
                                  {
                                    if(widget.pet.adoptionStatus!="available"){return;}
                                    // Mostrar el diálogo de confirmación
                                    bool confirmado = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Confirmar Adopción"),
                                          content: Text("¿Estás seguro de que deseas marcar como adoptado a esta mascota y cancelar todos los chats en proceso?, esta acción es irreversible"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(false); // Indica que la acción no fue confirmada
                                              },
                                              child: Text("Cancelar"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true); // Indica que la acción fue confirmada
                                              },
                                              child: Text("Aceptar"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if(confirmado==false){return;}
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 20),
                                              Text("Procesando Adopción..."),
                                            ],
                                          ),
                                        );
                                      },
                                      barrierDismissible: false,
                                    );
                                    try {
                                      await PetService().adoptPet(widget.pet.id);
                                      await ChatService().cancelAllChatsById(widget.pet.id);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }catch (error) {
                                      Navigator.pop(context);
                                      print(error);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Ha ocurrido un error inesperado. Inténtalo de nuevo más tarde.",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      );
                                    }


                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn,
                                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                                    margin: const EdgeInsets.only(right: 10),
                                    width: MediaQuery.of(context).size.width * .4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: (widget.pet.adoptionStatus=="adopted")? Color(0xFFFFF5D6):AppColor.cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Color(0xFFFFBC00),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.shadowColor.withOpacity(0.1),
                                          spreadRadius: .5,
                                          blurRadius: .5,
                                          offset: const Offset(0, 1), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 20,),
                                        SvgPicture.asset(
                                          'assets/images/adoptado.svg',
                                          width: 30, // Ancho deseado
                                          height: 20, // Altura deseada
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Text(
                                            "Adoptado",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color:  Color(0xFFFF8D00) ,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ),

                          ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        SizedBox(
                          width: double.infinity,
                          child:(widget.pet.adoptionStatus=="available")? ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditPet(
                                          pet: widget.pet
                                      )
                                  )
                              );
                            },
                            icon: const Icon(
                              Icons.insert_drive_file,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Editar información',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8D00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                          ):Container(),
                        ),
                      ],
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

  void goToChat(
      {required BuildContext context,
        required ChatService chatService,
        required ShelterModel shelter,
        required PetModel pet,
        required User user}) async {
    ChatModel? chatRoom = await _chatService.checkChat(
        FirebaseAuth.instance.currentUser!.uid, pet.shelterId, pet.id);

    if (chatRoom != null && context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatDetailPage(chatData: chatRoom!)));
    } else {
      User user = FirebaseAuth.instance.currentUser!;
      chatRoom = ChatModel(
        id: '',
        userId: user.uid,
        userImageURL: user.photoURL ?? '',
        userName: user.displayName ?? '',
        shelterImageURL: shelter.imageURL,
        shelterName: shelter.name,
        shelterId: pet.shelterId,
        petId: pet.id,
        petName: pet.name,
        petImageURL: pet.imageURLs[0],
        recentMessageContent: null,
        recentMessageTime: null,
        recentMessageSenderId: null,
        conversationStatus: 'En Proceso',
      );

      DocumentReference newChatDoc = await _chatService.createChat(chatRoom);
      chatRoom.id = newChatDoc.id;
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatDetailPage(chatData: chatRoom!)));
      }
    }
  }

  Widget _buildInfoContainerColor(
      {required String label, required String value}) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.32),
        borderRadius: BorderRadius.circular(7.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            offset: const Offset(2.0, 2.0),
            blurRadius: 4.0,
            spreadRadius: 0.0,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10.0), // Espacio más grande entre los textos
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFBC00),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer({required String label, required String value}) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.32),
        borderRadius: BorderRadius.circular(7.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            offset: const Offset(2.0, 2.0),
            blurRadius: 4.0,
            spreadRadius: 0.0,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10.0), // Espacio más grande entre los textos
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFBC00),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
