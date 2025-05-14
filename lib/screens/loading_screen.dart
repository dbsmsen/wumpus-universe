import 'package:flutter/material.dart';
import 'package:wumpus_universe/screens/grid_selection_screen.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;
  bool _isLoading = true;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  bool _particlesInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GridSelectionScreen(),
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_particlesInitialized) {
      _initializeParticles();
      _startParticleAnimation();
      _particlesInitialized = true;
    }
  }

  void _initializeParticles() {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        size: _random.nextDouble() * 3 + 1,
        speedX: _random.nextDouble() * 2 - 1,
        speedY: _random.nextDouble() * 2 - 1,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  void _startParticleAnimation() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted) {
        setState(() {
          for (var particle in _particles) {
            particle.update();
          }
        });
        _startParticleAnimation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Shadowy overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Particles
            CustomPaint(
              painter: ParticlePainter(particles: _particles),
              size: Size.infinite,
            ),
            // Loading content
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Almost there...',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 300,
                      height: 10,
                      child: Stack(
                        children: [
                          // Background
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          // Glowing effect
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.lightBlue.withOpacity(
                                          0.7 * _glowAnimation.value),
                                      blurRadius: 15 * _glowAnimation.value,
                                      spreadRadius: 3 * _glowAnimation.value,
                                    ),
                                    BoxShadow(
                                      color: Colors.lightBlue.withOpacity(
                                          0.5 * _glowAnimation.value),
                                      blurRadius: 25 * _glowAnimation.value,
                                      spreadRadius: 5 * _glowAnimation.value,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 300 * _progressAnimation.value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.lightBlue.withOpacity(0.8),
                                        Colors.lightBlue.withOpacity(1.0),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.lightBlue.withOpacity(0.6),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color:
                                            Colors.lightBlue.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speedX;
  final double speedY;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });

  void update() {
    x += speedX;
    y += speedY;

    // Bounce off edges
    if (x < 0 || x > 1000) {
      x = x < 0 ? 0 : 1000;
    }
    if (y < 0 || y > 1000) {
      y = y < 0 ? 0 : 1000;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
