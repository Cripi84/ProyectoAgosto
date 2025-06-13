import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil extends StatefulWidget {
  final String productId;

  Perfil({required this.productId});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: db.collection('Productos').doc(widget.productId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Cargando...');
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return Text('Error');
            }

            final Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            // Utiliza el nombre del producto como título
            return Text(data['Nombre']);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: db.collection('Productos').doc(widget.productId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar datos del producto'));
          }

          final Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  data['Imagen'] != null
                      ? Container(
                          height: 400,
                          child: Image.network(
                            data['Imagen'],
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image, size: 100),
                        ),
                  const SizedBox(height: 10),
                  const Text(
                    'Generalidades',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  buildInfoRow('Código', data['Codigo']),
                  buildInfoRow('Nombre', data['Nombre']),
                  buildInfoRow('Categoría', data['Categoria']),
                  buildInfoRow('SubCategoría', data['SubCategoria']),
                  const SizedBox(height: 10),
                  const Text(
                    'Características',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  buildInfoRow('Estilo', data['Modelo']),
                  buildInfoRow('Marca', data['Marca']),
                  buildInfoRow('Color', data['Color']),
                  buildInfoRow('Medidas', data['Medidas']),
                  const Text(
                    'Información del proveedor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  buildInfoRow('Código del Proveedor', data['Codigo Proveedor']),
                  buildInfoRow('Proveedor', data['Proveedor']),
                  buildInfoRow('Días de entrega', data['Dia Entrega']),
                  buildInfoRow('Monto mínimo compra', data['Monto']),
                  const Text(
                    'Almacenamiento',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  buildInfoRow('Bodega', data['Bodega']),
                  const Text(
                    'Finanzas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  buildInfoRow('Cantidad', data['Cantidad']),
                  buildInfoRow('Valor Factura', data['Factura']),
                  buildInfoRow('Costo Unitario', data['Costo Unitario']),
                  buildInfoRow('Costo Total', data['Costo']),
                  buildInfoRow('Precio Unitario', data['Precio Unitario']),
                  buildInfoRow('Precio Total', data['Precio Total']),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            '$title: ${value ?? 'n/d'}',
            style: const TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
