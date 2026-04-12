import 'dart:math';
import 'package:flutter/material.dart';

class KnockoutTab extends StatefulWidget {
  final Map<String, dynamic> tournamentData;

  const KnockoutTab({super.key, required this.tournamentData});

  @override
  State<KnockoutTab> createState() => _KnockoutTabState();
}

class _KnockoutTabState extends State<KnockoutTab> {
  late int qualifies;
  late int totalRounds;

  @override
  void initState() {
    super.initState();
    // Default to 8 if data is missing for safety
    qualifies = widget.tournamentData['qualifies_to_KO'] ?? 8;
    
    // Ensure qualifies is a power of 2, fallback if something is corrupted
    if (qualifies < 2) qualifies = 2;
    totalRounds = (log(qualifies) / log(2)).ceil();
  }

  String _getRoundName(int roundIndex) {
    if (roundIndex == totalRounds - 1) return "FINAL";
    if (roundIndex == totalRounds - 2) return "SEMI-FINALS";
    if (roundIndex == totalRounds - 3) return "QUARTER-FINALS";
    return "ROUND OF ${pow(2, totalRounds - roundIndex)}";
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total height needed based on number of matches in Round 1
    int initialMatches = qualifies ~/ 2;
    double requiredHeight = max(initialMatches * 100.0, MediaQuery.of(context).size.height * 0.7);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: InteractiveViewer(
        constrained: false, // Allows the content to overflow and be pan-able
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.4,
        maxScale: 2.0,
        child: Container(
          height: requiredHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ROUND TITLES ROW ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(totalRounds * 2 - 1, (index) {
                  // Even indices are Columns, Odd indices are Connectors
                  if (index % 2 != 0) {
                    return const SizedBox(width: 50); // Connector width
                  }
                  int roundIndex = index ~/ 2;
                  return SizedBox(
                    width: 220, // Card width
                    child: Center(
                      child: Text(
                        _getRoundName(roundIndex),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              
              // --- BRACKET TREE ROW ---
              Expanded(
                child: Row(
                  children: List.generate(totalRounds * 2 - 1, (index) {
                    if (index % 2 != 0) {
                      // DRAW CONNECTOR LINES
                      int prevRoundMatches = initialMatches ~/ pow(2, index ~/ 2);
                      return _buildConnectorColumn(prevRoundMatches);
                    } else {
                      // DRAW MATCH COLUMN
                      int roundIndex = index ~/ 2;
                      int matchCount = initialMatches ~/ pow(2, roundIndex);
                      return _buildMatchColumn(matchCount, roundIndex);
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Column containing the Match Cards
  Widget _buildMatchColumn(int matchCount, int roundIndex) {
    return SizedBox(
      width: 220,
      child: Column(
        children: List.generate(matchCount, (index) {
          // Wrap in Expanded so the mathematical centers align perfectly with the CustomPainter
          return Expanded(
            child: Center(
              child: _buildDummyMatchCard(roundIndex, index),
            ),
          );
        }),
      ),
    );
  }

  // Column containing the Drawn Lines
  Widget _buildConnectorColumn(int leftMatchesCount) {
    return SizedBox(
      width: 50,
      child: CustomPaint(
        painter: BracketConnectorPainter(leftMatchesCount: leftMatchesCount),
        child: Container(),
      ),
    );
  }

  // A sleek, premium looking match card UI
  Widget _buildDummyMatchCard(int roundIndex, int matchIndex) {
    // Generate some deterministic visual flair for the dummy data
    bool isCompleted = roundIndex < totalRounds - 1; // Earlier rounds are "done"
    bool homeWon = (matchIndex + roundIndex) % 2 == 0;
    
    return Container(
      width: 220,
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // HOME TEAM
          _teamRow(
            "TBD (Slot ${matchIndex * 2 + 1})", 
            isCompleted ? (homeWon ? "2" : "0") : "-", 
            isCompleted && homeWon
          ),
          const Divider(height: 1, color: Colors.white10),
          // AWAY TEAM
          _teamRow(
            "TBD (Slot ${matchIndex * 2 + 2})", 
            isCompleted ? (!homeWon ? "3" : "1") : "-", 
            isCompleted && !homeWon
          ),
        ],
      ),
    );
  }

  Widget _teamRow(String name, String score, bool isWinner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.shield, size: 16, color: Colors.white24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isWinner ? Colors.white : Colors.white60,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            score,
            style: TextStyle(
              color: isWinner ? Colors.blueAccent : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// The CustomPainter that mathematically draws perfect connecting lines 
/// regardless of the screen height or number of matches.
class BracketConnectorPainter extends CustomPainter {
  final int leftMatchesCount;
  final Color color;

  BracketConnectorPainter({required this.leftMatchesCount, this.color = Colors.white24});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    double w = size.width;
    double h = size.height;

    // Matches the exact centers of Flutter's "Expanded" widgets
    double getCenterY(int itemCount, int index) {
      return h / (itemCount * 2) * (index * 2 + 1);
    }

    // We step by 2 because we connect pairs of matches into 1
    for (int i = 0; i < leftMatchesCount; i += 2) {
      double y1 = getCenterY(leftMatchesCount, i);
      double y2 = getCenterY(leftMatchesCount, i + 1);
      
      // The exact center where the next round's match will be sitting
      double midY = (y1 + y2) / 2; 

      Path path = Path();
      
      // Draw top hook
      path.moveTo(0, y1);
      path.lineTo(w / 2, y1);
      path.lineTo(w / 2, y2);
      
      // Draw bottom hook
      path.lineTo(0, y2);
      
      // Draw middle connector pointing to the right
      path.moveTo(w / 2, midY);
      path.lineTo(w, midY);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}