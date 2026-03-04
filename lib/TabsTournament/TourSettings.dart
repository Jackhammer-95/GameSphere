import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:gamesphere/widgets/DeleteTournament.dart';
import 'package:gamesphere/TabsTournament/ListTilesTourSettings/manageAdmin.dart';
import 'package:gamesphere/TabsTournament/ListTilesTourSettings/participantsManage.dart';

class SettingsTab extends StatefulWidget {
  final String tournamentId;
  final Map<String, dynamic> data;
  final String? userId;

  const SettingsTab({super.key, required this.tournamentId, required this.data, required this.userId});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final PageController _settingsPageController = PageController();
  late TextEditingController _titleController;
  late TextEditingController _hostController;
  late TextEditingController _descController;
  late TextEditingController _passwordController;
  late bool _isPasswordNeeded;
  bool _obsecurePassword = true;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  void _navigatePage(int targetpage){
    _settingsPageController.jumpToPage(targetpage-1);
    _settingsPageController.animateToPage(targetpage, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  void initState(){
    super.initState();
    _titleController = TextEditingController(text: widget.data['title']);
    _hostController = TextEditingController(text: widget.data['host_name']);
    _descController = TextEditingController(text: widget.data['description']);
    _passwordController = TextEditingController(text: widget.data['password']);
    _isPasswordNeeded = widget.data['is_private'];
  }

  @override
  void dispose(){
    _titleController.dispose();
    _hostController.dispose();
    _descController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        ManageParticipants(data: widget.data, settingsPageController: _settingsPageController),
        _buildEmptyPage(),
        ManageAdmin(tournamentId: widget.tournamentId, data: widget.data, userId: widget.userId, settingsPageController: _settingsPageController),
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
        child: ListView(
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
            ),
            _buildFormContent()
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(){
    return Center(
      child: Container(
        color: const Color(0xFF0E0E12),
        constraints: BoxConstraints(maxWidth: 900),
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Tournament Title*", _titleController, "e.g. Champions League 2026"),
              const SizedBox(height: 16),
              _buildTextField("Host Name*", _hostController, "Organizer Name"),
              const SizedBox(height: 16),
              _buildTextField("Description", _descController, "Rules, prizes, or general info...", maxLines: 4),
              const SizedBox(height: 25),
              _buildPrivacyToggle(),
              if(_isPasswordNeeded) const SizedBox(height: 16),
              if(_isPasswordNeeded) _buildTextField("Set Password*", _passwordController, "Enter access password", suffix: true),
                  
              const SizedBox(height: 60),
              _isLoading? Center(child: const CircularProgressIndicator()) :_buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateTournamentData() async{
    if(!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try{
      await FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).update({
        'title': _titleController.text.trim(),
        'host_name': _hostController.text.trim(),
        'description': _descController.text.trim(),
        'password': _passwordController.text.trim(),
        'is_private': _isPasswordNeeded,
        'updated_At': FieldValue.serverTimestamp(),
      });

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tournament updated successfully!.", style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF1E1E24)),
        );

        _settingsPageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
      }
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e", style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF1E1E24)),
      );
    }
    finally{
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1, bool suffix = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  $label", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value){
            if((value == null || value.isEmpty) && label != 'Description'){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Please fill in all required fields.", style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF1E1E24),
              ));
              return 'Please enter the $label';
            }
            return null;
          },
          maxLines: maxLines,
          obscureText: suffix? _obsecurePassword: false,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: const Color(0xFF1E1E24),
            suffixIcon: (suffix)? IconButton(
              onPressed:() => setState(() {
                _obsecurePassword = !_obsecurePassword;
              }),
              icon: Icon(_obsecurePassword? Icons.visibility_off: Icons.visibility, color: Colors.grey),
            ): null,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle(){
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  onTap: () => setState(() {_isPasswordNeeded = false;}),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      color: _isPasswordNeeded? Colors.transparent : Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text("Public", style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              
              const VerticalDivider(color: Colors.white10, width: 1),
        
              Expanded(
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                  onTap: () => setState(() {_isPasswordNeeded = true;}),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                      color: _isPasswordNeeded? Theme.of(context).colorScheme.primary : Colors.transparent,
                    ),
                    child: const Text(
                      "Private",
                      style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          _isLoading? null: _updateTournamentData();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildEmptyPage(){
    return const SizedBox.shrink();
  }
}