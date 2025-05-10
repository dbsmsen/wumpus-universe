import 'package:flutter/material.dart';

class GameMechanicsScreen extends StatelessWidget {
  const GameMechanicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 32,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Game Mechanics',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Master the art of cave exploration',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      'Hazards in the Cave',
                      'Beware of these dangers that lurk in the darkness',
                      [
                        _buildMechanicItem(
                          'Wumpus',
                          'A dangerous creature that will kill you if you enter its room. Use your arrow wisely to eliminate it.',
                          Icons.warning,
                          Colors.red,
                          [
                            'Deadly on contact',
                            'Can be killed with an arrow',
                            'Emits stench in adjacent rooms'
                          ],
                        ),
                        _buildMechanicItem(
                          'Pit',
                          'A bottomless pit that will kill you if you fall into it. Watch out for the breeze that warns of its presence.',
                          Icons.arrow_downward,
                          Colors.deepPurple,
                          [
                            'Instant death on contact',
                            'Creates breeze in adjacent rooms',
                            'Cannot be eliminated'
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    _buildSection(
                      'Sensory Indicators',
                      'Use these clues to navigate safely through the cave',
                      [
                        _buildMechanicItem(
                          'Stench',
                          'A foul smell indicates the presence of the Wumpus in an adjacent room. Use this to track and avoid or hunt the Wumpus.',
                          Icons.air,
                          Colors.orange,
                          [
                            'Indicates adjacent Wumpus',
                            'Not diagonal',
                            'Disappears when Wumpus is killed'
                          ],
                        ),
                        _buildMechanicItem(
                          'Breeze',
                          'A cool breeze warns you of a nearby pit. Be careful when you feel this sensation!',
                          Icons.wind_power,
                          Colors.blue,
                          [
                            'Indicates adjacent pit',
                            'Not diagonal',
                            'Always present near pits'
                          ],
                        ),
                        _buildMechanicItem(
                          'Glitter',
                          'A sparkling light indicates the presence of gold in the current room. This is your main objective!',
                          Icons.star,
                          Colors.amber,
                          [
                            'Indicates gold in current room',
                            'Pick up to collect',
                            'Required for victory'
                          ],
                        ),
                        _buildMechanicItem(
                          'Bump',
                          'A solid wall blocks your path. You cannot move through walls.',
                          Icons.wallpaper,
                          Colors.grey,
                          [
                            'Indicates wall collision',
                            'Movement blocked',
                            'No damage taken'
                          ],
                        ),
                        _buildMechanicItem(
                          'Scream',
                          'A horrible scream echoes through the cave when you successfully shoot the Wumpus. The path is now safe!',
                          Icons.volume_up,
                          Colors.red,
                          [
                            'Indicates Wumpus death',
                            'Heard throughout cave',
                            'Stench disappears'
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    _buildSection(
                      'Game Rules',
                      'Follow these rules to achieve victory',
                      [
                        _buildMechanicItem(
                          'Movement',
                          'Navigate the cave using four directional movements. Plan your path carefully to avoid hazards.',
                          Icons.directions,
                          Colors.green,
                          [
                            'Move in four directions',
                            'Cannot move through walls',
                            'One step at a time'
                          ],
                        ),
                        _buildMechanicItem(
                          'Shooting',
                          'You have one arrow to eliminate the Wumpus. Aim carefully in the direction you are facing.',
                          Icons.arrow_forward,
                          Colors.red,
                          [
                            'One arrow only',
                            'Shoot in facing direction',
                            'Kills Wumpus on hit'
                          ],
                        ),
                        _buildMechanicItem(
                          'Victory Conditions',
                          'To win the game, you must collect the gold and return to the starting position safely.',
                          Icons.emoji_events,
                          Colors.amber,
                          [
                            'Collect the gold',
                            'Return to start',
                            'Avoid all hazards'
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    _buildSection(
                      'Pro Tips',
                      'Use these strategies to improve your chances of success',
                      [
                        _buildMechanicItem(
                          'Safe Exploration',
                          'Always check for stench and breeze before moving. If you detect both, the room is likely safe.',
                          Icons.lightbulb,
                          Colors.yellow,
                          [
                            'Check adjacent rooms first',
                            'Use sensory clues',
                            'Plan your route'
                          ],
                        ),
                        _buildMechanicItem(
                          'Wumpus Hunting',
                          'When you detect stench, you can either avoid the Wumpus or hunt it. Choose wisely!',
                          Icons.gps_fixed,
                          Colors.orange,
                          [
                            'Track stench patterns',
                            'Save arrow for sure shots',
                            'Consider avoiding instead'
                          ],
                        ),
                        _buildMechanicItem(
                          'Efficient Navigation',
                          'Remember your path and use it to return to the start after collecting the gold.',
                          Icons.map,
                          Colors.blue,
                          [
                            'Remember your route',
                            'Plan return path',
                            'Avoid revisiting rooms'
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMechanicItem(String title, String description, IconData icon,
      Color color, List<String> tips) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                ...tips
                    .map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                color: color,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
