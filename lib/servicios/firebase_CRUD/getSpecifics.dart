
import 'package:cloud_firestore/cloud_firestore.dart';

class getNombres_Codigos {
  Future<Map<String, dynamic>> fetchSuplidores() async {
    try {
      // Referencia a la colección 'Proveedores' en Firestore
      CollectionReference proveedores =
          FirebaseFirestore.instance.collection('Proveedores');
      // Obtener todos los documentos en la colección
      QuerySnapshot snapshot = await proveedores.get();

      // Listas y mapas para almacenar los datos recuperados
      List<String> getSuplidores = [];
      Map<String, String> getCodigosSuplidores = {};

      // Iterar sobre cada documento en el snapshot
      for (var doc in snapshot.docs) {
        String nombre = doc['Nombre']; // Obtener el nombre del proveedor
        String codigo = doc['Codigo']; // Obtener el código del proveedor

        // Añadir el nombre a la lista de suplidores recuperados
        getSuplidores.add(nombre);
        // Añadir el nombre y código al mapa de códigos de suplidores recuperados
        getCodigosSuplidores[nombre] = codigo;
      }

      // Devolver los datos en un mapa
      return {
        'Proveedor': getSuplidores,
        'Codigo_Proveedor': getCodigosSuplidores,
      };
    } catch (e) {
      // Devolver un mapa vacío en caso de error
      return {
        'Proveedor': [],
        'Codigo_Proveedor': {},
      };
    }
  }
}


class GetCategoria {
  Future<List<String>> fetchCategoria() async {
    try {
      // Referencia a la colección 'Categoria' en Firestore
      CollectionReference categorias =
          FirebaseFirestore.instance.collection('Categoria');
      // Obtener todos los documentos en la colección
      QuerySnapshot snapshot = await categorias.get();

      // Lista para almacenar los nombres recuperados
      List<String> categoriasList = [];

      // Iterar sobre cada documento en el snapshot
      for (var doc in snapshot.docs) {
        String nombre = doc['nombre']; // Obtener el nombre de las categorías
        // Añadir el nombre a la lista de categorías recuperadas
        categoriasList.add(nombre);
      }

      // Devolver la lista de nombres
      return categoriasList;
    } catch (e) {
      // Devolver una lista vacía en caso de error
      return [];
    }
  }
}
