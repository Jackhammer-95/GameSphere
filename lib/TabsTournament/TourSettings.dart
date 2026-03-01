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

  Widget _buildEmptyPage(){
    return const SizedBox.shrink();
  }
}