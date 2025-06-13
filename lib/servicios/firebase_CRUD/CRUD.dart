import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowers_EA/clases/LogProveedor.dart';
import 'package:flowers_EA/clases/productos.dart';

class FirebaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Métodos para productos
  Stream<List<Map<String, dynamic>>> getProductosStream() {
    return db.collection('Productos').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'Bodega': data['Bodega'] ?? 'n/d',
          'Codigo': data['Codigo'] ?? 'n/d',
          'Color': data['Color'] ?? 'n/d',
          'Marca': data['Marca'] ?? 'n/d',
          'Medidas': data['Medidas'] ?? 'n/d',
          'Tamanio': data['Tamanio'] ?? 'n/d',
          'Proveedor': data['Proveedor'] ?? 'n/d',
          'Categoria': data['Categoria'] ?? 'n/d',
          'SubCategoria': data['SubCategoria'] ?? 'n/d',
          'Precio': data['Precio'] ?? 'n/d',
          'Nombre': data['Nombre'] ?? 'n/d',
          'CodProv': data['CodProv'] ?? 'n/d',
          'Modelo': data['Modelo'] ?? 'n/d',
          'Costo': data['Costo'] ?? 'n/d',
          'Detalle': data['Detalle'] ?? 'n/d',
          'Total': data['Total'] ?? 'n/d',
          'Descuento': data['Descuento'] ?? 'n/d',
        };
      }).toList();
    });
  }

  Future<void> addProductos(Producto producto, LogProveedor proveedor) async {
    await db.collection('Productos').add({
      'Bodega': producto.bodega ?? 'n/d',
      'Codigo': producto.codigo ?? 'n/d',
      'Nombre': producto.nombre ?? 'n/d',
      'Cantidad': producto.cantidad ?? 'n/d',
      'Color': producto.color ?? 'n/d',
      'Marca': producto.marca ?? 'n/d',
      'Medidas': producto.medidas ?? 'n/d',
      'Proveedor': proveedor.NombreSuplidor ?? 'n/d',
      'Categoria': producto.categoria ?? 'n/d',
      'SubCategoria': producto.subcategoria ?? 'n/d',
      'Precio Unitario': producto.preciou ?? 'n/d',
      'Precio Total': producto.precio ?? 'n/d',
      'Imagen': producto.imagen ?? '',
      'Modelo': producto.modelo ?? 'n/d',
      'Costo Unitario': producto.costou ?? 'n/d',
      'Costo': producto.costo ?? 'n/d',
      'Monto': proveedor.Monto ?? 'n/d',
      'Total': producto.total ?? 'n/d',
      'Factura': producto.factura ?? 'n/d',
      'Codigo Producto': proveedor.CodigoProducto ?? 'n/d',
      'Codigo Proveedor': proveedor.CodigoSuplidor ?? 'n/d',
      'Dia Entrega': proveedor.DiasEntrega,
      'Fecha de Creacion': FieldValue.serverTimestamp(),
      'Fecha de Edicion': 'no se a editado el producto',
    });
  }

//agarrar id para editar
  Future<Map<String, dynamic>?> getProductoByUid(String uid) async {
    try {
      DocumentSnapshot doc = await db.collection('Productos').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print("No se encontro el documento");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> deleteProductos(String productoId) async {
    await db.collection('Productos').doc(productoId).delete();
  }

  Future<void> updateProductos(
      String uid, Producto producto, LogProveedor proveedor) async {
    await db.collection('Productos').doc(uid).update({
      'Bodega': producto.bodega ?? 'n/d',
      'Codigo': producto.codigo ?? 'n/d',
      'Color': producto.color ?? 'n/d',
      'Cantidad': producto.cantidad ?? 'n/d',
      'Marca': producto.marca ?? 'n/d',
      'Medidas': producto.medidas ?? 'n/d',
      'Proveedor': proveedor.NombreSuplidor ?? 'n/d',
      'Categoria': producto.categoria ?? 'n/d',
      'SubCategoria': producto.subcategoria ?? 'n/d',
      'Precio Unitario': producto.preciou ?? 'n/d',
      'Precio Total': producto.precio ?? 'n/d',
      'Nombre': producto.nombre ?? 'n/d',
      'Imagen': producto.imagen ?? 'n/d',
      'Modelo': producto.modelo ?? 'n/d',
      'Costo Unitario': producto.costou ?? 'n/d',
      'Costo': producto.costo ?? 'n/d',
      'Monto': proveedor.Monto ?? 'n/d',
      'Total': producto.total ?? 'n/d',
      'Factura': producto.factura ?? 'n/d',
      'Codigo Producto': proveedor.CodigoProducto ?? 'n/d',
      'Codigo Proveedor': proveedor.CodigoSuplidor ?? 'n/d',
      'Dia Entrega': proveedor.DiasEntrega,
      'Fecha de Edicion': FieldValue.serverTimestamp(),
    });
  }

Future<bool> existeCodigo(String codigo) async {
    // Realiza una consulta para verificar si el código ya existe en la colección
    final QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('Productos')
        .where('Codigo', isEqualTo: codigo)
        .get();

    // Devuelve true si ya existe el código, de lo contrario devuelve false
    return snapshot.docs.isNotEmpty;
  }

  //****************************************METODOS PARA PROVEEDORES*******************************************
  Stream<List<Map<String, dynamic>>> getProveedorStream() {
    return db.collection('Proveedores').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'Codigo': data['Codigo'],
          'Nombre': data['Nombre'],
          'Monto_Minimo_Compra': data['Monto_Minimo_Compra'],
          'Envia En': data['Envia En'],
          'Fecha En': data['Fecha En']
        };
      }).toList();
    });
  }

  Future<void> addProveedor(String name, String codigo, String envio,
      String fecha, String monto_minimo) async {
    await db.collection('Proveedores').add({
      'Codigo': codigo,
      'Nombre': name,
      'Monto_Minimo_Compra': monto_minimo,
      'Envia En': envio,
      'Fecha En': fecha
    });
  }

  Future<void> updateProveedor(String uid, String newName, String newCodigo,
      String newEnvio, String newMonto_minimo) async {
    await db.collection('Proveedores').doc(uid).update({
      'Codigo': newCodigo,
      'Nombre': newName,
      'Monto_Minimo_Compra': newMonto_minimo,
      'Envia En': newEnvio,
    });
  }

  Future<void> deleteProveedor(String uid) async {
    await db.collection('Proveedores').doc(uid).delete();
  }

  //******************************************METODOS PARA CATEGORIAS******************************************
  Stream<List<Map<String, dynamic>>> getCategoriaStream() {
    return db.collection('Categoria').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'codigo': data['codigo'],
          'nombre': data['nombre'],
        };
      }).toList();
    });
  }

  Stream<List<String>> getCategoriaNombresStream() {
    return getCategoriaStream().map((categorias) {
      return categorias
          .map((categoria) => categoria['nombre'] as String)
          .toList();
    });
  }

  Future<void> addCategoria(String nameCategoria, String codeCategoria) async {
    await db.collection('Categoria').add({
      'codigo': codeCategoria,
      'nombre': nameCategoria,
    });
  }

  Future<void> updateCategoria(
      String uid, String newName, String newCodigo) async {
    await db.collection('Categoria').doc(uid).update({
      'codigo': newCodigo,
      'nombre': newName,
    });
  }

  Future<void> deleteCategoria(String uid) async {
    await db.collection('Categoria').doc(uid).delete();
  }

  //******************************************METODOS PARA SUBCATEGORIAS***************************************
  Stream<List<Map<String, dynamic>>> getSubCategoriaStream() {
    return db.collection('SubCategoria').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'nombrecat': data['nombrecat'],
          'codigosub': data['codigosub'],
          'Nombre': data['Nombre'],
        };
      }).toList();
    });
  }

  Future<void> addSubCategoria(
      String nameCategoria, String codeSubCat, String nameSubCategoria) async {
    await db.collection('SubCategoria').add({
      'nombrecat': nameCategoria,
      'codigosub': codeSubCat,
      'Nombre': nameSubCategoria,
    });
  }

  Future<void> updateSubCategoria(
      String uid, String newName, String newCategoria, String newCodigo) async {
    await db.collection('SubCategoria').doc(uid).update({
      'nombrecat': newCategoria,
      'codigosub': newCodigo,
      'Nombre': newName,
    });
  }

  Future<void> deleteSubCategoria(String uid) async {
    await db.collection('SubCategoria').doc(uid).delete();
  }

  //FILTRA MODELOS POR CATEGORIA
  Stream<List<Map<String, dynamic>>> getSubCategoriasPorCategoriaStream(
      String nombreCategoria) {
    return db
        .collection('SubCategoria')
        .where('nombrecat', isEqualTo: nombreCategoria)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'codigosub': data['codigosub'],
          'nombre': data['Nombre'],
        };
      }).toList();
    });
  }

  //MUESTRA LOS Productos DEPENDIENDO DE SU CATEGORIA
  Stream<List<Map<String, dynamic>>> getObjetosPorCategoriaStream(
      String nameCategoria) {
    return db
        .collection('Productos')
        .where('Categoria', isEqualTo: nameCategoria)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'Codigo': data['Codigo'],
          'Nombre': data['Nombre'],
          'Marca': data['Marca'],
        };
      }).toList();
    });
  }

  //*******************************************BODEGA************************************** */

  Future<void> addBodega(String ubicacion) async {
    await db.collection('Bodega').add({
      'Ubicacion': ubicacion,
    });
  }

  Future<void> updateBodega(String uid, String ubicacion) async {
    await db.collection('Bodega').doc(uid).update({
      'Ubicacion': ubicacion,
    });
  }

  Future<void> deleteBodega(String uid) async {
    await db.collection('Bodega').doc(uid).delete();
  }

  Stream<List<Map<String, dynamic>>> getBodegasStream() {
    return db.collection('Bodega').snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {'uid': doc.id, 'Ubicacion': data['Ubicacion']};
      }).toList();
    });
  }

  // ***************************************** SCANNER ********************************************************

  Future<String?> verificarProducto(String codigoProducto) async {
    var snapshot = await db
        .collection('Productos')
        .where('Codigo', isEqualTo: codigoProducto)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].id;
    } else {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  
  double calcularPrecio(double precioUnitario, int cantidad) {
    return precioUnitario*cantidad;
  } 

  double calcularCosto(double costoUnitario, int cantidad) {
    return costoUnitario*cantidad;
  } 
  
}
