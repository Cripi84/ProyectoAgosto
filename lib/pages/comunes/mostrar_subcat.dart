import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/forms/edit/editSubCategoria.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:flowers_EA/pages/forms/add/addSubCategoria.dart';

class MiSubCategoria extends StatefulWidget {
  @override
  _MiSubCategoriaState createState() => _MiSubCategoriaState();
}

class _MiSubCategoriaState extends State<MiSubCategoria> {
  final FirebaseService db = FirebaseService();

  void _showDeleteDialog(Map<String, dynamic> subcategoria) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Está seguro que desea eliminar "${subcategoria['Nombre']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await db.deleteSubCategoria(subcategoria['uid']);
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

  Widget getSubCat(Map<String, dynamic> subcategoria) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre de Categoria: ${subcategoria['nombrecat']}'),
            Text('Código Sub-Categoria: ${subcategoria['codigosub']}'),
            Text('Sub-Categoria: ${subcategoria['Nombre']}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormSubCatEditar(),
                        settings: RouteSettings(arguments: {
                          'nombrecat': subcategoria['nombrecat'],
                          'codigosub': subcategoria['codigosub'],
                          'Nombre': subcategoria['Nombre'],
                          'uid': subcategoria['uid'],
                        }),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteDialog(subcategoria);
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
        title: const Text('Sub-Categorías'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getSubCategoriaStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var subcategorias = snapshot.data!;
            if (subcategorias.isEmpty) {
              return const Center(
                child: Text('No se encontraron sub-categorías'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: subcategorias.length,
              itemBuilder: (context, index) {
                var subcategoria = subcategorias[index];
                return getSubCat(subcategoria);
              },
            );
          } else {
            return const Center(
              child: Text('No se encontraron sub-categorías'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCategoriaForm(),
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
