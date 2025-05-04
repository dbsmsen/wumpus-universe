import 'package:flutter/material.dart';
import 'grid_selection_screen.dart';

class InitialOnboardingScreen extends StatefulWidget {
  const InitialOnboardingScreen({super.key});

  @override
  State<InitialOnboardingScreen> createState() =>
      _InitialOnboardingScreenState();
}

class _InitialOnboardingScreenState extends State<InitialOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _welcomePages = [
    {
      'title': 'Welcome to Wumpus World!',
      'description':
      'Navigate through a cave system to find gold while avoiding dangers.',
      'image': 'assets/images/agent.png',
      'gradientColors': [
        const Color(0xFF1A237E), // Deep Indigo
        const Color(0xFF3949AB), // Indigo
        const Color(0xFF5C6BC0), // Light Indigo
      ],
      'rules': [
        'Navigate through a 4x6 grid cave system',
        'Find the hidden gold and return safely',
        'Use your senses to detect dangers',
        'Score points for successful exploration',
      ],
    },
    {
      'title': 'Find the Gold',
      'description':
      'Navigate through the cave to find the hidden gold and return safely.',
      'image': 'assets/images/gold.png',
      'gradientColors': [
        const Color(0xFFBF360C), // Deep Orange
        const Color(0xFFE64A19), // Orange
        const Color(0xFFFF7043), // Light Orange
      ],
      'rules': [
        'Gold is hidden in one of the cave rooms',
        'You must pick up the gold to win',
        'Return to your starting position after finding gold',
        '+1000 points for successful gold retrieval',
      ],
    },
    {
      'title': 'Beware of Dangers',
      'description':
      'Watch out for pits and the Wumpus! Use your senses to detect them.',
      'image': 'assets/images/wumpus.png',
      'gradientColors': [
        const Color(0xFF880E4F), // Deep Red
        const Color(0xFFC2185B), // Pink
        const Color(0xFFEC407A), // Light Pink
      ],
      'rules': [
        'Pits are deadly - falling in means game over',
        'The Wumpus can be killed with your arrow',
        'You only have one arrow per game',
        '-1000 points for falling into a pit or being eaten',
      ],
    },
    {
      'title': 'Use Your Senses',
      'description':
      'Feel the breeze near pits, smell the stench near the Wumpus, and see the glitter of gold.',
      'image': 'assets/images/glitter.png',
      'gradientColors': [
        const Color(0xFF006064), // Deep Teal
        const Color(0xFF00897B), // Teal
        const Color(0xFF4DB6AC), // Light Teal
      ],
      'rules': [
        'Breeze indicates a pit in an adjacent room',
        'Stench means the Wumpus is nearby',
        'Glitter appears when gold is in your room',
        'Bump occurs when you hit a wall',
      ],
    },
    {
      'title': 'Begin Your Adventure',
      'description':
      'Are you ready to explore the mysterious cave system and find the hidden gold?',
      'image': 'assets/images/agent.png',
      'gradientColors': [
        const Color(0xFF1A237E), // Deep Indigo
        const Color(0xFF3949AB), // Indigo
        const Color(0xFF5C6BC0), // Light Indigo
      ],
      'rules': [
        'Use your knowledge to navigate safely',
        'Remember to use your senses wisely',
        'Be careful with your arrow',
        'Good luck on your adventure!',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildRuleItem(String rule, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rule,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GridSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _welcomePages[_currentPage]['gradientColors'],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _welcomePages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemBuilder: (context, index) {
                    final bool isLastPage = index == _welcomePages.length - 1;
                    return SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _welcomePages[index]['gradientColors'],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Spacer(flex: 2),
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: ScaleTransition(
                                          scale: _scaleAnimation,
                                          child: Hero(
                                            tag: 'onboarding_image_$index',
                                            child: Image.asset(
                                              _welcomePages[index]['image']!,
                                              height: isLastPage ? 200 : 180,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.3),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: _animationController,
                                            curve: Curves.easeOutCubic,
                                          )),
                                          child: Text(
                                            _welcomePages[index]['description']!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black26,
                                                  offset: Offset(1, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  ...(_welcomePages[index]['rules']
                                  as List<String>)
                                      .map((rule) => _buildRuleItem(
                                    rule,
                                    _welcomePages[index]['rules']
                                        .indexOf(rule),
                                  )),
                                  const Spacer(flex: 3),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 60.0,
                                  bottom: 60.0,
                                  left: 20.0,
                                  right: 20.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      _welcomePages[index]['gradientColors'][0]
                                          .withOpacity(0.9),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return FadeTransition(
                                          opacity: _fadeAnimation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.3),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: _animationController,
                                              curve: Curves.easeOutCubic,
                                            )),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    if (_currentPage > 0)
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          _pageController
                                                              .previousPage(
                                                            duration:
                                                            const Duration(
                                                                milliseconds:
                                                                500),
                                                            curve: Curves
                                                                .easeInOutCubic,
                                                          );
                                                        },
                                                        icon: const Icon(
                                                            Icons
                                                                .arrow_back_ios,
                                                            color: Colors.white,
                                                            size: 16),
                                                        label: const Text(
                                                          'Prev',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    const SizedBox(width: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: List.generate(
                                                        _welcomePages.length,
                                                            (index) =>
                                                            AnimatedContainer(
                                                              duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                  300),
                                                              margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  4),
                                                              width: _currentPage ==
                                                                  index
                                                                  ? 24
                                                                  : 8,
                                                              height: 8,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: _currentPage ==
                                                                    index
                                                                    ? Colors.white
                                                                    : Colors.white
                                                                    .withOpacity(
                                                                    0.3),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    4),
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 20),
                                                    if (_currentPage <
                                                        _welcomePages.length -
                                                            1)
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          _pageController
                                                              .nextPage(
                                                            duration:
                                                            const Duration(
                                                                milliseconds:
                                                                500),
                                                            curve: Curves
                                                                .easeInOutCubic,
                                                          );
                                                        },
                                                        icon: const Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.white,
                                                            size: 16),
                                                        label: const Text(
                                                          'Next',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      ElevatedButton.icon(
                                                        onPressed: _startGame,
                                                        icon: const Icon(
                                                            Icons
                                                                .play_arrow_rounded,
                                                            color: Colors.blue,
                                                            size: 18),
                                                        label: const Text(
                                                          'Start Game',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                          Colors.white,
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                            horizontal: 24,
                                                            vertical: 12,
                                                          ),
                                                          elevation: 8,
                                                          shadowColor:
                                                          Colors.black26,
                                                          shape:
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
