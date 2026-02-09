import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyTournament extends StatelessWidget {
  const MyTournament({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("MY  TOURNAMENTS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ),
        actions: [],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tournaments').where('admin_uid', isEqualTo: userUid).snapshots(),
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
              return _buildTournamentCard(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildTournamentCard(BuildContext context, Map<String, dynamic> data){
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
                          const SizedBox(
                            height: 80,
                            width: 80,
                            child: Center(child: Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 65,)),
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
                                    Text(data['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, overflow: TextOverflow.ellipsis)),
                                    Spacer(),
                                    IconButton(onPressed:() {}, icon: Icon(Icons.more_vert))
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
                // loiya jaw jaygamoto
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