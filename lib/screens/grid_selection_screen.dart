import 'package:flutter/material.dart';
import 'game_screen.dart';

class GridSelectionScreen extends StatefulWidget {
  const GridSelectionScreen({super.key});

  @override
  _GridSelectionScreenState createState() => _GridSelectionScreenState();
}

class _GridSelectionScreenState extends State<GridSelectionScreen> {
  List<List<int>> predefinedGrids = [
    [4, 4],  // Standard 4x4 grid
    [4, 6],  // 4x6 grid
    [5, 5],  // 5x5 grid
    [6, 6],  // 6x6 grid
  ];

  List<int> customGridSize = [4, 4];  // Default custom grid size

  void _showCustomGridDialog() {
    final rowController = TextEditingController(text: customGridSize[0].toString());
    final colController = TextEditingController(text: customGridSize[1].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Grid Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rowController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rows'),
            ),
            TextField(
              controller: colController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Columns'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                customGridSize = [
                  int.parse(rowController.text),
                  int.parse(colController.text)
                ];
              });
              Navigator.of(context).pop();
            },
            child: const Text('Set Grid'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Grid'),
        backgroundColor: Colors.deepPurple[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple[900]!,
              Colors.deepPurple[700]!,
              Colors.deepPurple[500]!,
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Choose Your Game Grid',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Predefined Grids',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: predefinedGrids.map((grid) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                rows: grid[0],
                                columns: grid[1],
                              ),
                            ),
                          );
                        },
                        child: Text('${grid[0]} x ${grid[1]}'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Custom Grid',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _showCustomGridDialog,
                    child: Text('Custom (${customGridSize[0]} x ${customGridSize[1]})'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            rows: customGridSize[0],
                            columns: customGridSize[1],
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Game with Selected Grid'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
