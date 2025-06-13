class Invent{
  String code; //código identificador
  String type; //tipo de producto mesa, adorno, mueble...
  String model; //especificar ejemplo si type=mesa si es mesa de noche, de centro, comedor, etc...
  String name; //nombre del producto ej: Sillon de sala color gris
  String cost; //costo del producto
  String price; //precio
  String discount; //si el producto tiene algún descuento
  String oCost; // % sobre costo del producto
  String oPrice; // % sobre precio del producto
  String ePrice; //campo extra de precio
  String eDiscount; //campo extra de descuento
  String costD; //costo en $
  String priceD; //precio en $
  String total; //total del precio ya con isv incluido

  Invent(
    {
      required this.code,
      required this.type,
      required this.model,
      required this.name,
      required this.cost,
      required this.price,
      required this.discount,
      required this.oCost,
      required this.oPrice,
      required this.ePrice,
      required this.eDiscount,
      required this.costD,
      required this.priceD,
      required this.total,
    }
  );
}