import 'package:flutter/material.dart';
import 'package:flowers_EA/servicios/excel/saveReport.dart';
import 'package:flowers_EA/servicios/firebase_CRUD/CRUD.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductosCategoria extends StatefulWidget {
  final String codigoCategoria;
  final String nombreCategoria;

  const ProductosCategoria({super.key, required this.codigoCategoria, required this.nombreCategoria});

  @override
  _ProductosCategoriaState createState() => _ProductosCategoriaState();
}

class _ProductosCategoriaState extends State<ProductosCategoria> {
  final FirebaseService db = FirebaseService();

  Future<void> _requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      // Solicitar permiso
      if (await Permission.manageExternalStorage.request().isGranted) {
        // Permiso concedido
        await saveReport(widget.nombreCategoria);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte guardado exitosamente')),
        );
      } else {
        // Permiso denegado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de almacenamiento denegado')),
        );
      }
    } else if (status.isGranted) {
      // Permiso ya concedido
      await saveReport(widget.nombreCategoria);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte guardado exitosamente en ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreCategoria),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _requestStoragePermission,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getObjetosPorCategoriaStream(widget.nombreCategoria),
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
                child: Text('No se encontraron productos para esta categoría'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                var producto = productos[index];
                return Card(
                  child: ListTile(
                    title: Text(producto['Nombre'] ?? 'n/d'),
                    subtitle: Text(producto['Marca'] ?? 'n/d'),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No se encontraron productos para esta categoría'),
            );
          }
        },
      ),
    );
  }
}
