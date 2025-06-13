import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flowers_EA/pages/comunes/bodega.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';

class BodegaForm extends StatefulWidget {
  const BodegaForm({Key? key}) : super(key: key);

  @override
  BodegaFormState createState() => BodegaFormState();
}

class BodegaFormState extends State<BodegaForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  TextEditingController ubicacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creación de una nueva bodega'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: ubicacionController,
                decoration: const InputDecoration(
                    labelText: 'Ubicación de la nueva bodega'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la ubicación porfavor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    _formKey.currentState!.save();

                    db.addBodega(ubicacionController.text).then((_) {
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        msg: "Bodega creada con éxito",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );

                    }).catchError((error) {
                      print("Error al guardar la bodega: $error");
                      Navigator.pop(context);
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
