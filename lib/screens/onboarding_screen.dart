import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialPages = [
    {
      'title': 'Welcome to Wumpus World!',
      'description':
          'Navigate through a cave system to find gold while avoiding dangers.',
      'image': 'assets/images/tutorial_1.png',
      'rules': [
        'Navigate through a 4x4 grid cave system',
        'Find the hidden gold and return safely',
        'Use your senses to detect dangers',
        'Score points for successful exploration',
      ],
    },
    {
      'title': 'Find the Gold',
      'description':
          'Navigate through the cave to find the hidden gold and return safely.',
      'image': 'assets/images/tutorial_2.png',
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
      'image': 'assets/images/tutorial_3.png',
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
      'image': 'assets/images/tutorial_4.png',
      'rules': [
        'Breeze indicates a pit in an adjacent room',
        'Stench means the Wumpus is nearby',
        'Glitter appears when gold is in your room',
        'Bump occurs when you hit a wall',
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildRuleItem(String rule, int index) {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialPages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _tutorialPages[index]['image']!,
                            height: 200,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            _tutorialPages[index]['title']!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _tutorialPages[index]['description']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ...(_tutorialPages[index]['rules'] as List<String>)
                              .map((rule) => _buildRuleItem(
                                    rule,
                                    _tutorialPages[index]['rules']
                                        .indexOf(rule),
                                  )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Previous',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  Row(
                    children: List.generate(
                      _tutorialPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < _tutorialPages.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Finish',
                        style: TextStyle(color: Colors.white),
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
