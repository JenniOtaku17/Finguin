
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_repository/src/auth_repository.dart';
import 'package:transaction_repository/src/models/models.dart' as repo;

class FirebaseAuthRepository implements AuthRepository {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  FirebaseAuthRepository() {
    _auth.setPersistence(Persistence.LOCAL);
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  }

  @override
  Future<String> register(repo.User user, String password, File? photo) async{
    try{
      await logout();
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: user.email, password: password);
      
      if(userCredential.user != null){
        updateDisplayName(user.displayName);

        if(photo != null){
          updatePhotoURL(photo);
        }

      }
      return 'ok';

    }catch(error){
      return error.toString();
    }
  }

  @override
  Future<String> login(String email, String password) async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if(userCredential.user != null){

        repo.User user = repo.User.empty;
        user.uid = userCredential.user!.uid;
        user.displayName = userCredential.user!.displayName.toString();
        user.email = userCredential.user!.email.toString();
        user.photoURL = userCredential.user!.photoURL.toString();
        localStorage.setItem('user', jsonEncode(user.toJson()));
        print('user saved');
      }
      return 'ok';

    }catch( error ){
      return error.toString();
    }
  }

  @override
  Future<bool> logout() async{
    try{
      await _auth.signOut();
      localStorage.removeItem('user');
      return true;

    }catch( error ){
      return false;
    }
  }

  @override
  Future<repo.User> getCurrentUser() async{
    try{
      final user = await _auth.currentUser;

      if (user != null) {

        repo.User myuser = repo.User.empty;
        myuser.uid = user.uid;
        myuser.displayName = user.displayName.toString();
        myuser.email = user.email.toString();
        myuser.photoURL = user.photoURL.toString();

        if (user.photoURL!.isNotEmpty) {
          final response = await http.get(Uri.parse(myuser.photoURL));
          if (response.statusCode == 200) {
            // Obtener el directorio de almacenamiento local
            Directory appDocDir = await getApplicationDocumentsDirectory();
            String appDocPath = appDocDir.path;

            // Guardar la imagen en el almacenamiento local
            File file = File('$appDocPath/profile_image.jpg');
            await file.writeAsBytes(response.bodyBytes);

            // Actualizar la ruta de la imagen en el objeto User
            myuser.photoURL = file.path;
          }
        }

        localStorage.setItem('user', jsonEncode(myuser.toJson()));
        return myuser;
        
      }else{
        return repo.User.empty;
      }

    }catch( error ){
      return repo.User.empty;
    }
  }

  @override
  Future<bool> updateDisplayName( String name ) async{
    try{
      await _auth.currentUser!.updateDisplayName(name);
      return true;

    }catch( error ){
      return false;
    }
  }

  @override
  Future<bool> updatePhotoURL( File? image ) async{
    try{
      User user = _auth.currentUser!;

      if(image != null){
        var file = File(image.path);
        final result = await firebaseStorage.ref()
          .child('users/${user.uid}/${image.path.split('/').last}')
          .putFile(file);

        await _auth.currentUser!.updatePhotoURL(await result.ref.getDownloadURL());
        return true;
      }
      return false;

    }catch( error ){
      return false;
    }
  }

  @override
  Future<String> changePassword( String password ) async{
    try{
      await _auth.currentUser!.updatePassword(password);
      return 'ok';
      
    }catch( error ){
      return error.toString();
    }
  }

  @override
  Future<String> updateProfile( String? displayName, File? image) async{
    try{

      if(displayName != ''){
        await _auth.currentUser!.updateDisplayName(displayName);
      }

      if(image != null){
        User user = _auth.currentUser!;

        var file = File(image.path);
        final result = await firebaseStorage.ref()
          .child('users/${user.uid}/${image.path.split('/').last}')
          .putFile(file);

        await _auth.currentUser!.updatePhotoURL(await result.ref.getDownloadURL());
      }

      await getCurrentUser();
      
      return 'ok';
      
    }catch( error ){
      return error.toString();
    }
  }


}