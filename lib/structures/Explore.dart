import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamesphere/Login_actions/LoginPage.dart';
import 'package:gamesphere/structures/HomeTournmtPage.dart';
import 'package:intl/intl.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bool loggedIn = snapshot.hasData && (snapshot.data != null);
        final User? user = snapshot.data;

        return Scaffold(
          backgroundColor: const Color(0xFF0E0E12),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("EXPLORE EVENTS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ),
            actions: [
              Padding(
                padding: context.isMobile? const EdgeInsets.only(right: 12.0) : const EdgeInsets.only(right: 24.0),
                child: loggedIn ? Consumer<UserProvider>(
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
                : OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GameSphereLogin()),);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color.fromARGB(77, 255, 255, 255)),
                      padding: context.isMobile
                          ? const EdgeInsets.symmetric(horizontal: 18, vertical: 9)
                          : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: context.isMobile ? const Icon(Icons.login, size: 14) : const Icon(Icons.login, size: 18),
                    label: context.isMobile? const Text("LOGIN", style: TextStyle(fontSize: 12.0)) : const Text("LOGIN"),
                  ),
              )
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tournaments').snapshots(),
            builder: (context, snapshot){
              if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent,));
              }
        
              final docs = snapshot.data!.docs;
        
              if(docs.isEmpty){
                return _buildEmptyState();
              }
        
              return ListView.builder(
                itemCount: docs.length,
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index){
                  var data = docs[index].data() as Map<String, dynamic>;
                  return _buildTournamentCard(context, data, loggedIn);
                },
              );
            },
          ),
        );
      }
    );
  }

  Widget _buildTournamentCard(BuildContext context, Map<String, dynamic> data, bool isLoggedIn){
    String dateStr = "Recently Created";
    if(data['createdAt'] != null){
      DateTime dt = (data['createdAt'] as Timestamp).toDate();
      dateStr = DateFormat('MMM dd, yyyy').format(dt);
    }

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E1E24),
                        const Color(0xFF1E1E24).withOpacity(0.8),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3)),
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height:context.isMobile? 60: 80,
                            width:context.isMobile? 60: 80,
                            child: Center(child: Icon(Icons.emoji_events_outlined, color: Colors.amber, size:context.isMobile? 55: 65,)),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5))
                                  ),
                                  child: Text("${data['sport']}", style: const TextStyle(color: Colors.blueAccent, fontSize: 11))
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: Text(data['title'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:context.isMobile?18: 24,))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Divider(height: 2, color: Colors.white10),
                      SizedBox(height: 6),
                      Text(dateStr, style: const TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
              onTap: (){
                isLoggedIn?
                Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentDashboard(tournamentId: data['tournament_id'])),)
                :ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please login into your account first.", style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xFF1E1E24),
                ));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text(
            "NO TOURNAMENTS FOUND",
            style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            "Start your journey by creating one.",
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}