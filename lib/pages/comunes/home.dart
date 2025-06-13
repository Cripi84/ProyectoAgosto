import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flowers_EA/servicios/excel/importReport.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/comunes/bodega.dart';
import 'package:flowers_EA/pages/comunes/buscar.dart';
import 'package:flowers_EA/pages/comunes/categorias.dart';
import 'package:flowers_EA/pages/comunes/perfil_producto.dart';
import 'package:flowers_EA/pages/comunes/productos_categoria.dart';
import 'package:flowers_EA/pages/comunes/proveedores.dart';
import 'package:flowers_EA/pages/forms/add/addProv.dart';
import 'package:flowers_EA/pages/forms/add/addProducto.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:flowers_EA/servicios/sign_user/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import '../forms/add/addBodega.dart';
import '../forms/edit/editProducto.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.user}) : super(key: key);

  final String? user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService db = FirebaseService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      // Solicitar permiso
      if (await Permission.manageExternalStorage.request().isGranted) {
        // Permiso concedido
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );
        if (result != null) {
          File excelFile = File(result.files.single.path!);
          await importExcel(excelFile);
        } else {
          Fluttertoast.showToast(
            msg: 'No se seleccionó ningún archivo',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        // Permiso denegado
        Fluttertoast.showToast(
          msg: 'Se negó el permiso',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (status.isGranted) {
      // Permiso ya concedido
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null) {
        File excelFile = File(result.files.single.path!);
        await importExcel(excelFile);
      } else {
        Fluttertoast.showToast(
          msg: 'Se ingresó de manera correcta',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // Solicitar permiso
      if (await Permission.camera.request().isGranted) {
        // Permiso concedido
        scanCd();
      } else {
        // Permiso denegado
        Fluttertoast.showToast(
          msg: 'Permiso de cámara denegado',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (status.isGranted) {
      // Permiso ya concedido
      scanCd();
    }
  }

  void scanCd() async {
    String? scanResult = await scanner.scan();
    if (scanResult != null) {
      String? productoExiste =
          await FirebaseService().verificarProducto(scanResult);

      if (productoExiste != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Perfil(productId: productoExiste),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InventarioForm(),
          ),
        );
      }
    }
  }

  Future<void> clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
  }

  void _confirmBorrarProducto(String productoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que quieres eliminar este producto?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                db.deleteProductos(productoId).then((_) {
                  Navigator.of(context).pop();
                  setState(() {});
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Flowers EA'),
          leading: IconButton(
            icon: const Icon(Icons.supervised_user_circle),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Buscar(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () => _requestCameraPermission(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _tabController.index = index;
            });
          },
          selectedItemColor: const Color.fromARGB(255, 94, 8, 159),
          unselectedItemColor: const Color.fromARGB(255, 111, 111, 111),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Productos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fire_truck),
              label: 'Proveedores',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Agregar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Catálogo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse),
              label: 'Bodegas',
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Ingresar Excel'),
                onTap: () {
                  _requestStoragePermission();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Crear Producto'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InventarioForm()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Crear Proveedor'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FormProvCrear()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categorías'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Categorias()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.fire_truck),
                title: const Text('Proveedores'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MiProveedor()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.warehouse),
                title: const Text('Bodega'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Bodegas()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove("Email");
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: db.getProductosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  var productos = snapshot.data!;
                  if (productos.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron productos'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      var producto = productos[index];
                      return Card(
                        child: ListTile(
                          title: Text(producto['Nombre'] ?? 'n/d'),
                          subtitle: Text(producto['Marca'] ?? 'n/d'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Perfil(productId: producto['uid']),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          editarInventarioForm(
                                              uid: producto['uid']),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _confirmBorrarProducto(producto['uid']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No se encontraron productos'),
                  );
                }
              },
            ),
            MiProveedor(),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Agregar Proveedor'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FormProvCrear()),
                        );
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Agregar Categorías'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Categorias()),
                        );
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Agregar Productos'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InventarioForm()),
                        );
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Agregar Bodega'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BodegaForm()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: db.getCategoriaStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  var categorias = snapshot.data!;
                  if (categorias.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron categorías'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      var categoria = categorias[index];
                      return Card(
                        child: ListTile(
                          title: Text(categoria['nombre'] ?? 'n/d'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductosCategoria(
                                  codigoCategoria: categoria['codigo'],
                                  nombreCategoria: categoria['nombre'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No se encontraron categorías'),
                  );
                }
              },
            ),
            Bodegas(),
          ],
        ),
      ),
    );
  }
}
