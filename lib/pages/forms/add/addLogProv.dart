import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flowers_EA/clases/DatosFormProductos.dart';
import 'package:flowers_EA/pages/comunes/home.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/getSpecifics.dart';
import 'package:flowers_EA/clases/LogProveedor.dart';

class ProveedorForm extends StatefulWidget {
  @override
  _ProveedorFormState createState() => _ProveedorFormState();
}

class _ProveedorFormState extends State<ProveedorForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  // Controladores de texto
  TextEditingController nombreProvController = TextEditingController();
  TextEditingController codigoProvController = TextEditingController();
  TextEditingController codigoProdController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController precioProdController = TextEditingController();
  TextEditingController diasEntregaController = TextEditingController();
  TextEditingController montoController = TextEditingController();

  List<String> proveedores = [];
  Map<String, String> codigosProveedor = {};

  @override
  void initState() {
    super.initState();
    _fetchSuplidores();
  }

  void _fetchSuplidores() async {
    // Obtener datos de proveedores desde Firestore
    Map<String, dynamic> datos = await getNombres_Codigos().fetchSuplidores();
    setState(() {
      proveedores = datos['Proveedor'] as List<String>;
      codigosProveedor = datos['Codigo_Proveedor'] as Map<String, String>;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Nombre del proveedor:'),
                value: nombreProvController.text.isEmpty
                    ? null
                    : nombreProvController.text,
                items: proveedores.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    nombreProvController.text = newValue!;
                    codigoProvController.text = codigosProveedor[newValue]!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione un proveedor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: diasEntregaController,
                decoration: const InputDecoration(labelText: 'Días de entrega'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese los días de entrega';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: montoController,
                decoration: const InputDecoration(labelText: 'Monto mínimo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el monto mínimo';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Código del proveedor'),
                controller: codigoProvController,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    DatosFormProducto.logProveedor = LogProveedor(
                      CodigoProducto: codigoProdController.text,
                      CodigoSuplidor: codigoProvController.text,
                      DiasEntrega: diasEntregaController.text,
                      Fecha: fechaController.text,
                      Monto: montoController.text,
                      NombreSuplidor: nombreProvController.text,
                      PrecioProducto: precioProdController.text,
                    );

                    db
                        .addProductos(DatosFormProducto.producto,
                            DatosFormProducto.logProveedor)
                        .then((_) {
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        msg: "Producto creado con éxito",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()),
                        (Route<dynamic> route) => false,
                      );
                    }).catchError((error) {
                      print("Error al guardar el producto: $error");
                      Navigator.pop(
                          context);
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
