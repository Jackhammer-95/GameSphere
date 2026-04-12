import 'package:flutter/material.dart';

class reserveKnockoutTab extends StatelessWidget {
  final Map<String, dynamic> tournamentData;

  const reserveKnockoutTab({super.key, required this.tournamentData});

  @override
  Widget build(BuildContext context) {
    // Determine starting round based on qualifies_to_KO
    int qualifiesCount = (tournamentData['qualifies_to_KO'] ?? 4).toInt();
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F13), Color(0xFF1E1E24)],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildRounds(qualifiesCount),
        ),
      ),
    );
  }

  List<Widget> _buildRounds(int totalTeams) {
    List<Widget> rounds = [];
    int currentTeams = totalTeams;

    while (currentTeams >= 2) {
      String roundTitle = _getRoundTitle(currentTeams);
      rounds.add(_buildRoundColumn(roundTitle, currentTeams ~/ 2));
      
      // Add a connector spacer between rounds
      if (currentTeams > 2) {
        rounds.add(_buildConnectorSpacer());
      }
      currentTeams ~/= 2;
    }

    return rounds;
  }

  String _getRoundTitle(int teams) {
    if (teams == 2) return "FINAL";
    if (teams == 4) return "SEMI-FINALS";
    if (teams == 8) return "QUARTER-FINALS";
    return "ROUND OF $teams";
  }

  Widget _buildRoundColumn(String title, int matchCount) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Fill column with matches
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matchCount,
              itemBuilder: (context, index) => _buildBracketMatch(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketMatch() {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A32),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTeamRow("HOME TEAM", "3", isWinner: true),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          _buildTeamRow("AWAY TEAM", "1", isWinner: false),
        ],
      ),
    );
  }

  Widget _buildTeamRow(String name, String score, {required bool isWinner}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: isWinner ? Colors.blueAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.shield, size: 20, color: Colors.white24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isWinner ? Colors.white : Colors.white38,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            score,
            style: TextStyle(
              color: isWinner ? Colors.blueAccent : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorSpacer() {
    return SizedBox(
      width: 40,
      child: Center(
        child: Container(
          width: 20,
          height: 2,
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }
}