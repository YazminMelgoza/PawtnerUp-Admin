import 'package:pawtnerup_admin/model/shelter_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ShelterRepository {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List> getUser(String? email) async {
    List user = [];
    CollectionReference collectionReferenceUser = db.collection('users');

    QuerySnapshot queryUser =
        await collectionReferenceUser.where("email", isEqualTo: email).get();

    for (var documento in queryUser.docs) {
      user.add(documento.data());
    }

    return user;
  }

  Future<void> addShelter(ShelterModel shelter) async {
    db.collection("shelters").doc(shelter.uid).set({
      "name": shelter.name,
      "email": shelter.email,
      "uid": shelter.uid,
      "address": shelter.address,
      "phone": shelter.phone,
      "description": shelter.description,
      "image": shelter.image,
      "latitude": shelter.latitude,
      "longitude": shelter.longitude,
    });
  }
}
