import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/structures/Team%20Profile/TeamProfile.dart';

class buildPointsTableTab extends StatefulWidget {
  final Map<String, dynamic> data;

  const buildPointsTableTab({super.key, required this.data});

  @override
  State<buildPointsTableTab> createState() => _buildPointsTableTabState();
}

class _buildPointsTableTabState extends State<buildPointsTableTab>{

  @override
  Widget build(BuildContext context){
    int participantCount = widget.data['participant_count'] ?? 0;

    if (participantCount == 0) {
      return _buildEmptySection();
    }

    int groupCount = widget.data['no_of_groups'] ?? 0;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groupCount,
      cacheExtent: context.screenHeight*3,
      itemBuilder: (context, index){
        String groupName = String.fromCharCode(65+index);

        return Column(
          children: [
            _buildSingleGroupTable(context, "GROUP $groupName"),
            const SizedBox(height: 32)
          ],
        );
      },
    );
  }

  Widget _buildSingleGroupTable(BuildContext context, String title) {
    String groupidentifier = title.split(" ")[1];

    DataCell buildCenterCell(int value){
      return DataCell(SizedBox(width:context.isMobile? 45:90, child: Text("$value", style: TextStyle(color: Colors.white), textAlign: TextAlign.center)));
    }

    DataColumn buildCenterColumn(String text){
      return DataColumn(label: SizedBox(width:context.isMobile?45: 90, child: Text(text, textAlign: TextAlign.center)));
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tournaments').doc(widget.data['tournament_id']).collection('participants')
      .where('group', isEqualTo: groupidentifier).orderBy('points', descending: true).orderBy('difference', descending: true)
      .orderBy('scored', descending: true).orderBy('slot_index', descending: false).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFF1E1E24)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.purple),
                      columnSpacing: 0,
                      horizontalMargin: 15,
                      columns: [
                        DataColumn(label: SizedBox(width: 150, child: Text("TEAM NAME", textAlign: TextAlign.center))),
                      ],
                      rows: List.generate(snapshot.data!.docs.length, (index) {
                        var participant = snapshot.data!.docs[index];
                        String teamId = participant['team_id'];
                        
                        return DataRow(
                          cells: [
                            DataCell(StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('teams').doc(teamId).snapshots(),
                              builder: (context, teamSnapshot) {
                                String teamName = "Loading...";
                                String? logoUrl;

                                if (teamSnapshot.hasData && teamSnapshot.data!.exists) {
                                  var teamData = teamSnapshot.data!.data() as Map<String, dynamic>;
                                  teamName = teamData['name'] ?? "Unknown Team";
                                  logoUrl = teamData['logo_url'];
                                }

                                return Row(
                                  children: [
                                    Text("${index + 1} ", style: const TextStyle(color: Colors.grey)),
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child:(logoUrl != null && logoUrl.isNotEmpty)
                                      ? Image.network(logoUrl, fit: BoxFit.contain)
                                      : const Icon(Icons.shield, color: Colors.white38)
                                    ),
                                    const SizedBox(width: 5),
                                    InkWell(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDashboard(teamId: teamId))),
                                      child: SizedBox(
                                        width: context.isMobile? 130 :140,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(teamName, style: const TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            )),
                          ]
                        );
                      }),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.purple),
                          columnSpacing: 0,
                          horizontalMargin: 15,
                          headingTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          columns: [
                            buildCenterColumn(context.isMobile? "P":"PLAYED"),
                            buildCenterColumn(context.isMobile? "W":"WON"),
                            buildCenterColumn(context.isMobile? "D":"DRAWN"),
                            buildCenterColumn(context.isMobile? "L":"LOST"),
                            buildCenterColumn(context.isMobile? "PTS":"POINTS"),
                            buildCenterColumn(context.isMobile? "GS":"GOALS\nSCORED"),
                            buildCenterColumn(context.isMobile? "GC":"GOALS\nCONCECDED"),
                            buildCenterColumn(context.isMobile? "GD":"GOAL\nDIFFERENCE"),
                          ],
                          rows: List.generate(snapshot.data!.docs.length, (index){
                            var team = snapshot.data!.docs[index];

                            return DataRow(
                              cells: [
                                buildCenterCell(team['played'] ?? 0),
                                buildCenterCell(team['won'] ?? 0),
                                buildCenterCell(team['drawn'] ?? 0),
                                buildCenterCell(team['lost'] ?? 0),
                                DataCell(SizedBox(width:context.isMobile? 45:90, child: Text("${team['points']?? 0}",style: TextStyle(
                                  color: Colors.blueAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center
                                ))),
                                buildCenterCell(team['scored'] ?? 0),
                                buildCenterCell(team['conceded'] ?? 0),
                                buildCenterCell(team['difference'] ?? 0),
                              ]
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildEmptySection(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_list_numbered, size: 100, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text("ADD PARTICIPANTS TO SEE STANDINGS", style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }
}