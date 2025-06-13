import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

Future<void> importExcel(File excelFile) async {
  // Inicializar Firebase si no está ya inicializado
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Leer el archivo Excel
  var bytes = await excelFile.readAsBytes();
  var excel = Excel.decodeBytes(bytes);

  // Obtener la hoja de "Productos"
  var sheet = excel['Productos'];
  if (sheet == null) {
    print('La hoja "Productos" no existe en el archivo.');
    return;
  }

  // Recorrer las filas del archivo Excel, comenzando desde la segunda fila (índice 1)
  for (var i = 1; i < sheet.rows.length; i++) {
    var row = sheet.rows[i];

    // Crear un mapa de datos para el producto
    var data = {
      'Bodega': row[0]?.value?.toString() ?? 'n/d',
      'Codigo': row[1]?.value?.toString() ?? 'n/d',
      'Color': row[2]?.value?.toString() ?? 'n/d',
      'Marca': row[3]?.value?.toString() ?? 'n/d',
      'Medidas': row[4]?.value?.toString() ?? 'n/d',
      'Proveedor': row[5]?.value?.toString() ?? 'n/d',
      'Categoria': row[6]?.value?.toString() ?? 'n/d',
      'SubCategoria': row[7]?.value?.toString() ?? 'n/d',
      'Precio Unitario': row[8]?.value?.toString() ?? 'n/d',
      'Precio Total': row[9]?.value?.toString() ?? 'n/d',
      'Nombre': row[10]?.value?.toString() ?? 'n/d',
      'Imagen': row[11]?.value?.toString() ?? '',
      'Modelo': row[12]?.value?.toString() ?? 'n/d',
      'Costo Unitario': row[13]?.value?.toString() ?? 'n/d',
      'Costo': row[14]?.value?.toString() ?? 'n/d',
      'Monto': row[15]?.value?.toString() ?? 'n/d',
      'Total': row[16]?.value?.toString() ?? 'n/d',
      'Factura': row[17]?.value?.toString() ?? 'n/d',
      'Codigo Producto': row[18]?.value?.toString() ?? 'n/d',
      'Codigo Proveedor': row[19]?.value?.toString() ?? 'n/d',
      'Dia Entrega': row[20]?.value?.toString() ?? 'n/d',
      'Fecha de Creacion': row[21]?.value?.toString() ?? 'n/d',
      'Fecha de Edicion':
          row[22]?.value?.toString() ?? 'no se ha editado el producto'
    };

    // Verificar y agregar categoría si no existe
    await addCategoryIfNotExist(data['Categoria'] as String);

    // Verificar y agregar subcategoría si no existe
    await addSubCategoryIfNotExist(
        data['Categoria'] as String, 
        data['SubCategoria'] as String);

    await addProvIfNotExist(
      data['Codigo Proveedor'] as String,
      data['Dia Entrega'] as String,
      data['Monto'] as String,
      data['Proveedor'] as String,
    );

    await addBodegaIfNotExist(data['Bodega'] as String);

    // Agregar producto a Firestore
    await FirebaseFirestore.instance.collection('Productos').add(data);
  }

  print('Importación completada.');
}

Future<void> addCategoryIfNotExist(String categoria) async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Categoria')
      .where('nombre', isEqualTo: categoria)
      .get();

  if (snapshot.docs.isEmpty) {
    await FirebaseFirestore.instance.collection('Categoria').add({
      'nombre': categoria,
      'codigo':
          DateTime.now().millisecondsSinceEpoch.toString(), // Código generado
    });
    print('Categoría "$categoria" agregada.');
  }
}

Future<void> addSubCategoryIfNotExist(
    String categoria, String subCategoria) async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('SubCategoria')
      .where('nombrecat', isEqualTo: categoria)
      .where('Nombre', isEqualTo: subCategoria)
      .get();

  if (snapshot.docs.isEmpty) {
    await FirebaseFirestore.instance.collection('SubCategoria').add({
      'nombrecat': categoria,
      'Nombre': subCategoria,
      'codigosub':
          DateTime.now().millisecondsSinceEpoch.toString(), // Código generado
    });
    print(
        'Subcategoría "$subCategoria" agregada bajo la categoría "$categoria".');
  }
}

Future<void> addProvIfNotExist(
    String codigo, String envio, String monto, String name) async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Proveedores')
      .where('Nombre', isEqualTo: name)
      .get();

  if (snapshot.docs.isEmpty) {
    await FirebaseFirestore.instance.collection('Proveedores').add({
      'Codigo': codigo,
      'Nombre': name,
      'Monto Minimo Compra': monto,
      'Envia En': envio
    });
    print('Proveedor "$name" agregado con el código "$codigo".');
  }
}

Future<void> addBodegaIfNotExist(String ubicacion) async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Bodega')
      .where('Ubicacion', isEqualTo: ubicacion)
      .get();

  if (snapshot.docs.isEmpty) {
    await FirebaseFirestore.instance.collection('Bodega').add({
      'Ubicacion': ubicacion,
    });
  }
}

Future<void> seleccionarArchivoExcel() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    await importExcel(file);
  } else {
    print('No se seleccionó ningún archivo.');
  }
}