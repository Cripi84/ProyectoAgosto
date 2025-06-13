import 'package:flutter/material.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FormCatEditar extends StatefulWidget {
  FormCatEditar({super.key});

  @override
  _FormCatEditarState createState() => _FormCatEditarState();
}

class _FormCatEditarState extends State<FormCatEditar> {
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController codigoController = TextEditingController(text: '');

  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    nameController.text = arguments['nombre'] ?? '';
    codigoController.text = arguments['codigo'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Categoría'),
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
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await db.updateCategoria(
                      arguments['uid'],
                      nameController.text,
                      codigoController.text,
                    );

                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Categoría actualizada correctamente",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );

                    Navigator.pop(context);
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
