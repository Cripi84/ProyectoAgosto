import 'package:flutter/material.dart';
import 'package:flowers_EA/clases/prov.dart';
import 'package:flowers_EA/pages/forms/add/addProv.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import '../forms/edit/editProv.dart';

class MiProveedor extends StatefulWidget {
  @override
  _MiProveedorState createState() => _MiProveedorState();
}

class _MiProveedorState extends State<MiProveedor> {
  List<Proveedor> proveedores = [];
  final FirebaseService db = FirebaseService();

  void _showDeleteDialog(Map<String, dynamic> prov) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Está seguro que desea eliminar "${prov['Nombre']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await db.deleteProveedor(prov['uid']);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Widget getProv(Map<String, dynamic> prov) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Código: ${prov['Codigo']}'),
                  Text('Proveedor: ${prov['Nombre']}'),
                  Text('Envío en: ${prov['Envia En']}'),
                  // Text('Fecha: ${prov['Fecha En']}'),
                  Text('Monto mínimo compra: ${prov['Monto_Minimo_Compra']}'),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  padding: EdgeInsets.only(top: 37),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormProvEditar(),
                        settings: RouteSettings(arguments: {
                          'uid': prov['uid'],
                          'Nombre': prov['Nombre'],
                          'Codigo': prov['Codigo'],
                          'Monto_Minimo_Compra': prov['Monto_Minimo_Compra'],
                          'Envia En': prov['Envia En']
                          // 'Fecha En': prov['Fecha En']
                        }),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  padding: EdgeInsets.only(top: 37),
                  onPressed: () {
                    _showDeleteDialog(prov);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proveedores'),
      ),
      body: StreamBuilder<List>(
        stream: db.getProveedorStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var proveedores = snapshot.data!;
            if (proveedores.isEmpty) {
              return const Center(
                child: Text('No se encontraron proveedores'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              itemCount: proveedores.length,
              itemBuilder: (context, index) {
                var proveedor = proveedores[index] as Map<String, dynamic>;
                return getProv(proveedor);
              },
            );
          } else {
            return const Center(
              child: Text('No se encontraron proveedores'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormProvCrear(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        mini: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
