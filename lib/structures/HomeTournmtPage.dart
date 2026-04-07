import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/TabsTournament/AskAI.dart';
import 'package:gamesphere/TabsTournament/Knockout.dart';
import 'package:gamesphere/TabsTournament/TourSettings.dart';
import 'package:gamesphere/TabsTournament/pointsTableTab.dart';
import 'package:gamesphere/TabsTournament/InfoTab.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:provider/provider.dart';

class TournamentDashboard extends StatefulWidget {
  final String tournamentId;

  const TournamentDashboard({super.key, required this.tournamentId});

  @override
  State<TournamentDashboard> createState() => _TournamentDashboardState();
}

class _TournamentDashboardState extends State<TournamentDashboard>{

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent,));
        }
        if(!snapshot.hasData || !snapshot.data!.exists) return const Scaffold(backgroundColor: Color(0xFF0E0E12), body: Center(child: CircularProgressIndicator()));

        var data = snapshot.data!.data() as Map<String, dynamic>;
        bool isAdmin = (data['admins'] as List).contains(userProvider.uid) || (userProvider.role == "superAdmin");
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
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildInfoTab(context, data),
                  _buildFixturesTab(),
                  if(format != 2)buildPointsTableTab(data: data),
                  if(format != 0)buildKnockoutTab(),
                  buildAskAiTab(),
                  if(isAdmin) SettingsTab(tournamentId: widget.tournamentId, data: data, userId: userProvider.uid),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Map<String, dynamic> data, bool isAdmin, int tabCount, int format) {
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
        buildProfileOrLogin(context)
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
            Positioned(
              top: context.isMobile? 30: 5,
              right: 0,
              left: 0,
              child: Align(
                alignment:Alignment.topCenter,
                child:(data['logo_url'] != null && data['logo_url'].toString().isNotEmpty)
                ? SizedBox(
                  height: 90,
                  width: 150,
                  child: Image.network(
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
                  ),
                )
                :Icon(Icons.emoji_events_outlined, size: 100, color: Colors.white.withOpacity(0.1)),
              ),
            ),
            if(!context.isMobile) Positioned(
              left: -50,
              top: -20,
              child: Icon(Icons.emoji_events, size: 200, color: Colors.white.withOpacity(0.08)),
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
}