import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'perfil_producto.dart';

class Buscar extends StatefulWidget {
  const Buscar({Key? key}) : super(key: key);

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Card(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar por nombre o código...',
            ),
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Productos').snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshots.hasError) {
            return Center(child: Text('Error: ${snapshots.error}'));
          } else if (snapshots.hasData) {
            var filteredDocs = snapshots.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String nombre = data['Nombre'].toString().toLowerCase();
              String codigo = data['Codigo'].toString().toLowerCase();
              return query.isEmpty ||
                  nombre.contains(query.toLowerCase()) ||
                  codigo.contains(query.toLowerCase());
            }).toList();

            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                var doc = filteredDocs[index];
                var data = doc.data() as Map<String, dynamic>;
                String documentId = doc.id;

                return ListTile(
                  title: Text(
                    data['Nombre'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    data['Codigo'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    // Imprime el documentId para depuración
                    print('Document ID: $documentId');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Perfil(productId: documentId),
                      ),
                    );
                  },
                  leading: data['Imagen'] != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(data['Imagen']),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.image),
                        ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay datos disponibles.'));
          }
        },
      ),
    );
  }
}