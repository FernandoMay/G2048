import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 4, // Número de columnas en la cuadrícula
          children: <Widget>[
            // Aquí puedes generar dinámicamente los widgets para cada celda de la cuadrícula
            buildGridCell(2),
            buildGridCell(4),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(8),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
            buildGridCell(0),
          ],
        ),
      ),
    );
  }

  Widget buildGridCell(int number) {
    return Container(
      margin: const EdgeInsets.all(4),
      color: Colors
          .tealAccent, // Puedes personalizar el color de cada celda según el número
      child: Center(
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 32, color: Colors.white),
        ),
      ),
    );
  }
}
