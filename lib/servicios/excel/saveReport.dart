import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveReport(String nombreCategoria) async {
  // Inicializar Firebase si no está ya inicializado
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Crear una nueva instancia de Excel
  var excel = Excel.createExcel();

  // Crear una nueva hoja llamada "Productos"
  var sheet = excel['Productos'];

  // Encabezados de la tabla
  List<String> headers = [
    'Bodega', 'Codigo', 'Color', 'Marca', 'Medidas', 'Proveedor', 
    'Categoria', 'SubCategoria', 'Precio Unitario', 'Precio Total', 
    'Nombre', 'Imagen', 'Modelo', 'Costo Unitario', 'Costo', 
    'Monto', 'Total', 'Factura', 'Codigo Producto', 'Codigo Proveedor', 
    'Dia Entrega', 'Fecha de Creacion', 'Fecha de Edicion'
  ];

  // Añadir los encabezados a la primera fila
  sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

  // Obtener datos desde Firestore
  CollectionReference productos = FirebaseFirestore.instance.collection('Productos');
  QuerySnapshot snapshot = await productos.where('Categoria', isEqualTo: nombreCategoria).get();

  // Añadir los datos a la hoja de cálculo
  snapshot.docs.forEach((doc) {
    var data = doc.data() as Map<String, dynamic>;
    List<dynamic> row = [
      data['Bodega'] ?? 'n/d',
      data['Codigo'] ?? 'n/d',
      data['Color'] ?? 'n/d',
      data['Marca'] ?? 'n/d',
      data['Medidas'] ?? 'n/d',
      data['Proveedor'] ?? 'n/d',
      data['Categoria'] ?? 'n/d',
      data['SubCategoria'] ?? 'n/d',
      data['Precio Unitario'] ?? 'n/d',
      data['Precio Total'] ?? 'n/d',
      data['Nombre'] ?? 'n/d',
      data['Imagen'] ?? '',
      data['Modelo'] ?? 'n/d',
      data['Costo Unitario'] ?? 'n/d',
      data['Costo'] ?? 'n/d',
      data['Monto'] ?? 'n/d',
      data['Total'] ?? 'n/d',
      data['Factura'] ?? 'n/d',
      data['Codigo Producto'] ?? 'n/d',
      data['Codigo Proveedor'] ?? 'n/d',
      data['Dia Entrega'] ?? 'n/d',
      data['Fecha de Creacion'] != null ? data['Fecha de Creacion'].toDate().toString() : 'n/d',
      data['Fecha de Edicion'] ?? 'no se ha editado el producto'
    ];
    sheet.appendRow(row.map((value) => TextCellValue(value.toString())).toList());
  });

  // Definir el directorio y el nombre del archivo
  String outputFile = '/storage/emulated/0/Download/productos_$nombreCategoria.xlsx';

  // Guardar el archivo en el directorio especificado
  List<int>? fileBytes = excel.save();
  if (fileBytes != null) {
    File(outputFile)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    print('Archivo guardado en: $outputFile');
  } else {
    print('No se pudo guardar el archivo');
  }
}
