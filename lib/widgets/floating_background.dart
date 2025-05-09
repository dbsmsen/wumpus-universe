import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingBackground extends StatefulWidget {
  const FloatingBackground({super.key});

  @override
  State<FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingBackgroundState extends State<FloatingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingImage> _floatingImages = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _initializeFloatingImages();
  }

  void _initializeFloatingImages() {
    final List<String> imageAssets = [
      'assets/images/wumpus.png',
      'assets/images/gold.png',
      'assets/images/pit.png',
      'assets/images/agent.png',
      'assets/images/glitter.png',
      'assets/images/breeze.png',
      'assets/images/stench.png',
    ];

    // Create more images with varied properties
    for (int i = 0; i < 20; i++) {
      // Increased number of images
      final double baseSize =
          25 + _random.nextDouble() * 60; // More size variation
      final double baseSpeed = 1.5 + _random.nextDouble() * 2.5;
      final double baseOpacity =
          0.1 + _random.nextDouble() * 0.3; // More opacity variation

      _floatingImages.add(
        FloatingImage(
          image: imageAssets[i % imageAssets.length],
          startX: _random.nextDouble() * 1.2 -
              0.1, // Wider spread with negative values
          startY: _random.nextDouble() * 1.2 -
              0.1, // Wider spread with negative values
          amplitude:
              (50 + _random.nextDouble() * 100).toDouble(), // Larger amplitude
          speed: baseSpeed,
          size: baseSize,
          opacity: baseOpacity,
          rotationSpeed:
              -3.0 + _random.nextDouble() * 6.0, // More dramatic rotation
          scaleSpeed: 2.0 + _random.nextDouble() * 3.0, // More dramatic scaling
          movementPattern: _random.nextInt(5), // More movement patterns
          phaseOffset:
              _random.nextDouble() * 2 * math.pi, // Random phase offset
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _floatingImages.map((floatingImage) {
            final double progress =
                _controller.value * 2 * math.pi * floatingImage.speed +
                    floatingImage.phaseOffset;

            // Calculate position based on movement pattern
            double x = floatingImage.startX * MediaQuery.of(context).size.width;
            double y =
                floatingImage.startY * MediaQuery.of(context).size.height;

            switch (floatingImage.movementPattern) {
              case 0: // Sine wave
                y += math.sin(progress) * floatingImage.amplitude;
                break;
              case 1: // Cosine wave
                x += math.cos(progress) * floatingImage.amplitude;
                break;
              case 2: // Combined movement
                x += math.cos(progress) * floatingImage.amplitude * 0.5;
                y += math.sin(progress) * floatingImage.amplitude * 0.5;
                break;
              case 3: // Figure 8 pattern
                x += math.sin(progress) * floatingImage.amplitude * 0.7;
                y += math.sin(progress * 2) * floatingImage.amplitude * 0.7;
                break;
              case 4: // Spiral pattern
                final double spiral = progress * 0.5;
                x += math.cos(spiral) *
                    floatingImage.amplitude *
                    (spiral / (2 * math.pi));
                y += math.sin(spiral) *
                    floatingImage.amplitude *
                    (spiral / (2 * math.pi));
                break;
            }

            // Calculate rotation and scale with more dramatic effects
            final double rotation = progress * floatingImage.rotationSpeed;
            final double scale = 0.6 +
                math.sin(progress * floatingImage.scaleSpeed) *
                    0.4; // More dramatic scaling

            // Add a subtle glow effect
            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white
                              .withOpacity(floatingImage.opacity * 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Opacity(
                      opacity: floatingImage.opacity,
                      child: Image.asset(
                        floatingImage.image,
                        width: floatingImage.size,
                        height: floatingImage.size,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class FloatingImage {
  final String image;
  final double startX;
  final double startY;
  final double amplitude;
  final double speed;
  final double size;
  final double opacity;
  final double rotationSpeed;
  final double scaleSpeed;
  final int movementPattern;
  final double phaseOffset;

  FloatingImage({
    required this.image,
    required this.startX,
    required this.startY,
    required this.amplitude,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.rotationSpeed,
    required this.scaleSpeed,
    required this.movementPattern,
    required this.phaseOffset,
  });
}
