import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawtnerup_admin/models/shelter_model.dart'; 
import 'package:pawtnerup_admin/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ShelterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obtener un refugio por su ID
  Future<ShelterModel?> getShelterById(String shelterId) async {
      DocumentSnapshot shelterSnapshot =
          await _firestore.collection('shelters').doc(shelterId).get();

      if (shelterSnapshot.exists) {
        return ShelterModel.fromFirebase(shelterSnapshot);
      } else {
        return null;
      }
  }

  // Método para agregar un nuevo refugio
  Future<String> addShelter(ShelterModel shelter) async {
    DocumentReference docRef = await _firestore.collection('shelters').add(shelter.toMap());
    // update the shelter with the id
    await _firestore.collection('shelters').doc(docRef.id).update({
      'uid': docRef.id,
    });
    return docRef.id;
  }

  Future<void> signInShelter(context, String email, String password) async {
    ShelterModel? user = await getUserByEmail(email);
    if (user == null) throw 'Datos incorrectos o usuario no encontrado.';
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    Provider.of<AuthenticationProvider>(context, listen: false).user = user;
  }

  Future<String> uploadProfilePic(File image, String uid) async {
    String fileName = 'profile_pics/$uid';
    await FirebaseStorage.instance.ref(fileName).putFile(image);
    return await FirebaseStorage.instance.ref(fileName).getDownloadURL();
  }

  Future<ShelterModel> createUser(String username, String email, String password, File image) async {
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  ShelterModel user = ShelterModel(
    uid: userCredential.user!.uid,
    name: username,
    email: email,
    phone: '',
    address: '',
    latitude: 0,
    longitude: 0,
    description: '',
    imageURL: await uploadProfilePic(image, userCredential.user!.uid),
  );
  await _firestore.collection('users').doc(user.uid).set(user.toMap());
  return user;
  }

  Future<void> signOutShelter(context) async {
    await FirebaseAuth.instance.signOut();
    Provider.of<AuthenticationProvider>(context, listen: false).removeUser();
  }

  // Método para obtener un refugio por su email
  Future<ShelterModel?> getUserByEmail(String email) async {
    QuerySnapshot userSnapshot = await _firestore
        .collection('shelters')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      return ShelterModel.fromFirebase(userSnapshot.docs.first);
    } else {
      return null;
    }
  }

  Future<bool> setShelterInProvider(context, User user) async {
    ShelterModel? shelter = await getUserByEmail(user.email!);
    if (shelter != null) {
      return true;
    }
    return false;

  }
  // Método para actualizar la información de un refugio
  Future<void> updateShelter(ShelterModel shelter) async {
    await _firestore.collection('shelters').doc(shelter.uid).update(shelter.toMap());
  }

  // Método para eliminar un refugio
  Future<void> deleteShelter(String shelterId) async {
    await _firestore.collection('shelters').doc(shelterId).delete();
  }

  // Metodo para obtener todos los refugios
  Future<List<ShelterModel>> getAllShelters() async {
    QuerySnapshot sheltersSnapshot = await _firestore.collection('shelters').get();
    return sheltersSnapshot.docs.map((doc) => ShelterModel.fromFirebase(doc)).toList();
  }

  // Método para buscar los refugios de acuerdo a la cercanía a una ubicación
  Future<List<ShelterModel>> getSheltersNearby(double latitude, double longitude, double radius) async {
    // Calcular los límites del cuadrado que contiene el círculo
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;

    double lowerLat = latitude - (lat * radius);
    double lowerLon = longitude - (lon * radius);

    double greaterLat = latitude + (lat * radius);
    double greaterLon = longitude + (lon * radius);

    // Realizar la consulta
    QuerySnapshot sheltersSnapshot = await _firestore.collection('shelters')
        .where('latitude', isGreaterThan: lowerLat)
        .where('latitude', isLessThan: greaterLat)
        .where('longitude', isGreaterThan: lowerLon)
        .where('longitude', isLessThan: greaterLon)
        .get();

    if (sheltersSnapshot.docs.isEmpty) {
      return [];
    }
    return sheltersSnapshot.docs.map((doc) => ShelterModel.fromFirebase(doc)).toList();
  }
}
