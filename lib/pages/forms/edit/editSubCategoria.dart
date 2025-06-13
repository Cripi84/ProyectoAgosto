import 'package:flutter/material.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FormSubCatEditar extends StatefulWidget {
  const FormSubCatEditar({Key? key}) : super(key: key);

  @override
  _FormSubCatEditarState createState() => _FormSubCatEditarState();
}

class _FormSubCatEditarState extends State<FormSubCatEditar> {
  TextEditingController nameController = TextEditingController();
  TextEditingController codigoController = TextEditingController();
  String? _selectedCategoria;
  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    codigoController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    nameController.text = arguments['Nombre'] ?? '';
    codigoController.text = arguments['codigosub'] ?? '';
    _selectedCategoria ??= arguments['codigocat'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Sub-Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: db.getCategoriaStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay categorías disponibles');
                  } else {
                    var categorias = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Seleccione una Categoría:'),
                      value: _selectedCategoria,
                      items: categorias.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria['nombre'] as String,
                          child: Text(categoria['nombre'] as String),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategoria = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una categoría';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              TextFormField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un codigo para la Sub-Categoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await db.updateSubCategoria(
                      arguments['uid'],
                      nameController.text,
                      _selectedCategoria!,
                      codigoController.text,
                    );

                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Subcategoría actualizada correctamente",
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
