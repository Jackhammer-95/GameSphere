import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/structures/SquadTab.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:flutter/services.dart';
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
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              var teamData = snapshot.data!.data() as Map<String, dynamic>;

              final userProv = Provider.of<UserProvider>(context, listen: false);

              List admins = teamData['admins']?? [];
              bool isTeamAdmin = admins.contains(userProv.uid);
          
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
                    Text(data['flag'] ?? "", style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(data['country'] ?? "", style: const TextStyle(color: Colors.grey)),
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

  
}