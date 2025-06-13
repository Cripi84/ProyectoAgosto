import 'package:flowers_EA/pages/comunes/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flowers_EA/pages/comunes/proveedores.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';

class FormProvCrear extends StatefulWidget {
  const FormProvCrear({super.key});

  @override
  _FormProvCrearState createState() => _FormProvCrearState();
}

class _FormProvCrearState extends State<FormProvCrear> {
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController codigoController = TextEditingController(text: '');
  TextEditingController envioController = TextEditingController(text: '');
  TextEditingController fechaController = TextEditingController(text: '');
  TextEditingController montoMinimoController = TextEditingController(text: '');

  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Proveedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un código por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del proveedor por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: envioController,
                decoration: const InputDecoration(labelText: 'Envío en:'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese donde envía en por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: montoMinimoController,
                decoration: const InputDecoration(
                    labelText: 'Monto mínimo para comprar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el monto mínimo de compra por favor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    db
                        .addProveedor(
                      nameController.text,
                      codigoController.text,
                      envioController.text,
                      fechaController.text,
                      montoMinimoController.text,
                    )
                        .then((_) {
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        msg: "Proveedor creado con éxito",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }).catchError((error) {
                      print("Error al guardar el proveedor: $error");
                      Navigator.pop(context);
                    });
                  }
                },
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
