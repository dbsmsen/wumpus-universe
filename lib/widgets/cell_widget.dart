import 'package:flutter/material.dart';
import '../models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final bool hasAgent;

  const CellWidget({super.key, required this.cell, this.hasAgent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: cell.visited ? Colors.white : Colors.grey[300],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasAgent) const Icon(Icons.person, color: Colors.blue),
          if (cell.hasGold) const Icon(Icons.star, color: Colors.amber),
          if (cell.hasPit) const Icon(Icons.circle, color: Colors.black),
          if (cell.hasWumpus) const Icon(Icons.warning, color: Colors.red),
        ],
      ),
    );
  }
}
