


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowers_EA/toast.dart';


class FirebaseAuthService {
//CREAMOS UNA INSTACION DE FIREBASE AUTH
//FIREBASE AUTH SE USA PARA SABER SI EL USUARIO ESTA EN LA BD Y PASA TODOS LOS PARAMETROS YA LO TRAE FIREBASE
  FirebaseAuth _auth = FirebaseAuth.instance;


  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      //AQUI VERIFICAMOS EL EMAIL ES UN EMAIL Y SI EL PASSWORD ES PASSWORD 
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {

//CAPTURAMOS EL SI TIRA ALGUNA EXCEPCION DE FIREBASE 
//AQUI SOLO TENEMOS SI YA ESTA EN USO O SI ES ALGUN OTRO ERROR
      if (e.code == 'El email ya esta en uso') {
        showToast(message: 'Este email ya esta tomado usa otro tramposo.');
      } else {
        showToast(message: 'Ocurrio un Error: ${e.code}');
      }
    }
    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      //AQUI VERIFICAMOS SI LAS CREDENCIALES SON CORRECTAS Y ESTAN LA BD 
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      //LE DECIMOS AL USUARIO CUAL ES SU ERROR SI CONTRASEÑA O EMAIL MALO
      if (e.code == 'Email no Encontrado' || e.code == 'Contraseña Incorrecta') {
        showToast(message: 'Email o Contraseña Invalida');
      } else {
        showToast(message: 'Ocurrio un error: ${e.code}');
      }

    }
    return null;

  }




}

