import 'package:flutter/material.dart';
import 'package:flowers_EA/clases/DatosFormProductos.dart';
import 'package:flowers_EA/clases/productos.dart';
import 'package:flowers_EA/pages/comunes/home.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/getSpecifics.dart';
import 'package:flowers_EA/clases/LogProveedor.dart';
import 'package:fluttertoast/fluttertoast.dart';

class editLogProveedorForm extends StatefulWidget {
  final String uid;

  const editLogProveedorForm({super.key, required this.uid});

  @override
  _editLogProveedorFormState createState() => _editLogProveedorFormState();
}

class _editLogProveedorFormState extends State<editLogProveedorForm> {
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
    _loadProveedorData();
  }

  void _fetchSuplidores() async {
    Map<String, dynamic> datos = await getNombres_Codigos().fetchSuplidores();
    setState(() {
      proveedores = datos['Proveedor'] as List<String>;
      codigosProveedor = datos['Codigo_Proveedor'] as Map<String, String>;
    });
  }

  Future<void> _loadProveedorData() async {
    var proveedor = await db.getProductoByUid(widget.uid);
    if (proveedor != null) {
      setState(() {
        nombreProvController.text = proveedor['Proveedor'] ?? '';
        codigoProvController.text = proveedor['Codigo Proveedor'] ?? '';
        codigoProdController.text = proveedor['Codigo Producto'] ?? '';
        diasEntregaController.text = proveedor['Dia Entrega'] ?? '';
        montoController.text = proveedor['Monto'] ?? '';
        precioProdController.text = proveedor['Precio Unitario'] ?? '';
      });
    }
  }

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
                    const InputDecoration(labelText: 'Nombre del Proveedor:'),
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
                keyboardType: TextInputType.number,
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
                    const InputDecoration(labelText: 'Código del Proveedor'),
                controller: codigoProvController,
                readOnly: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    DatosFormProducto.logProveedor = LogProveedor(
                      CodigoProducto: codigoProdController.text,
                      CodigoSuplidor: codigoProvController.text,
                      DiasEntrega: diasEntregaController.text,
                      Monto: montoController.text,
                      NombreSuplidor: nombreProvController.text,
                      PrecioProducto: precioProdController.text,
                    );

                    db
                        .updateProductos(widget.uid, DatosFormProducto.producto,
                            DatosFormProducto.logProveedor)
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

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }).catchError((error) {
                      Navigator.pop(context); 
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text(
                              'Ocurrió un error al actualizar LogProv: $error'),
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
