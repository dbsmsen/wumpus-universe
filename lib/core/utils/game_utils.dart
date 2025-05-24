import '../../models/grid.dart';
import '../../models/cell.dart';
import '../../core/constants/app_constants.dart';

class GameUtils {
  static int calculatePitCount(int rows, int cols) {
    return ((rows * cols) * 0.15).round();  // 15% of cells
  }

  static bool isValidGridSize(int size) {
    return size >= AppConstants.minGridSize && size <= AppConstants.maxGridSize;
  }

  static List<Cell> generateEmptyCells(int rows, int cols) {
    List<Cell> cells = [];
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        cells.add(Cell(x: x, y: y));
      }
    }
    return cells;
  }

  static Grid createInitialGrid(int rows, int cols) {
    return Grid(rows, cols);
  }
}
