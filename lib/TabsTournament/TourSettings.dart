import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:gamesphere/widgets/DeleteTournament.dart';

class SettingsTab extends StatefulWidget {
  final String tournamentId;
  final Map<String, dynamic> data;
  final String? userUid;

  const SettingsTab({super.key, required this.tournamentId, required this.data, required this.userUid});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final PageController _settingsPageController = PageController();
  final TextEditingController _adminEmailController = TextEditingController();
  
  void _navigatePage(int targetpage){
    _settingsPageController.jumpToPage(targetpage-1);
    _settingsPageController.animateToPage(targetpage, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _settingsPageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMainSettings(),
        _buildEmptyPage(),
        _buildEditInfo(),
        _buildEmptyPage(),
        _buildManageParticipants(),
        _buildEmptyPage(),
        _buildManageAdmins(),
      ],
    );
  }

  Widget _buildMainSettings() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _settingsTile(
              Icons.edit, "Edit Basic Info",
              onTap: () => _navigatePage(2),
            ),
            const SizedBox(height: 5),
            _settingsTile(
              Symbols.apparel_rounded, "Manage Participants",
              onTap: () => _navigatePage(4),
            ),
            const SizedBox(height: 5),
            _settingsTile(
              Icons.people, "Manage Admins",
              onTap: () => _navigatePage(6),
            ),
            const SizedBox(height: 5),
            _settingsTile(Icons.notifications, "Announcements"),
            const SizedBox(height: 5),
            _settingsTile(
              Icons.delete_forever, "Delete Tournament", isDanger: true,
              onTap: (){
                confirmDeleteTournament(context, widget.tournamentId, call: true);
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, {bool isDanger = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, fill: 1, color: isDanger ? Colors.redAccent : Colors.white70),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.redAccent : Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap
    );
  }

  Widget _buildEditInfo(){
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
                  onPressed: (){
                    _settingsPageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                  },
                ),
                const SizedBox(width: 10),
                const Text("EDIT  TOURNAMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildManageParticipants(){
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
                  onPressed: (){
                    _settingsPageController.jumpToPage(1);
                    _settingsPageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                  },
                ),
                const SizedBox(width: 10),
                const Text("MANAGE  PARTICIPANTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildManageAdmins(){
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
                  onPressed: (){
                    _settingsPageController.jumpToPage(1);
                    _settingsPageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                  },
                ),
                const SizedBox(width: 10),
                const Text("MANAGE  ADMINS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                Text("${(widget.data['admins']?.length ?? 0)}/5", style: TextStyle(fontSize: 15)),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if((widget.data['admins']?.length ?? 0) < 5) _showAddAdminDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:((widget.data['admins']?.length ?? 0) < 5)? Theme.of(context).colorScheme.primary
                    : const Color.fromARGB(255, 57, 57, 81),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("ADD ADMIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 700),
                  child: _buildAdminsList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdminsList(){
    List adminIds = widget.data['admins']?? [];
    return ListView.separated(
      itemCount: adminIds.length,
      separatorBuilder: (context, Index) => const SizedBox(height: 12),
      itemBuilder: (context, index){
        String uid = adminIds[index];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, snapshot){
            String name = snapshot.hasData ? "${snapshot.data!['firstname']} ${snapshot.data!['lastname']}" : "Loading...";
            bool isCreator = uid == widget.data['creator_id'];

            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
              title: Text(name, style: const TextStyle(color: Colors.white)),
              trailing: (!isCreator && ((widget.userUid == widget.data['creator_id']) || (uid == widget.userUid)))? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent,),
                onPressed: () => _removeAdmin(context , uid, name),
              ): null,
            );
          },
        );
      },
    );
  }

  Future<void> _addAdminByEmail() async {
    String email = _adminEmailController.text.trim();
    if (email.isEmpty) return;

    List admins = widget.data['admins'] ?? [];
    if(admins.length >= 5){
      _showSnackBar("Maximum limit of 5 admins raeched.");
      return;
    }

    try{
      var userQuery = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();

      if(userQuery.docs.isEmpty){
        _showSnackBar("User with this email not found.");
        return;
      }

      String newAdminId = userQuery.docs.first.id;

      if(admins.contains(newAdminId)){
        _showSnackBar("User is already an admin.");
        return;
      }

      await FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).update({
        'admins': FieldValue.arrayUnion([newAdminId])
      });

      _adminEmailController.clear();
      Navigator.pop(context);
      _showSnackBar("Admin set successfully!");
    } catch(e){
      _showSnackBar("Error adding admin: $e");
    }
  }

  void _removeAdmin(BuildContext context, String id, String name) {
  showDialog(
    context: context,
    builder: (confirmContext) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Text(
                    "Remove $name as admin?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                
                const Divider(color: Colors.white10, height: 1),

                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
                          onTap: () => Navigator.pop(confirmContext),
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: const Text("Cancel", style: TextStyle(color: Colors.purple, fontSize: 16.0, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      
                      const VerticalDivider(color: Colors.white10, width: 1),

                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                          onTap: () async {
                            try{
                              await FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).update({
                                'admins': FieldValue.arrayRemove([id])
                              });

                              Navigator.pop(confirmContext);

                              _showSnackBar("$name successfully removed as admin.");
                            } catch(e){
                              _showSnackBar("Error: failed to remove as admin. $e");
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: const Text(
                              "Remove",
                              style: TextStyle(color: Colors.redAccent, fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E1E24))
    );
  }

  void _showAddAdminDialog(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text("ADD ADMIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _adminEmailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter user email",
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(onPressed: _addAdminByEmail, child: const Text("ADD")),
        ],
      )
    );
  }

  Widget _buildEmptyPage(){
    return const SizedBox.shrink();
  }
}