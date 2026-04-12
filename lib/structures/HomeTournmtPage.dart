import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/TabsTournament/AskAI.dart';
import 'package:gamesphere/TabsTournament/FixtureTab.dart';
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
                  FixturesTab(tournamentId: widget.tournamentId, tournamentData: data),
                  if(format != 2)buildPointsTableTab(data: data),
                  if(format != 0)KnockoutTab(tournamentData: data,),
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
                    errorBuilder: (context, error, stackTrace){
                      return Icon(Icons.broken_image, color: Colors.white.withOpacity(0.1), size: 100);
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
}