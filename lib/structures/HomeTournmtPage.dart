import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/TabsTournament/pointsTableTab.dart';
import 'package:gamesphere/TabsTournament/InfoTab.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:gamesphere/widgets/DeleteTournament.dart';

class TournamentDashboard extends StatefulWidget {
  final String tournamentId;

  const TournamentDashboard({super.key, required this.tournamentId});

  @override
  State<TournamentDashboard> createState() => _TournamentDashboardState();
}

class _TournamentDashboardState extends State<TournamentDashboard>{
  final String? userUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent,));
        }
        if(!snapshot.hasData || !snapshot.data!.exists) return const Scaffold(backgroundColor: Color(0xFF0E0E12), body: Center(child: CircularProgressIndicator()));

        var data = snapshot.data!.data() as Map<String, dynamic>;
        bool isAdmin = data['admin_uid'] == userUid;
        int format = data['format_index'];

        int tabCount = 5;
        if (format != 1) tabCount--;
        if (isAdmin) tabCount++;

        return DefaultTabController(
          length: tabCount,
          child: Scaffold(
            backgroundColor: const Color(0xFF0E0E12),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildSliverAppBar(context, data, isAdmin, tabCount, format),
                ];
              },
              body: TabBarView(
                children: [
                  buildInfoTab(context, data),
                  _buildFixturesTab(),
                  if(format != 2)buildPointsTableTab(),
                  if(format != 0)_buildKnockoutTab(),
                  _buildAskAiTab(),
                  if(isAdmin) _buildSettingsTab(),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Map<String, dynamic> data, bool isAdmin, int tabCount, int format) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = snapshot.data;

        return SliverAppBar(
          expandedHeight: 180.0,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF0E0E12),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: context.isMobile? const EdgeInsets.only(right: 12.0) : const EdgeInsets.only(right: 24.0),
              child: Consumer<UserProvider>(
                builder: (context, userProv, child) {
                  return IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.white30,
                      radius: 18,
                      child: CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 57, 92, 109),
                        radius: 17,
                        child: userProv.isLoading
                          ? const SizedBox(
                            width: 12.0,
                            height: 12.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white,),
                          )
                          : Text(
                            userProv.initial,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                      ),
                    ),
                    onPressed: (){
                      showProfileDialog(context, user!);
                    },
                  );
                }
              )
            )
          ],
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(bottom: 50),
            title: SizedBox(
              width: double.infinity,
              child: Text(
                data['title'].toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing:context.isMobile? 0: 2,
                ),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.emoji_events_outlined, size: 100, color: Colors.white.withOpacity(0.1)),
                ),
                if(!context.isMobile) Positioned(
                  left: -50,
                  top: -20,
                  child: Icon(Icons.emoji_events, size: 200, color: Colors.white.withOpacity(0.08)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blueAccent.withOpacity(0.15),
                        const Color(0xFF0E0E12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: TabBar(
                isScrollable: false,
                indicatorColor: Colors.blueAccent,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                tabs: [
                  context.isMobile? Tab(icon: Icon(Icons.info_outline)): Tab(text: "INFO"),
                  context.isMobile? Tab(icon: Icon(Icons.calendar_month_outlined)): Tab(text: "FIXTURES"),
                  if(format != 2) (context.isMobile? Tab(icon: Icon(Icons.format_list_numbered)): Tab(text: "STANDINGS")),
                  if(format != 0) (context.isMobile? Tab(icon: Icon(Icons.account_tree_outlined)): Tab(text: "BRACKETS")),
                  context.isMobile? Tab(icon: Icon(Icons.chat_outlined)): Tab(text: "ASK"),
                  if(isAdmin) (context.isMobile? Tab(icon: Icon(Icons.settings)): Tab(text: "SETTINGS")),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildFixturesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Placeholder for match list
      itemBuilder: (context, index) {
        return _matchCard();
      },
    );
  }

  Widget _matchCard() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.only(bottom: 12),
        padding:context.isMobile? const EdgeInsets.symmetric(vertical: 16, horizontal: 0) :const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _teamInfo("REAL MADRID", Icons.shield),
            SizedBox(height: 50, width: 50, child: Text("0", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 40))),
            const SizedBox(width: 10),
            Column(
              children: [
                const Text("VS", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("21:45", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
            SizedBox(height: 50, width: 50, child: Text("0", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 40))),
            const SizedBox(width: 10),
            _teamInfo("INTER MIAMI", Icons.shield),
          ],
        ),
      ),
    );
  }

  Widget _teamInfo(String name, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 40),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  

  Widget _buildKnockoutTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 100, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text("KNOCKOUT BRACKET GENERATING...", style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _settingsTile(Icons.edit, "Edit Basic Info"),
            const SizedBox(height: 5),
            _settingsTile(Symbols.apparel_rounded, "Manage Participants"),
            const SizedBox(height: 5),
            _settingsTile(Icons.people, "Manage Admins"),
            const SizedBox(height: 5),
            _settingsTile(Icons.notifications, "Announcements"),
            const SizedBox(height: 5),
            _settingsTile(Icons.delete_forever, "Delete Tournament", isDanger: true),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, fill: 1, color: isDanger ? Colors.redAccent : Colors.white70),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.redAccent : Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {
        if(icon == Icons.delete_forever){
          confirmDeleteTournament(context, widget.tournamentId, call: true);
        }
      },
    );
  }

  Widget _buildAskAiTab(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.analytics_outlined, size: 100, color: Colors.white.withOpacity(0.05)),
        const SizedBox(height: 20),
        Center(child: Text("Ask AI", style: TextStyle(color: Colors.white24))),
      ],
    );
  }
}