import 'package:flutter/material.dart';
import '../../models/game_mode.dart';
import '../../models/difficulty_level.dart';
import '../../screens/loading_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/grid_selection_screen.dart';
import '../../screens/game_screen.dart';
import '../../screens/game_mechanics_screen.dart';
import '../../screens/leaderboard_screen.dart';
import '../../screens/point_system_screen.dart';

class AppRouter {
  static const String loading = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String gridSelection = '/grid-selection';
  static const String game = '/game';
  static const String gameMechanics = '/game-mechanics';
  static const String leaderboard = '/leaderboard';
  static const String pointSystem = '/point-system';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loading:
        return MaterialPageRoute(builder: (_) => const LoadingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case gridSelection:
        return MaterialPageRoute(builder: (_) => const GridSelectionScreen());
      case game:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GameScreen(
            rows: args['rows'] as int,
            columns: args['columns'] as int,
            gameMode: args['gameMode'] as GameMode,
            difficultyLevel: args['difficultyLevel'] as DifficultyLevel,
          ),
        );
      case gameMechanics:
        return MaterialPageRoute(builder: (_) => const GameMechanicsScreen());
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case pointSystem:
        return MaterialPageRoute(builder: (_) => const PointSystemScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
