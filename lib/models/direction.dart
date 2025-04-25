// Direction enum definition
enum Direction { up, down, left, right }

extension DirectionExtension on Direction {
  // Get the horizontal change (dx) for movement
  int get dx {
    switch (this) {
      case Direction.left:
        return -1;
      case Direction.right:
        return 1;
      default:
        return 0;
    }
  }

  // Get the vertical change (dy) for movement
  int get dy {
    switch (this) {
      case Direction.up:
        return -1;
      case Direction.down:
        return 1;
      default:
        return 0;
    }
  }

  // Get the string name for each direction
  String get name {
    switch (this) {
      case Direction.up:
        return "Up";
      case Direction.down:
        return "Down";
      case Direction.left:
        return "Left";
      case Direction.right:
        return "Right";
    }
  }
}
