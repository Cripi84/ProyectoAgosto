import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//TOAST ES UNA LIBRERIA PARA MOSTRAR MENSAJES QUE APARECEN Y DESAPARACENE
//EJEMPLO LOS DE INICIO DE SESION
void showToast({required String message}){
  Fluttertoast.showToast(
      msg: message, //AQUI LE DECIMOS QUE EL MENSAJE VA A SER TIPO STRING
      toastLength: Toast.LENGTH_SHORT, //LA DURACION QUE VA A SER CORTA
      gravity: ToastGravity.BOTTOM, //QUE EL MENSAJE APAREZCA ABAJO
      timeInSecForIosWeb: 1, //CUANDO TIEMPO VA A APARECER EN PANTALLA
      backgroundColor: Colors.blue, //COLOR DE BRACKGROUND
      textColor: Colors.white, //COLOR DE LA LETRA
      fontSize: 16.0 //TAMAÑO DE LA LETRA
  );
}