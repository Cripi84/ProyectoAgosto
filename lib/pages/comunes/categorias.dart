import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/comunes/mostrar_cat.dart';
import 'package:flowers_EA/pages/comunes/mostrar_subcat.dart';

class Categorias extends StatefulWidget {
  const Categorias({super.key});

  @override
  State<Categorias> createState() => CategoriasState();
}

class CategoriasState extends State<Categorias> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text('Categorias'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MiCategoria()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Sub-Categorias'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MiSubCategoria()),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}
