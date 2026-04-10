import 'package:flutter/material.dart';
import 'package:gamesphere/TheProvider.dart'; // Ensure this is available for context.isMobile

class FixturesTab extends StatelessWidget {
  final String tournamentId;
  final Map<String, dynamic> tournamentData;

  const FixturesTab({
    super.key, 
    required this.tournamentId, 
    required this.tournamentData
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8, // Placeholder
      itemBuilder: (context, index) {
        return _matchCard(context);
      },
    );
  }

  Widget _matchCard(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: context.isMobile 
            ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8) 
            : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _teamInfo("REAL MADRID"),
            const SizedBox(
              width: 50,
              child: Text("0", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold))
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("VS", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("21:45", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
            const SizedBox(width: 20),
            const SizedBox(
              width: 50,
              child: Text("0", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold))
            ),
            _teamInfo("INTER MIAMI"),
          ],
        ),
      ),
    );
  }

  Widget _teamInfo(String name) {
    return Expanded(
      child: Column(
        children: [
          const Icon(Icons.shield, color: Colors.white24, size: 40),
          const SizedBox(height: 8),
          Text(name, 
            textAlign: TextAlign.center, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)
          ),
        ],
      ),
    );
  }
}