import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gamesphere/ProfileZone/ProfileDashboard.dart';

class SquadTab extends StatefulWidget {
  final String teamId;
  final bool isTeamAdmin;
  final int squadSize;

  const SquadTab({
    super.key,
    required this.teamId,
    required this.isTeamAdmin,
    required this.squadSize,
  });
@override
  State<SquadTab> createState() => _SquadTabState();
}

class _SquadTabState extends State<SquadTab> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        if(widget.isTeamAdmin) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _showAddPlayerDialog(widget.squadSize),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  spacing: 5.0,
                  children: [
                    Icon(Icons.person_add),
                    Text("Add Player", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('teams').doc(widget.teamId).collection('players')
              .orderBy('number', descending: false).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var players = snapshot.data!.docs;

              if (players.isEmpty) {
                return const Center(child: Text("No players registered yet.", style: TextStyle(color: Colors.white24)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  var player = players[index].data() as Map<String, dynamic>;
                  String docId = players[index].id;
                  bool isLinked = player['is_linked'] ?? false;

                  if(isLinked && player['user_id'] != null){
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').doc(player['user_id']).snapshots(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return const SizedBox.shrink();
                        var userData = userSnapshot.data?.data();

                        return _buildPlayerTile(
                          name: "${userData?['firstname'] ?? "Unknown Player"} ${userData?['lastname'] ?? ""}",
                          imageUrl: userData?['logo_url'],
                          position: player['position'] ?? "",
                          number: player['number']?.toString() ?? "",
                          isLinked: true,
                          userId: player['user_id'],
                          docId: docId,
                          isTeamAdmin: widget.isTeamAdmin,
                          squadSize: widget.squadSize
                        );
                      },
                    );
                  }
                  else{
                    return _buildPlayerTile(
                      name: player['name'] ?? "Unknown Player",
                      imageUrl: null,
                      position: player['position'] ?? "",
                      number: player['number']?.toString() ?? "",
                      isLinked: false,
                      docId: docId,
                      isTeamAdmin: widget.isTeamAdmin,
                      squadSize: widget.squadSize
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTile({
    required String name,
    String? imageUrl,
    required String position,
    required String number,
    required bool isLinked,
    String? userId,
    required String docId,
    required bool isTeamAdmin,
    required int squadSize,
  }) {
    return Card(
      color: const Color(0xFF1E1E24),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: isLinked ? () {
          if(userId != null) Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileDashboard(personId: userId)));
        } : null,
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
          child: (imageUrl == null || imageUrl.isEmpty) ? const Icon(Icons.person, color: Colors.blueAccent) : null,
        ),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("$position #$number", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: isTeamAdmin ? IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () async{
            try{
              await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).collection('players').doc(docId).delete();
              await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).update({'squad_size': FieldValue.increment(-1)});
              if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Player deleted successfully!", style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xFF1E1E24),
                ));
              }
            } catch(e){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Something went wrong.", style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF1E1E24),
              ));
            }
          },
        ) : (isLinked ? const Icon(Icons.chevron_right, color: Colors.white24) : null),
      ),
    );
  }

  void _showAddPlayerDialog(int squadSize) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController posController = TextEditingController();
    bool isLoading = false;

    Future<void> _handlePlayerAdd(StateSetter setDialogState, {required bool isLinked, String? uid, String? name, String? num, String? pos})
    async{
      setDialogState(() => isLoading = true);

      try {
        Map<String, dynamic> playerData = {
          'added_at': FieldValue.serverTimestamp(),
          'number': int.tryParse(num ?? "0") ?? 0,
          'position': pos ?? "",
        };

        if (isLinked) {
          if (uid == null || uid.isEmpty) return;
          var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid.trim()).get();
          if (!userDoc.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User not found.", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1E1E24))
            );
            return;
          }
          playerData['user_id'] = uid.trim();
          playerData['is_linked'] = true;
        } else {
          if (name == null || name.isEmpty) return;
          playerData['name'] = name.trim();
          playerData['is_linked'] = false;
        }

        await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).collection('players').add(playerData);
        await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).update({'squad_size': FieldValue.increment(1)});

        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong!", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1E1E24))
        );
      } finally {
        setDialogState(() => isLoading = false);
      }
    }

    Widget _buildDialogField(String label, TextEditingController controller, {bool isNumber = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            TextField(
              controller: controller,
              keyboardType: isNumber? TextInputType.number : TextInputType.text,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0E0E12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return DefaultTabController(
            length: 2,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E24),
              title: const Text("Add to Squad", style: TextStyle(color: Colors.white)),
              content: SizedBox(
                height: 300,
                width: 400,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [Tab(text: "Import ID"), Tab(text: "Manual")],
                      indicatorColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Column(
                            children: [
                              _buildDialogField("User ID", idController),
                              Row(
                                children: [
                                  Expanded(child: _buildDialogField("Kit #", numberController, isNumber: true)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildDialogField("Position", posController)),
                                ],
                              ),
                              const Spacer(),
                              isLoading? const CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _handlePlayerAdd(
                                    setDialogState, 
                                    isLinked: true, 
                                    uid: idController.text,
                                    num: numberController.text,
                                    pos: posController.text,
                                  ),
                                  child: const Text("Add Player"),
                                ),
                            ],
                          ),
                          // --- TAB 2: MANUAL ---
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildDialogField("Full Name", nameController),
                                Row(
                                  children: [
                                    Expanded(child: _buildDialogField("Kit #", numberController, isNumber: true)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildDialogField("Position", posController)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                isLoading? const CircularProgressIndicator()
                                : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _handlePlayerAdd(
                                    setDialogState, 
                                    isLinked: false, 
                                    name: nameController.text,
                                    num: numberController.text,
                                    pos: posController.text,
                                  ),
                                  child: const Text("Add Player"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}