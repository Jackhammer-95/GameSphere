import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/TheProvider.dart';

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
    //Getting participants to see who occupies which slot
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .snapshots(),
      builder: (context, partSnapshot) {
        if (partSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, String> slotToTeamId = {};
        if (partSnapshot.hasData) {
          for (var doc in partSnapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            if (data['team_id'] != null) {
              slotToTeamId["${data['group']}_${data['slot_index']}"] = data['team_id'];
            }
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).collection('matches')
              .orderBy('round').orderBy('order').snapshots(),
          builder: (context, matchSnapshot) {
            if (!matchSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            var matches = matchSnapshot.data!.docs;

            if (matches.isEmpty) {
              return const Center(child: Text("No fixtures generated.", style: TextStyle(color: Colors.white38)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              cacheExtent: max(context.screenHeight*4, 3000),
              itemBuilder: (context, index) {
                var match = matches[index].data() as Map<String, dynamic>;
                
                String homeSlotKey = "${match['group']}_${match['home_slot']}";
                String awaySlotKey = "${match['group']}_${match['away_slot']}";

                return _MatchCard(
                  match: match,
                  homeTeamId: slotToTeamId[homeSlotKey],
                  awayTeamId: slotToTeamId[awaySlotKey],
                  tournamentId: tournamentId,
                );
              },
            );
          },
        );
      }
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final String? homeTeamId;
  final String? awayTeamId;
  final String tournamentId;

  const _MatchCard({required this.match, this.homeTeamId, this.awayTeamId, required this.tournamentId});

  Future<Map<String, dynamic>> _fetchTeams() async {
    Map<String, dynamic> result = {
      'home': {'name': "TBD (Slot ${match['home_slot'] + 1})", 'logo': null},
      'away': {'name': "TBD (Slot ${match['away_slot'] + 1})", 'logo': null},
    };

    if (homeTeamId != null && homeTeamId!.isNotEmpty) {
      var doc = await FirebaseFirestore.instance.collection('teams').doc(homeTeamId).get();
      if (doc.exists) {
        result['home'] = {'name': doc['name'], 'logo': doc['logo_url']};
      }
    }

    if (awayTeamId != null && awayTeamId!.isNotEmpty) {
      var doc = await FirebaseFirestore.instance.collection('teams').doc(awayTeamId).get();
      if (doc.exists) {
        result['away'] = {'name': doc['name'], 'logo': doc['logo_url']};
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    
    void _showSnackBar(String text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text, style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E1E24))
      );
    }
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchTeams(),
      builder: (context, snapshot) {

        final homeData = snapshot.data?['home'] ?? {'name': "Loading...", 'logo': null};
        final awayData = snapshot.data?['away'] ?? {'name': "Loading...", 'logo': null};

        bool isCompleted = match['status'] == 'completed';
        String scoreDisplay = isCompleted ? "${match['home_score']} - ${match['away_score']}" : "VS";

        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: (){
                bool isHomeMissing = homeTeamId == null || homeTeamId!.isEmpty;
                bool isAwayMissing = awayTeamId == null || awayTeamId!.isEmpty;

                if (!isCompleted && (isHomeMissing || isAwayMissing)) {
                  _showSnackBar("Cannot enter scores until both teams are assigned.");
                  return;
                }

                _showScoreDialog(context, isCompleted, homeData['name'], awayData['name']);
              },
              child: Opacity(
                opacity: (!isCompleted && (homeTeamId == null || awayTeamId == null)) ? 0.5 : 1.0,
                child: Padding(
                  padding: context.isMobile 
                      ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8) 
                      : const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _StaticTeamBadge(name: homeData['name'], logoUrl: homeData['logo'])),
                      
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Group ${match['group']} • Round ${match['round']}", 
                            style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)
                          ),
                          const SizedBox(height: 8),
                          Text(scoreDisplay, 
                            style: TextStyle(
                              color: isCompleted ? Colors.white : Colors.blueAccent, 
                              fontSize: isCompleted ? 28 : 20, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      
                      // AWAY TEAM
                      Expanded(child: _StaticTeamBadge(name: awayData['name'], logoUrl: awayData['logo'])),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void _showScoreDialog(BuildContext context, bool isCompleted, String homeName, String awayName) {
    final TextEditingController homeController = TextEditingController(text: "${match['home_score'] ?? 0}");
    final TextEditingController awayController = TextEditingController(text: "${match['away_score'] ?? 0}");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Enter Match Result", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Column(
                  spacing: 5,
                  children: [
                    Text(homeName, style: TextStyle(color: Colors.blue, fontSize: 12, overflow: TextOverflow.ellipsis)),
                    _scoreField(homeController),
                  ],
                )),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Text("-", style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                Expanded(child: Column(
                  spacing: 5,
                  children: [
                    Text(awayName, style: TextStyle(color: Colors.blue, fontSize: 12, overflow: TextOverflow.ellipsis)),
                    _scoreField(awayController),
                  ],
                )),
              ],
            ),
          ],
        ),
        actions: [
          if(isCompleted) Padding(
            padding: EdgeInsets.all(context.isMobile? 4: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 186, 14, 2)),
              onPressed: () => _clearMatchResult(context),
              child: const Text("Clear Result", style: TextStyle(color: Colors.white)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(context.isMobile? 4: 8),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.isMobile? 4: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () async {
                    int newHomeScore = int.tryParse(homeController.text) ?? 0;
                    int newAwayScore = int.tryParse(awayController.text) ?? 0;
                    
                    bool wasCompleted = match['status'] == 'completed';
                    int? oldHomeScore = match['home_score'];
                    int? oldAwayScore = match['away_score'];
                
                    Map<String, int> getStats(int? myScore, int? oppScore, bool isDone) {
                      if (!isDone || myScore == null || oppScore == null) {
                        return {'p': 0, 'w': 0, 'd': 0, 'l': 0, 'pts': 0, 'gs': 0, 'gc': 0, 'gd': 0};
                      }
                      int w = myScore > oppScore ? 1 : 0;
                      int d = myScore == oppScore ? 1 : 0;
                      int l = myScore < oppScore ? 1 : 0;
                      return {
                        'p': 1,
                        'w': w,
                        'd': d,
                        'l': l,
                        'pts': (w * 3) + (d * 1),
                        'gs': myScore,
                        'gc': oppScore,
                        'gd': myScore - oppScore,
                      };
                    }
                
                    var oldHomeStats = getStats(oldHomeScore, oldAwayScore, wasCompleted);
                    var oldAwayStats = getStats(oldAwayScore, oldHomeScore, wasCompleted);
                
                    var newHomeStats = getStats(newHomeScore, newAwayScore, true);
                    var newAwayStats = getStats(newAwayScore, newHomeScore, true);
                
                    Map<String, dynamic> buildUpdateMap(Map<String, int> newS, Map<String, int> oldS) {
                      Map<String, dynamic> updates = {};
                      Map<String, int> differences = {
                        'played': newS['p']! - oldS['p']!,
                        'won': newS['w']! - oldS['w']!,
                        'drawn': newS['d']! - oldS['d']!,
                        'lost': newS['l']! - oldS['l']!,
                        'points': newS['pts']! - oldS['pts']!,
                        'scored': newS['gs']! - oldS['gs']!,
                        'conceded': newS['gc']! - oldS['gc']!,
                        'difference': newS['gd']! - oldS['gd']!,
                      };
                      
                      differences.forEach((key, value) {
                        if (value != 0) updates[key] = FieldValue.increment(value);
                      });
                      return updates;
                    }
                
                    var homeUpdates = buildUpdateMap(newHomeStats, oldHomeStats);
                    var awayUpdates = buildUpdateMap(newAwayStats, oldAwayStats);
                
                    WriteBatch batch = FirebaseFirestore.instance.batch();
                
                    DocumentReference matchRef = FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).collection('matches').doc(match['match_id']);
                    batch.update(matchRef, {
                      'home_score': newHomeScore,
                      'away_score': newAwayScore,
                      'status': 'completed',
                    });
                
                    String homeSlotId = "Group${match['group']}_Slot${match['home_slot']}";
                    DocumentReference homeRef = FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).collection('participants').doc(homeSlotId);
                    
                    if (homeUpdates.isNotEmpty) batch.update(homeRef, homeUpdates);
                
                    String awaySlotId = "Group${match['group']}_Slot${match['away_slot']}";
                    DocumentReference awayRef = FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).collection('participants').doc(awaySlotId);
                    
                    if (awayUpdates.isNotEmpty) batch.update(awayRef, awayUpdates);
                
                    await batch.commit();
                    
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("Save Result", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _clearMatchResult(BuildContext context) async {
    int oldHomeScore = match['home_score'] ?? 0;
    int oldAwayScore = match['away_score'] ?? 0;

    int w = oldHomeScore > oldAwayScore ? 1 : 0;
    int d = oldHomeScore == oldAwayScore ? 1 : 0;
    int l = oldHomeScore < oldAwayScore ? 1 : 0;

    Map<String, dynamic> buildReversal(int myS, int oppS, int win, int draw, int loss) {
      return {
        'played': FieldValue.increment(-1),
        'won': FieldValue.increment(-win),
        'drawn': FieldValue.increment(-draw),
        'lost': FieldValue.increment(-loss),
        'points': FieldValue.increment(-((win * 3) + (draw * 1))),
        'scored': FieldValue.increment(-myS),
        'conceded': FieldValue.increment(-oppS),
        'difference': FieldValue.increment(-(myS - oppS)),
      };
    }

    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference matchRef = FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).collection('matches').doc(match['match_id']);
        
    batch.update(matchRef, {
      'home_score': null,
      'away_score': null,
      'status': 'pending',
    });

    String homeSlotId = "Group${match['group']}_Slot${match['home_slot']}";
    DocumentReference homeRef = FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).collection('participants').doc(homeSlotId);
    
    batch.update(homeRef, buildReversal(oldHomeScore, oldAwayScore, w, d, l));

    String awaySlotId = "Group${match['group']}_Slot${match['away_slot']}";
    DocumentReference awayRef = FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).collection('participants').doc(awaySlotId);
    
    batch.update(awayRef, buildReversal(oldAwayScore, oldHomeScore, l, d, w));

    await batch.commit();
    if (context.mounted) Navigator.pop(context);
  }

  Widget _scoreField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
      ),
    );
  }
}

class _StaticTeamBadge extends StatelessWidget {
  final String name;
  final String? logoUrl;

  const _StaticTeamBadge({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          width: 40,
          child: (logoUrl != null && logoUrl!.isNotEmpty)
            ? Image.network(
                logoUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress){
                  if(loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 3.5),
                  );
                },
                errorBuilder: (context, error, stackTrace){
                  return const Icon(Icons.shield, color: Colors.white, size: 40);
                },
              )
            : const Icon(Icons.shield, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 8),
        Text(name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)
        ),
      ],
    );
  }
}