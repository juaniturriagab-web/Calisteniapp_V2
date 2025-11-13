import 'package:flutter/material.dart';

class LevelSelector extends StatefulWidget {
  final ValueChanged<String> onSelected;
  const LevelSelector({super.key, required this.onSelected});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  String? selected;

  final levels = [
    'Principiante',
    'Intermedio',
    'Avanzado'
  ];

  final primary = const Color(0xFF0A4CFF); // color principal azul

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nivel de calistenia',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white, // texto blanco
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: levels.map((lvl) {
            final isSelected = lvl == selected;
            return ChoiceChip(
              label: Text(
                lvl,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: primary,
              backgroundColor: Colors.blueGrey.shade800,
              onSelected: (_) {
                setState(() => selected = lvl);
                widget.onSelected(lvl);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
