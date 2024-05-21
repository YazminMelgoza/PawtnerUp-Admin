import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pawtnerup_admin/models/user_model.dart'; // Asegúrate de importar el modelo aquí

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obtener un usuario por su UID
  Future<UserModel?> getUserByUid(String uid) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      return UserModel.fromFirebase(userSnapshot);
    } else {
      return null;
    }
  }

  Future<UserModel> createUser(String username, String email, String password, File? image) async {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    UserModel user = UserModel(
      uid: userCredential.user!.uid,
      name: username,
      email: email,
      profilePicURL: image != null ? await uploadProfilePic(image, userCredential.user!.uid) : null,
    );
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  Future<String> uploadProfilePic(File image, String uid) async {
    String fileName = 'profile_pics/$uid';
    await FirebaseStorage.instance.ref(fileName).putFile(image);
    return await FirebaseStorage.instance.ref(fileName).getDownloadURL();
  }

  Future<UserModel?> getUserByEmail(String email) async {
    QuerySnapshot userSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (userSnapshot.docs.isNotEmpty) {
      return UserModel.fromFirebase(userSnapshot.docs.first);
    } else {
      return null;
    }
  }

  Future<void> updateUser(context, UserModel user) async {
    var partialUser = user.toMap();
    partialUser.remove('uid');
    // Actualizamos los datos del usuario en Firestore
    await _firestore.collection('users').doc(user.uid).update(partialUser);
  }
}
