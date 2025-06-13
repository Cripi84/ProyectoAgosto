import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/forms/edit/editBodega.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import '../forms/add/addBodega.dart';

class Bodegas extends StatefulWidget {
  @override
  _BodegasState createState() => _BodegasState();
}

class _BodegasState extends State<Bodegas> {
  List<Bodegas> Bodega = [];
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
                await db.deleteBodega(prov['uid']);
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

  Widget getProv(Map<String, dynamic> ubi) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ubicación: ${ubi['Ubicacion']}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormEditarBodega(),
                        settings: RouteSettings(arguments: {
                          'uid': ubi['uid'],
                          'Ubicacion': ubi['Ubicacion'],
                        }),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteDialog(ubi);
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
        title: Text('Bodegas'),
      ),
      body: StreamBuilder<List>(
        stream: db.getBodegasStream(),
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
                child: Text('No hay bodegas disponibles'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: proveedores.length,
              itemBuilder: (context, index) {
                var proveedor = proveedores[index] as Map<String, dynamic>;
                return getProv(proveedor);
              },
            );
          } else {
            return const Center(
              child: Text('No se encontraron bodegas'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BodegaForm(),
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
