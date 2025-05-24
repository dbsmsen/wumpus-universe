import 'package:flutter/material.dart';
import 'package:wumpus_universe/models/game_mode.dart';
import 'package:wumpus_universe/models/difficulty_level.dart';
import 'package:wumpus_universe/widgets/info_tooltip.dart';

class GameSettingsSection extends StatelessWidget {
  final GameMode? selectedGameMode;
  final DifficultyLevel? selectedDifficulty;
  final Function(GameMode) onGameModeSelected;
  final Function(DifficultyLevel) onDifficultySelected;
  final VoidCallback onPlayClickSound;

  const GameSettingsSection({
    super.key,
    required this.selectedGameMode,
    required this.selectedDifficulty,
    required this.onGameModeSelected,
    required this.onDifficultySelected,
    required this.onPlayClickSound,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text(
            'Game Mode',
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
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: GameMode.modes.map((mode) {
            return InfoTooltip(
              message: mode.description,
              child: ElevatedButton.icon(
                onPressed: () {
                  onPlayClickSound();
                  onGameModeSelected(mode);
                },
                icon: Icon(mode.icon),
                label: Text(mode.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedGameMode == mode
                      ? mode.color
                      : mode.color.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            'Difficulty Level',
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
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: DifficultyLevel.levels.map((level) {
            return InfoTooltip(
              message: level.description,
              child: ElevatedButton(
                onPressed: () {
                  onPlayClickSound();
                  onDifficultySelected(level);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedDifficulty == level
                      ? level.color
                      : level.color.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(level.name),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
