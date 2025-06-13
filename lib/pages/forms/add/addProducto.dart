import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flowers_EA/clases/DatosFormProductos.dart';
import 'package:flowers_EA/clases/productos.dart';
import 'package:flowers_EA/pages/forms/add/addLogProv.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:flowers_EA/servicios/images/select_image.dart';
import 'package:flowers_EA/servicios/images/subirimagen.dart';

class InventarioForm extends StatefulWidget {
  @override
  InventarioFormState createState() => InventarioFormState();
}

class InventarioFormState extends State<InventarioForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService db = FirebaseService();

  // Generalidades
  TextEditingController codigoController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  String? _selectedCategoria;
  String? _selectedSubCategoria;
  String? _Bodega;
  File? imagen_upload;

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
                    return 'Por favor ingresa el nombre del producto.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el código del producto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: db.getCategoriaStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final categorias = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoria,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categorias.map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria['nombre'] as String,
                        child: Text(categoria['nombre'] as String),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategoria = newValue;
                        _selectedSubCategoria = null;
                      });
                      if (_selectedCategoria != null) {
                        db
                            .getSubCategoriasPorCategoriaStream(
                                _selectedCategoria!)
                            .listen((subcategoriasData) {
                          setState(() {
                            subcategorias = subcategoriasData;
                          });
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona una categoría.';
                      }
                      return null;
                    },
                  );
                },
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
                    return 'Ingrese el estilo del producto porfavor.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la marca del producto porfavor.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el color del producto porfavor.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: medidasController,
                decoration: const InputDecoration(labelText: 'Medidas'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese las medidas del producto porfavor.';
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
                        return 'Por favor selecciona una bodega para el producto.';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              imagen_upload != null
                  ? Image.file(imagen_upload!)
                  : Container(
                      margin: const EdgeInsets.all(10),
                      height: 150,
                      width: double.infinity,
                      color: Colors.purple,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.file_upload),
                        onPressed: () async {
                          final imagen = await getImage();
                          if (imagen != null) {
                            setState(() {
                              imagen_upload = File(imagen.path);
                            });
                          }
                        },
                      ),
                      const Text('Subir Imagen'),
                    ],
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final imagen = await takeImage();
                          if (imagen != null) {
                            setState(() {
                              imagen_upload = File(imagen.path);
                            });
                          }
                        },
                      ),
                      const Text('Tomar Imagen'),
                    ],
                  ),
                ],
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
                controller: facturaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor en factura:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el valor en factura para el producto.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Ingrese un valor válido (número positivo).';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: costouController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Costo unitario:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el costo unitario del producto por favor.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Ingrese un costo unitario válido (número positivo).';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: costoController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Costo total:'),
              ),
              TextFormField(
                controller: preciouController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio unitario:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el precio unitario del producto por favor.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Ingrese un precio unitario válido (número positivo).';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: precioController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Precio total: '),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Verificar si el código ya existe en la base de datos
                    bool codigoExiste =
                        await db.existeCodigo(codigoController.text);

                    if (codigoExiste) {
                      Navigator.pop(context); // Cerrar el diálogo de carga
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Código Existente'),
                            content: Text(
                                'El código ${codigoController.text} ya existe en la base de datos. Por favor, elige otro código.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Cerrar el diálogo
                                },
                                child: Text('Aceptar'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Si el código no existe, continuar con el proceso de creación del producto
                      String? subido;
                      if (imagen_upload != null) {
                        subido = await uploadImage(imagen_upload!);
                      }
                      DatosFormProducto.producto = Producto(
                        nombre: nombreController.text,
                        codigo: codigoController.text,
                        categoria: _selectedCategoria,
                        subcategoria: _selectedSubCategoria,
                        modelo: modeloController.text,
                        color: colorController.text,
                        marca: marcaController.text,
                        medidas: medidasController.text,
                        cantidad: cantidadController.text,
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
                          builder: (context) => ProveedorForm(),
                        ),
                      );
                    }
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
