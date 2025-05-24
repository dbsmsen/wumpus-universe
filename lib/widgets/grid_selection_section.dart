import 'package:flutter/material.dart';
import 'package:wumpus_universe/widgets/custom_grid_dialog.dart';

class GridSelectionSection extends StatelessWidget {
  final List<List<int>> predefinedGrids;
  final List<int> customGridSize;
  final List<int>? selectedGridSize;
  final bool isCustomGridSelected;
  final bool isPredefinedGridSelected;
  final Function(List<int>) onPredefinedGridSelected;
  final Function(int rows, int cols) onCustomGridSelected;
  final VoidCallback onPlayClickSound;
  final VoidCallback onPlayGridSelectionSound;

  const GridSelectionSection({
    super.key,
    required this.predefinedGrids,
    required this.customGridSize,
    required this.selectedGridSize,
    required this.isCustomGridSelected,
    required this.isPredefinedGridSelected,
    required this.onPredefinedGridSelected,
    required this.onCustomGridSelected,
    required this.onPlayClickSound,
    required this.onPlayGridSelectionSound,
  });

  void _showCustomGridDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomGridDialog(
        initialGridSize: customGridSize,
        onGridSelected: onCustomGridSelected,
        onPlaySound: onPlayClickSound,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text(
            'Predefined Grids',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: predefinedGrids.map((grid) {
            bool isSelected = selectedGridSize != null &&
                selectedGridSize![0] == grid[0] &&
                selectedGridSize![1] == grid[1];
            return Opacity(
              opacity: isSelected ? 1.0 : 0.6,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isSelected ? 8 : 4,
                ),
                onPressed: () {
                  onPlayClickSound();
                  onPlayGridSelectionSound();
                  onPredefinedGridSelected(List.from(grid));
                },
                child: Text(
                  '${grid[0]} x ${grid[1]}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            'Custom Grid',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: isCustomGridSelected ? 1.0 : 0.6,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isCustomGridSelected ? 8 : 4,
            ),
            onPressed: () {
              onPlayClickSound();
              _showCustomGridDialog(context);
            },
            child: Text(
              'Custom (${customGridSize[0]} x ${customGridSize[1]})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
