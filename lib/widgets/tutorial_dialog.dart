import 'package:flutter/material.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int currentPage = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> pages = [
    {
      'title': 'Welcome to Wumpus World!',
      'description':
          'Navigate through a cave system to find gold while avoiding dangers.',
      'image': 'assets/images/agent.png',
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
      'image': 'assets/images/wumpus_dead.png',
      'rules': [
        'Use your knowledge to navigate safely',
        'Remember to use your senses wisely',
        'Be careful with your arrow',
        'Good luck on your adventure!',
      ],
    },
  ];

  // Define color schemes for each page
  final List<Color> pageColors = [
    const Color(0xFF2C3E50), // Welcome page - Dark blue-gray
    const Color(0xFF8E44AD), // Find Gold page - Purple
    const Color(0xFFC0392B), // Dangers page - Red
    const Color(0xFF27AE60), // Senses page - Green
    const Color(0xFFF39C12), // Adventure page - Orange
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _pageController.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page ?? 0;
    setState(() {
      currentPage = page.floor();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tutorial',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent swiping
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  final title = page['title'] as String;
                  final description = page['description'] as String;
                  final image = page['image'] as String;
                  final rules = page['rules'] as List<String>;

                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              image,
                              height: 150,
                              alignment: Alignment.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            textWidthBasis: TextWidthBasis.longestLine,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            textWidthBasis: TextWidthBasis.longestLine,
                          ),
                          const SizedBox(height: 24),
                          ...rules
                              .map((rule) => Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.25),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '${rules.indexOf(rule) + 1}',
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
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentPage > 0)
                    TextButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 16),
                      label: const Text(
                        'Prev',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80), // Placeholder for alignment
                  SizedBox(
                    width: 120, // Fixed width for dots container
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: currentPage == dotIndex ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: currentPage == dotIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (currentPage < pages.length - 1)
                    TextButton.icon(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 16),
                      label: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.play_arrow_rounded,
                          color: Colors.blue, size: 18),
                      label: const Text(
                        'Start Game',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 8,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
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
