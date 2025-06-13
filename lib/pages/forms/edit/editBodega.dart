import 'package:flowers_EA/pages/comunes/home.dart';
import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/comunes/bodega.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FormEditarBodega extends StatefulWidget {
  FormEditarBodega({super.key});

  @override
  _FormEditarBodegaState createState() => _FormEditarBodegaState();
}

class _FormEditarBodegaState extends State<FormEditarBodega> {
  TextEditingController ubicacionController = TextEditingController(text: '');

  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Verificar si 'uid' y 'Ubicacion' están presentes en los argumentos
    if (arguments == null ||
        !arguments.containsKey('uid') ||
        !arguments.containsKey('Ubicacion')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Faltan argumentos necesarios para editar la bodega.'),
        ),
      );
    }

    ubicacionController.text = arguments['Ubicacion'] ?? 'n/d';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Bodega'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: ubicacionController,
                decoration:
                    const InputDecoration(labelText: 'Escriba la ubicación'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    db
                        .updateBodega(
                      arguments['uid'],
                      ubicacionController.text,
                    )
                        .then((_) {
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        msg: "Bodega actualizada correctamente",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }).catchError((error) {
                      print("Error al actualizar la bodega: $error");
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                              'Ocurrió un error al actualizar la bodega: $error'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
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
