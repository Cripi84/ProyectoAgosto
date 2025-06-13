import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';

class SubCategoriaForm extends StatefulWidget {
  const SubCategoriaForm({Key? key}) : super(key: key);

  @override
  SubCategoriaFormState createState() => SubCategoriaFormState();
}

class SubCategoriaFormState extends State<SubCategoriaForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  TextEditingController codigoSubCategoriaController = TextEditingController();
  TextEditingController nombreSubCategoriaController = TextEditingController();
  String? _selectedCategoria;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Sub-Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firebaseService.getCategoriaStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay categorías disponibles');
                  } else {
                    var categorias = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Seleccione una categoría:'),
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
                controller: codigoSubCategoriaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Código para Sub-Categoría:'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código para sub-categoría';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nombreSubCategoriaController,
                decoration: const InputDecoration(
                    labelText: 'Nombre para Sub-Categoría:'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de sub-categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    _firebaseService
                        .addSubCategoria(
                      _selectedCategoria!,
                      codigoSubCategoriaController.text,
                      nombreSubCategoriaController.text,
                    )
                        .then((_) {
                      Navigator.pop(context);

                      // Mostrar un toast de éxito
                      Fluttertoast.showToast(
                        msg: "Subcategoría creada con éxito",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }).catchError((error) {
                      print("Error al guardar la subcategoría: $error");
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                              'Ocurrió un error al guardar la subcategoría: $error'),
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
