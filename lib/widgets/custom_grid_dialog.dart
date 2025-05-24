import 'package:flutter/material.dart';

class CustomGridDialog extends StatelessWidget {
  final List<int> initialGridSize;
  final Function(int rows, int cols) onGridSelected;
  final VoidCallback onPlaySound;

  const CustomGridDialog({
    super.key,
    required this.initialGridSize,
    required this.onGridSelected,
    required this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    final rowController = TextEditingController(text: initialGridSize[0].toString());
    final colController = TextEditingController(text: initialGridSize[1].toString());

    return AlertDialog(
      title: const Text('Custom Grid Size'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: rowController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Rows',
              hintText: 'Enter number of rows (max: 10)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: colController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Columns',
              hintText: 'Enter number of columns (max: 10)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onPlaySound();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onPlaySound();
            // Validate input
            final rows = int.tryParse(rowController.text);
            final cols = int.tryParse(colController.text);

            if (rows != null && cols != null && rows > 0 && cols > 0) {
              if (rows > 10 || cols > 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Grid size cannot exceed 10x10'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              onGridSelected(rows, cols);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter valid numbers greater than 0'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Set Grid'),
        ),
      ],
    );
  }
}
