import 'package:flutter/material.dart';
import '../../../servicios/firebase_CRUD/CRUD.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoriaForm extends StatefulWidget {
  const CategoriaForm({super.key});

  @override
  CategoriaFormState createState() => CategoriaFormState();
}

class CategoriaFormState extends State<CategoriaForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  TextEditingController codigoController = TextEditingController();
  TextEditingController nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: codigoController,
                decoration:
                    const InputDecoration(labelText: 'Código de categoría '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresar un código para la categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría: '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresar un nombre de la categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _firebaseService
                        .addCategoria(
                      nombreController.text,
                      codigoController.text,
                    )
                        .then((_) {
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        msg: "Categoría creada con éxito",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }).catchError((error) {
                      print("Error al guardar la categoría: $error");
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                              'Ocurrió un error al guardar la categoría: $error'),
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
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
