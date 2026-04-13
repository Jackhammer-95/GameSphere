import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/structures/Team%20Profile/SquadTab.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:flutter/services.dart';
import 'package:gamesphere/widgets/basicDeleteDialog.dart';
import 'package:gamesphere/widgets/confirmDeleteSomething.dart';
import 'package:provider/provider.dart';
// import 'package:gamesphere/TheProvider.dart';

class TeamDashboard extends StatefulWidget {
  final String teamId;

  const TeamDashboard({super.key, required this.teamId});

  @override
  State<TeamDashboard> createState() => _TeamDashboardState();
}

class _TeamDashboardState extends State<TeamDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _managerEditController = TextEditingController();
  final TextEditingController _stadiumEditController = TextEditingController();
  final TextEditingController _foundedEditController = TextEditingController();
  final TextEditingController _bioEditController = TextEditingController();
  final TextEditingController _locationEditController = TextEditingController();
  final TextEditingController _leagueEditController = TextEditingController();
  final TextEditingController _ownerEditController = TextEditingController();
  final TextEditingController _emailEditController = TextEditingController();
  String? _selectedFlag;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameEditController.dispose();
    _managerEditController.dispose();
    _stadiumEditController.dispose();
    _foundedEditController.dispose();
    _bioEditController.dispose();
    _locationEditController.dispose();
    _leagueEditController.dispose();
    _ownerEditController.dispose();
    _emailEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          buildProfileOrLogin(context)
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('teams').doc(widget.teamId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const SizedBox.shrink();
              
              var teamData = snapshot.data!.data() as Map<String, dynamic>;

              final userProv = Provider.of<UserProvider>(context, listen: false);

              List admins = teamData['admins']?? [];
              bool isTeamAdmin = admins.contains(userProv.uid) || (userProv.role == "superAdmin");
          
              return Column(
                children: [
                  _buildTeamHeader(teamData),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E24),
                      border: Border.symmetric(horizontal: BorderSide(width: 2, color: Colors.white24))
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.blueAccent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: "OVERVIEW"),
                        Tab(text: "SQUAD"),
                        Tab(text: "ACHIEVEMENTS"),
                      ],
                    ),
                  ),
          
                  // --- TAB CONTENT ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(teamData, isTeamAdmin),
                        SquadTab(teamId: widget.teamId, isTeamAdmin: isTeamAdmin, squadSize: teamData['squad_size'] ?? 0),
                        const Center(child: Text("No Achievements to Show", style: TextStyle(color: Colors.white30))),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTeamHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Color(0xFF1E1E24)
          ]
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height:90,
            width:90,
            child:(data['logo_url'] != null && data['logo_url'].toString().isNotEmpty)
            ? Image.network(
              data['logo_url'],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress){
                if(loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!: null,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace){
                return Icon(Icons.broken_image, color: Colors.grey, size: 100);
              },
            )
            :Center(child: Icon(Icons.shield, color: Colors.grey, size: 75)),
          ),
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name']?.toUpperCase() ?? "UNKNOWN TEAM",
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text((data['flag'] != null && data['flag'] != "🌍")? data['flag'] :"", style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text((data['country'] != null && data['country'] != "Select Country")? data['country'] :"", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickStat("SQUAD SIZE", (data['squad_size'] ?? 0).toString()),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> data, bool isTeamAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(isTeamAdmin)Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _showEditTeamDialog(data),
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
                    Icon(Icons.edit),
                    Text("Edit Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const Text("BIO", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 15),
          Text(
            (data['bio'] != null && data['bio'] != "")? data['bio']: "No description available for this team.",
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const Divider(color: Colors.white10, height: 40),
          _buildDetailRow(Icons.tag, "ID", widget.teamId),
          _buildDetailRow(Icons.person, "Owner", (data['owner']!= null && data['owner']!= "")? data['owner']:"Unknown"),
          if((data['manager'] != null) && (data['manager'] != ""))_buildDetailRow(Icons.person_pin, "Manager", data['manager'] ?? "Not Set"),
          if((data['league'] != null) && (data['league'] != ""))_buildDetailRow(Icons.workspace_premium, "League", data['league']?? "N/A"),
          if((data['stadium'] != null) && (data['stadium'] != ""))_buildDetailRow(Icons.stadium, "Home Stadium", data['stadium']?? "N/A"),
          if((data['location'] != null) && (data['location'] != ""))_buildDetailRow(Icons.location_on, "Location", data['location']?? "N/A"),
          _buildDetailRow(Icons.calendar_today, "Founded", ((data['founded']!=null) && data['founded']!="")? data['founded']:"N/A"),
          if((data['contact_email']!=null) && (data['contact_email']!=""))_buildDetailRow(Icons.email, "Contact", data['contact_email']?? "Not Provided"),
          const SizedBox(height: 10),
          if (isTeamAdmin) ...[
            const Divider(color: Colors.white10, height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TEAM ADMINS", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ElevatedButton(
                  onPressed: () {
                    ((data['admins']?.length ?? 0) < 5)? _showAddAdminDialog(data['admins'] ?? [])
                    :_showSnackBar("Maximum of 5 admins reached. Remove an existing admin to add a new one.");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:((data['admins']?.length ?? 0) < 5)
                      ? Theme.of(context).colorScheme.primary : const Color.fromARGB(255, 57, 57, 81),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("ADD ADMIN", style: TextStyle(fontSize:context.isMobile? 12:14)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildAdminList(data['admins'] ?? [], ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white10, thickness: 0.5),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  confirmDeleteSomething(
                    context,
                    widget.teamId,
                    "Team",
                    "Do you want to delete this team?",
                    onSuccess: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 186, 14, 2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("DELETE TEAM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
              Row(
                spacing: 5,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  if(label == "ID") IconButton(
                    onPressed: () async{
                      await Clipboard.setData(ClipboardData(text: value));

                      if(context.mounted){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Copied to clipboard", style: const TextStyle(color: Colors.white)),
                            backgroundColor: const Color(0xFF1E1E24),
                            duration: const Duration(seconds: 2)
                          )
                        );
                      }
                    },
                    icon: Icon(Icons.copy, size: 18),
                    constraints: const BoxConstraints(), padding: const EdgeInsets.only(right: 8), visualDensity: VisualDensity.compact
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminList(List admins) {
  if (admins.isEmpty) return const Text("No admins assigned", style: TextStyle(color: Colors.white38));

  return FutureBuilder<List<DocumentSnapshot>>(
    future: Future.wait(admins.map((uid) => 
      FirebaseFirestore.instance.collection('users').doc(uid).get()
    )),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: LinearProgressIndicator(color: Colors.blueAccent));
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text("Error loading admins", style: TextStyle(color: Colors.redAccent));
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: snapshot.data!.map((userDoc) {
          var userData = userDoc.data() as Map<String, dynamic>?;
          String fullName = userData != null? "${userData['firstname'] ?? ""} ${userData['lastname'] ?? ""}".trim(): "Unknown User";
          String? dpUrl = userData?['logo_url'];
          String initial = fullName.isNotEmpty? fullName[0].toUpperCase() : "?";

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: (dpUrl != null && dpUrl.isNotEmpty) ? NetworkImage(dpUrl) : null,
                  child: (dpUrl == null || dpUrl.isEmpty) 
                      ? Text(initial, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)) : null,
                ),
                const SizedBox(width: 10),
                Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 5),
                if(admins.length > 1) ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  onPressed: () {
                    showUniversalDeleteDialog(
                      context: context,
                      content: "Are you sure you want to remove $fullName as an admin?",
                      onConfirm: () async {
                        try {
                          await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).update({
                            'admins': FieldValue.arrayRemove([userDoc.id])
                          });
                          _showSnackBar("$fullName successfully removed as admin.");
                        } catch (e) {
                          _showSnackBar("Error removing admin.");
                        }
                      },
                    );
                  },
                  child: const Icon(Icons.remove_circle_outline, size: 20),
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}

  void _showEditTeamDialog(Map<String, dynamic> data) {
    _nameEditController.text = data['name'] ?? "";
    _managerEditController.text = data['manager'] ?? "";
    _stadiumEditController.text = data['stadium'] ?? "";
    _foundedEditController.text = data['founded'] ?? "";
    _bioEditController.text = data['bio'] ?? "";
    _locationEditController.text = data['location']?? "";
    _leagueEditController.text = data['league']?? "";
    _ownerEditController.text = data['owner']?? "";
    _emailEditController.text = data['contact_email']?? "";
    _selectedCountry = data['country']?? "Select Country";
    _selectedFlag = data['flag']?? "🌍";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            title: const Text("Edit Team Info", style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditField("Team Name", _nameEditController),
                  _buildEditField("Bio", _bioEditController, maxLines: 3),
                  _buildEditField("Owners", _ownerEditController),
                  _buildEditField("Manager Name", _managerEditController),
                  const SizedBox(height: 8),
                  const Text("Country", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: (){
                      showCountryPicker(
                        moveAlongWithKeyboard: true,
                        context: context,
                        showPhoneCode: false,
                        exclude: <String> ['IL', 'IM', 'AX', 'AC', 'IO', 'BQ', 'CX', 'FK', 'PF', 'FO', 'GG', 'JE', 'NF', 'TK', 'WF'],
                        onSelect: (Country country){
                          setDialogState(() {
                            if(country.countryCode == 'PS'){
                              _selectedCountry = "Palestine";
                            }
                            else{
                              _selectedCountry = country.name;
                            }
                            _selectedFlag = country.flagEmoji;
                          });
                        },
                        countryListTheme: CountryListThemeData(
                          borderRadius: BorderRadius.circular(20),
                          backgroundColor: const Color(0xFF1E1E24),
                          textStyle: const TextStyle(color: Colors.white),
                          searchTextStyle: const TextStyle(color: Colors.white),
                          inputDecoration: InputDecoration(
                            hintText: 'Search Country',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey,),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(_selectedFlag?? "🌍", style: const TextStyle(fontSize: 24)),
                          Text(
                            _selectedCountry?? "Select country",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey,)
                        ],
                      ),
                    ),
                  ),
                  _buildEditField("League", _leagueEditController),
                  _buildEditField("Stadium", _stadiumEditController),
                  _buildEditField("Location", _locationEditController),
                  _buildEditField("Founded", _foundedEditController),
                  _buildEditField("Contact Email", _emailEditController),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  try{
                    await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).update({
                      'name': _nameEditController.text.trim(),
                      'name_lowercase': _nameEditController.text.trim().toLowerCase(),
                      'bio': _bioEditController.text.trim(),
                      'owner': _ownerEditController.text.trim(),
                      'manager': _managerEditController.text.trim(),
                      'stadium': _stadiumEditController.text.trim(),
                      'location': _locationEditController.text.trim(),
                      'founded': _foundedEditController.text.trim(),
                      'league': _leagueEditController.text.trim(),
                      'contact_email': _emailEditController.text.trim(),
                      'flag': _selectedFlag,
                      'country': _selectedCountry,
                    });
                    if(mounted){
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Changes saved successfully!", style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xFF1E1E24),
                      ));
                    }
                  } catch(e){
                    debugPrint("Error updating team: $e");
                    if(context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Something went wrong.", style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xFF1E1E24),
                      ));
                    }
                  }
                },
                child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: maxLines,
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showAddAdminDialog(List admins){
    final TextEditingController adminEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text("ADD NEW ADMIN   ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: adminEmailController,
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
            onPressed:() {
              final email = adminEmailController.text.trim();
              if(email.isNotEmpty){
                _addAdminByEmail(admins, email);
                Navigator.pop(dialogContext);
                adminEmailController.clear();
              }
            },
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

  Future<void> _addAdminByEmail(List admins, String email) async {
    if (email.isEmpty) return;

    if(admins.length >= 5){
      _showSnackBar("Maximum limit of 5 admins reached.");
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

      await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).update({
        'admins': FieldValue.arrayUnion([newAdminId])
      });

      _showSnackBar("Admin set successfully!");
    } catch(e){
      _showSnackBar("Error adding admin: $e");
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E1E24))
    );
  }
}