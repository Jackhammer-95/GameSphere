import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/TheProvider.dart';

class ManageAdmin extends StatefulWidget {
  final String tournamentId;
  final Map<String, dynamic> data;
  final String? userId;
  final PageController settingsPageController;

  const ManageAdmin({super.key, required this.tournamentId, required this.data, required this.userId, required this.settingsPageController});

  @override
  State<ManageAdmin> createState() => _ManageAdminState();
}

class _ManageAdminState extends State<ManageAdmin> {
  final TextEditingController _adminEmailController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: context.isMobile? 0:16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
                  onPressed: (){
                    widget.settingsPageController.jumpToPage(1);
                    widget.settingsPageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                  },
                ),
                if(!context.isMobile) const SizedBox(width: 10),
                const Text("MANAGE  ADMINS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                Text("${(widget.data['admins']?.length ?? 0)}/5", style: TextStyle(fontSize: 15)),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    ((widget.data['admins']?.length ?? 0) < 5)? _showAddAdminDialog()
                    :_showSnackBar("Maximum of 5 admins reached. Remove an existing admin to add a new one.");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:((widget.data['admins']?.length ?? 0) < 5)? Theme.of(context).colorScheme.primary
                    : const Color.fromARGB(255, 57, 57, 81),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("ADD ADMIN", style: TextStyle(fontSize:context.isMobile? 14:16, fontWeight: FontWeight.bold)),
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
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
              trailing: (!isCreator && ((widget.userId == widget.data['creator_id']) || (uid == widget.userId)))? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent,),
                onPressed: () => _removeAdmin(context , uid, name, (uid == widget.userId)),
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
        Navigator.pop(context);
        return;
      }

      String newAdminId = userQuery.docs.first.id;

      if(admins.contains(newAdminId)){
        _showSnackBar("User is already an admin.");
        Navigator.pop(context);
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

  void _removeAdmin(BuildContext context, String id, String name, bool himself) {
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
                    "Remove ${himself? "yourself": name} as admin?",
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
        title: const Text("ADD NEW ADMIN   ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          ElevatedButton(
            onPressed: _addAdminByEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor:Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("ADD"),
          ),
        ],
      )
    );
  }
}