import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flowers_EA/clases/productos.dart';
import 'package:flowers_EA/pages/comunes/home.dart';
import 'package:flowers_EA/pages/forms/add/addLogProv.dart';
import 'package:flowers_EA/pages/forms/edit/editLogProv.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../clases/DatosFormProductos.dart';
import '../../../servicios/images/select_image.dart';
import '../../../servicios/images/subirimagen.dart';

class editarInventarioForm extends StatefulWidget {
  final String uid;

  const editarInventarioForm({super.key, required this.uid});

  @override
  editarInventarioFormState createState() => editarInventarioFormState();
}

class editarInventarioFormState extends State<editarInventarioForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  // Generalidades
  TextEditingController codigoController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  String? _selectedCategoria;
  String? _selectedSubCategoria;
  String? _Bodega;
  File? imagenUpload;
  String? imagenUrl;

  // Características
  TextEditingController categoriaController = TextEditingController();
  TextEditingController modeloController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController marcaController = TextEditingController();
  TextEditingController medidasController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();
  TextEditingController bodegaController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController preciouController = TextEditingController();
  TextEditingController costoController = TextEditingController();
  TextEditingController costouController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController facturaController = TextEditingController();

  List<Map<String, dynamic>> subcategorias = [];

  @override
  void initState() {
    super.initState();
    _loadProductData();
    cantidadController.addListener(_updateCostAndPrice);
    costouController.addListener(_updateCost);
    preciouController.addListener(_updatePrice);
  }

  @override
  void dispose() {
    cantidadController.removeListener(_updateCostAndPrice);
    costouController.removeListener(_updateCost);
    preciouController.removeListener(_updatePrice);
    cantidadController.dispose();
    costouController.dispose();
    preciouController.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    var producto = await db.getProductoByUid(widget.uid);
    if (producto != null) {
      setState(() {
        nombreController.text = producto['Nombre'] ?? '';
        codigoController.text = producto['Codigo'] ?? '';
        _selectedCategoria = producto['Categoria'];
        _selectedSubCategoria = producto['SubCategoria'];
        _Bodega = producto['Bodega'];
        modeloController.text = producto['Modelo'] ?? '';
        colorController.text = producto['Color'] ?? '';
        marcaController.text = producto['Marca'] ?? '';
        medidasController.text = producto['Medidas'] ?? '';
        ubicacionController.text = producto['Ubicacion'] ?? '';
        precioController.text = producto['Precio Total'] ?? '';
        preciouController.text = producto['Precio Unitario'] ?? '';
        costoController.text = producto['Costo'] ?? '';
        costouController.text = producto['Costo Unitario'] ?? '';
        totalController.text = producto['Total'] ?? '';
        facturaController.text = producto['Factura'] ?? '';
        cantidadController.text = producto['Cantidad'] ?? '';

        // Cargar la imagen del producto si está disponible
        if (producto['Imagen'] != null) {
          imagenUrl = producto['Imagen'];
        }
      });
    }
  }

  void _updateCostAndPrice() {
    _updateCost();
    _updatePrice();
  }

  void _updateCost() {
    if (cantidadController.text.isEmpty || costouController.text.isEmpty) {
      costoController.text = '';
      return;
    }
    double costoUnitario = double.tryParse(costouController.text) ?? 0;
    int cantidad = int.tryParse(cantidadController.text) ?? 0;
    double totalC = costoUnitario * cantidad;
    costoController.text = totalC.toStringAsFixed(2);
  }

  void _updatePrice() {
    if (cantidadController.text.isEmpty || preciouController.text.isEmpty) {
      precioController.text = '';
      return;
    }
    double precioUnitario = double.tryParse(preciouController.text) ?? 0;
    int cantidad = int.tryParse(cantidadController.text) ?? 0;
    double totalP = precioUnitario * cantidad;
    precioController.text = totalP.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Text(
                'Generalidades',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: codigoController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              const SizedBox(height: 16.0),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _selectedCategoria != null
                    ? db.getSubCategoriasPorCategoriaStream(_selectedCategoria!)
                    : Stream.value([]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final subcategorias = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: _selectedSubCategoria,
                    decoration:
                        const InputDecoration(labelText: 'Subcategoría'),
                    items: subcategorias.isNotEmpty
                        ? subcategorias.map((subcategoria) {
                            return DropdownMenuItem<String>(
                              value: subcategoria['nombre'] as String,
                              child: Text(subcategoria['nombre'] as String),
                            );
                          }).toList()
                        : [],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSubCategoria = newValue;
                      });
                    },
                    validator: (value) {
                      if (subcategorias.isNotEmpty &&
                          (value == null || value.isEmpty)) {
                        return 'Por favor selecciona una subcategoría.';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Características',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: modeloController,
                decoration: const InputDecoration(labelText: 'Estilo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el modelo del producto por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la marca del producto por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el color del producto por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: medidasController,
                decoration: const InputDecoration(labelText: 'Medidas'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese las medidas del producto por favor';
                  }
                  return null;
                },
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: db.getBodegasStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final bodegas = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: _Bodega,
                    decoration: const InputDecoration(labelText: 'Bodegas'),
                    items: bodegas.map((bodega) {
                      return DropdownMenuItem<String>(
                        value: bodega['Ubicacion'] as String,
                        child: Text(bodega['Ubicacion'] as String),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _Bodega = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona una Bodega donde se encuentre el producto';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              imagenUrl != null
                  ? Image.network(imagenUrl!)
                  : Container(
                      margin: const EdgeInsets.all(10),
                      height: 150,
                      width: double.infinity,
                      color: Colors.purple,
                    ),
              ElevatedButton(
                onPressed: () async {
                  final imagen = await getImage();
                  if (imagen != null) {
                    setState(() {
                      imagenUpload = File(imagen.path);
                    });
                  }
                },
                child: const Text('Seleccionar Imagen'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final imagen = await takeImage();
                  if (imagen != null) {
                    setState(() {
                      imagenUpload = File(imagen.path);
                    });
                  }
                },
                child: const Text('Tomar Foto'),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Finanzas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
               TextFormField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de producto:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una cantidad para el producto.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Ingrese una cantidad válida (número entero positivo).';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: preciouController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio Unitario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el precio unitario del producto por favor';
                  }
                  return null;
                },
              ),
             TextFormField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el precio del producto por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: costouController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Costo Unitario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el costo unitario del producto por favor';
                  }
                  return null;
                },
              ), TextFormField(
                controller: costoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Costo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el costo del producto por favor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: facturaController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Precio en Factura'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el precio en factura del producto por favor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String? subido;
                    if (imagenUpload != null) {
                      subido = await uploadImage(imagenUpload!);
                    }

                    DatosFormProducto.producto = Producto(
                      nombre: nombreController.text,
                      codigo: codigoController.text,
                      categoria: _selectedCategoria,
                      subcategoria: _selectedSubCategoria,
                      modelo: modeloController.text,
                      color: colorController.text,
                      marca: marcaController.text,
                      cantidad: cantidadController.text,
                      medidas: medidasController.text,
                      ubicacion: ubicacionController.text,
                      bodega: _Bodega,
                      imagen: subido,
                      precio: precioController.text,
                      preciou: preciouController.text,
                      costo: costoController.text,
                      costou: costouController.text,
                      total: totalController.text,
                      factura: facturaController.text,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => editLogProveedorForm(
                          uid: widget.uid,
                        ),
                      ),
                    );

                    Fluttertoast.showToast(
                      msg: "Producto actualizado correctamente",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
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
