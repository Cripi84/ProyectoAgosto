import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/forms/add/addCategoria.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import '../forms/edit/editCategoria.dart';

class MiCategoria extends StatefulWidget {
  @override
  _MiCategoriaState createState() => _MiCategoriaState();
}

class _MiCategoriaState extends State<MiCategoria> {
  final FirebaseService db = FirebaseService();

  void _showDeleteDialog(Map<String, dynamic> tip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Está seguro que desea eliminar "${tip['nombre']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await db.deleteCategoria(tip['uid']);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Widget getCat(Map<String, dynamic> tip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Código: ${tip['codigo']}'), 
            Text(
                'Nombre: ${tip['nombre']}'), 
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormCatEditar(),
                        settings: RouteSettings(arguments: {
                          'codigo': tip['codigo'],
                          'nombre': tip['nombre'],
                          'uid': tip['uid'],
                        }),
                      ),
                    ).then((_) {
                      // Refrescar la lista de categorías al regresar de la pantalla de edición
                      setState(() {});
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteDialog(tip);
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
        title: const Text('Categorías'),
      ),
      body: StreamBuilder<List>(
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
            // Debugging: Imprimir las categorías
            print("Categorías obtenidas: $categorias");
            if (categorias.isEmpty) {
              return const Center(
                child: Text('No se encontraron categorías'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                var categoria = categorias[index] as Map<String, dynamic>;
                return getCat(categoria);
              },
            );
          } else {
            return const Center(
              child: Text('No se encontraron categorías'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoriaForm(),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        mini: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
