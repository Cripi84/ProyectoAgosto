import 'package:flowers_EA/pages/comunes/home.dart';
import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/comunes/proveedores.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FormProvEditar extends StatefulWidget {
  const FormProvEditar({super.key});

  @override
  _FormProvEditarState createState() => _FormProvEditarState();
}

class _FormProvEditarState extends State<FormProvEditar> {
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController codigoController = TextEditingController(text: '');
  TextEditingController envioController = TextEditingController(text: '');
  TextEditingController montoMinimoController = TextEditingController(text: '');

  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  @override
  Widget build(BuildContext context) {
    //esto de aca envia estos textos como argumentos como map con string y dinamico
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    nameController.text = arguments['Nombre'] ?? '';
    codigoController.text = arguments['Codigo'] ?? '';
    montoMinimoController.text = arguments['Monto_Minimo_Compra'] ?? '';
    envioController.text = arguments['Envia En'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Proveedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: codigoController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del proveedor porfavor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: envioController,
                decoration: const InputDecoration(labelText: 'Envío en:'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese donde envia el proveedor porfavor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: montoMinimoController,
                decoration: const InputDecoration(
                    labelText: 'Monto mínimo para comprar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un monto minimo porfavor';
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
                        .updateProveedor(
                      arguments['uid'],
                      nameController.text,
                      codigoController.text,
                      envioController.text,
                      montoMinimoController.text,
                    )
                        .then((_) {
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        msg: "Proveedor actualizado correctamente",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }).catchError((error) {
                      print("Error al actualizar el proveedor: $error");
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg: "Error al actualizar el proveedor",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    });
                  }
                },
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
