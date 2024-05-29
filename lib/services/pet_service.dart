import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:pawtnerup_admin/models/pet_model.dart";

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obtener una mascota por su ID
  Future<PetModel?> getPetById(String petId) async {
    DocumentSnapshot petSnapshot =
        await _firestore.collection('pets').doc(petId).get();

    if (petSnapshot.exists) {
      return PetModel.fromFirebase(petSnapshot);
    } else {
      return null;
    }
  }

  Future<List<PetModel>> getPetsByShelterId(String shelterId) async {
    QuerySnapshot petsSnapshot = await _firestore.collection('pets').where('shelterId', isEqualTo: shelterId).get();
    return petsSnapshot.docs.map((doc) => PetModel.fromFirebase(doc)).toList();
  }
  Stream<List<PetModel>> getPetsStreamByShelterId(String shelterId) {
    return _firestore
        .collection('pets')
        .where('shelterId', isEqualTo: shelterId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PetModel.fromMap(doc.data()))
        .toList());
  }

  Future<String> uploadProfilePic(File image, String uid) async {
    String fileName = 'profile_pics/$uid';
    await FirebaseStorage.instance.ref(fileName).putFile(image);
    return await FirebaseStorage.instance.ref(fileName).getDownloadURL();
  }
  Future<String> uploadPetPic(File image, String uid) async {
    String fileName = 'pet_pics/'+Timestamp.now().millisecondsSinceEpoch.toString();
    await FirebaseStorage.instance.ref(fileName).putFile(image);
    return await FirebaseStorage.instance.ref(fileName).getDownloadURL();
  }
  // Método para agregar una nueva mascota
  Future<void> addPet(PetModel pet) async {
    DocumentReference docRef = await _firestore.collection('pets').add(pet.toMap());
    String docId = docRef.id;
    pet.id = docId;
    await docRef.update({'id': docId});
  }

  // Método para actualizar la información de una mascota
  Future<void> updatePet(PetModel pet) async {
    await _firestore.collection('pets').doc(pet.id).update(pet.toMap());
  }

  // Método para eliminar una mascota
  Future<void> deletePet(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }

  Future<List<PetModel>> getAllPets() async {
    QuerySnapshot petsSnapshot = await _firestore.collection('pets').get();
    return petsSnapshot.docs.map((doc) => PetModel.fromFirebase(doc)).toList();
  }

  // Método para buscar las mascotas de acuerdo a la cercanía a una ubicación
  Future<List<PetModel>> getPetsNearby(double latitude, double longitude, double radius) async {
    // Calcular los límites del cuadrado que contiene el círculo
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;

    double lowerLat = latitude - (lat * radius);
    double lowerLon = longitude - (lon * radius);

    double greaterLat = latitude + (lat * radius);
    double greaterLon = longitude + (lon * radius);

    // Realizar la consulta de los refugios cercanos
    QuerySnapshot sheltersSnapshot = await _firestore.collection('shelters')
        .where('latitude', isGreaterThan: lowerLat)
        .where('latitude', isLessThan: greaterLat)
        .where('longitude', isGreaterThan: lowerLon)
        .where('longitude', isLessThan: greaterLon)
        .get();

    // Obtener los IDs de los refugios cercanos
    List<String> shelterIds = sheltersSnapshot.docs.map((doc) => doc.id).toList();

    // Realizar la consulta de las mascotas que pertenecen a los refugios cercanos
    QuerySnapshot petsSnapshot = await _firestore.collection('pets')
        .where('shelterId', whereIn: shelterIds)
        .get();

    if (petsSnapshot.docs.isEmpty) return [];
    return petsSnapshot.docs.map((doc) => PetModel.fromFirebase(doc)).toList();
  }

  // Método para obtener las mascotas adoptadas
  Future<List<PetModel>> getAdoptedPets() async {
    QuerySnapshot petsSnapshot = await _firestore.collection('pets').where('adoptionStatus', isEqualTo: 'adopted').get();
    return petsSnapshot.docs.map((doc) => PetModel.fromFirebase(doc)).toList();
  }

  // Método para obtener todas las mascotas disponibles
  Future<List<PetModel>> getAvailablePets() async {
    QuerySnapshot petsSnapshot = await _firestore.collection('pets').where('adoptionStatus', isEqualTo: 'available').get();
    return petsSnapshot.docs.map((doc) => PetModel.fromFirebase(doc)).toList();
  }

  // Método para cancelar la adopción de una mascota
  Future<void> cancelAdoption(String petId) async {
    await _firestore.collection('pets').doc(petId).update({
      'adoptionStatus': 'available',
    });
  }

  // Método para adoptar una mascota
  Future<void> adoptPet(String petId) async {
    await _firestore.collection('pets').doc(petId).update({
      'adoptionStatus': 'adopted',
    });
  }

  // Método para archivar una mascota
  Future<void> archivePet(String petId) async {
    await _firestore.collection('pets').doc(petId).update({
      'adoptionStatus': 'archived',
    });
  }


}
