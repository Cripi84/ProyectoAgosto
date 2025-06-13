class LogProveedor {
  String? NombreSuplidor;
  String? CodigoSuplidor;
  String? CodigoProducto;
  String? Fecha;
  String? PrecioProducto;
  String? DiasEntrega;
  String? Monto;


  LogProveedor({
     this.NombreSuplidor,
     this.CodigoSuplidor,
     this.CodigoProducto,
     this.Fecha,
     this.PrecioProducto,
     this.DiasEntrega,
     this.Monto,
  });

  // Método para convertir a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'NombreSuplidor': NombreSuplidor,
      'CodigoSuplidor': CodigoSuplidor,
      'CodigoProducto': CodigoProducto,
      'Fecha': Fecha,
      'PrecioProducto': PrecioProducto,
      'DiasEntrega': DiasEntrega,
      'Monto': Monto,

    };
  }
}
