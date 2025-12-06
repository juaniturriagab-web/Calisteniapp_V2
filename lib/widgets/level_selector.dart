import 'package:flutter/material.dart';

class LevelSelector extends StatefulWidget {
  final ValueChanged<String> onSelected;
  const LevelSelector({super.key, required this.onSelected});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  String? selected;
  bool _isExpanded = false;

  final levels = ['Principiante', 'Intermedio', 'Avanzado'];

  final primary = const Color(0xFF0A4CFF); // color principal azul

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Nivel de calistenia',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // texto blanco
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 16.0),
            child: Wrap(
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
          ),
      ],
    );
  }
}
