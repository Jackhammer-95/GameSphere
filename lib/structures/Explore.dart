import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamesphere/Login_actions/LoginPage.dart';
import 'package:gamesphere/structures/HomeTournmtPage.dart';
import 'package:intl/intl.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:provider/provider.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot>? _tournamentStream;
  bool _obsecurePassword = true;

  void _handleSearch(){
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void initState(){
    super.initState();
    _tournamentStream = FirebaseFirestore.instance.collection('tournaments').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bool loggedIn = snapshot.hasData && (snapshot.data != null);
        final User? user = snapshot.data;

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "Assets/images/Homepage_extended_GameSphere.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                title: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("EXPLORE EVENTS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ),
                actions: [
                  if(!context.isMobile) Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 300,
                      height: 35,
                      child: Row(
                        children: [
                          Expanded(child: _buildSearchField()),
                          InkWell(
                            borderRadius: BorderRadius.circular(2),
                            onTap: _handleSearch,
                            child: Container(
                              width: 35,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white
                              ),
                              child: Icon(Icons.search, color: const Color(0xFF1E1E24)),
                            ),
                          ),
                          const SizedBox(width: 10)
                        ],
                      )
                    ),
                  ),
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
                stream: _tournamentStream,
                builder: (context, snapshot){
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent,));
                  }
                      
                  final docs = snapshot.data!.docs;
                  
                  final filteredDocs = docs.where((doc){
                    final data = doc.data() as Map<String, dynamic>;

                    final String title = (data['title']?? "").toString().toLowerCase();
                    final String tournamentId = (data['tournament_id'] ?? "").toString().toLowerCase();

                    if(_searchQuery.isEmpty) return true;

                    return title.contains(_searchQuery) || tournamentId == _searchQuery;
                  }).toList();
                      
                  if(docs.isEmpty || filteredDocs.isEmpty){
                    return _buildEmptyState();
                  }
                      
                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index){
                      var data = filteredDocs[index].data() as Map<String, dynamic>;
                      return _buildTournamentCard(context, data, loggedIn);
                    },
                  );
                },
              ),
              bottomNavigationBar: (context.isMobile)? Transform.translate(
                offset: Offset(0, -MediaQuery.of(context).viewInsets.bottom),
                child: BottomAppBar(
                  color: Colors.transparent,
                  elevation: 0,
                  height: 85,
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 300,
                      height: 35,
                      child: Row(
                        children: [
                          Expanded(child: _buildSearchField()),
                          InkWell(
                            borderRadius: BorderRadius.circular(2),
                            onTap: _handleSearch,
                            child: Container(
                              width: 35,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white
                              ),
                              child: Icon(Icons.search, color: const Color(0xFF1E1E24)),
                            ),
                          ),
                          const SizedBox(width: 10)
                        ],
                      )
                    ),
                  ),
                ),
              ): null,
            ),
          ],
        );
      }
    );
  }

  Widget _buildSearchField(){
    return TextField(
      controller: _searchController,
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(color: Colors.white),
      onSubmitted: (_) => _handleSearch(),
      decoration: InputDecoration(
        hintText: "Search Tournament",
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        fillColor: const Color(0xFF1E1E24),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child){
            return value.text.isNotEmpty? IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: (){
                  _searchController.clear();
                  setState(() {
                    _searchQuery = "";
                  });
                },
              )
            : const SizedBox.shrink();
          }
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1),
        ),
      ),
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
                        const Color.fromARGB(255, 20, 20, 46),
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
                                Row(
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
                                    const SizedBox(width: 8),
                                    if((data['is_private']?? false)) Icon(Icons.lock_outline, color: Colors.grey, size: 20,),
                                  ],
                                ),
                                const SizedBox(height: 8),
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
                  if(!isLoggedIn){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please login into your account first.", style: TextStyle(color: Colors.white)),
                      backgroundColor: Color(0xFF1E1E24),
                    ));
                    return;
                  }
                
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final List admins = data['admins'] ?? [];
                  final bool amIAdmin = admins.contains(userProvider.uid);
                  final bool isPrivate = data['is_private'] ?? false;

                  if(isPrivate && !amIAdmin){
                    _showEnterPasswordDialog(context, data['tournament_id'], data['password']);
                  }
                  else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentDashboard(tournamentId: data['tournament_id'])));
                  }
                },
            ),
          ),
        ),
      ),
    );
  }

  void _showEnterPasswordDialog(BuildContext context, String tournamentId, String password) {
    final TextEditingController _passVerifyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (confirmContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 700),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(1),
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              color: Theme.of(context).colorScheme.primary,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "PRIVATE  TOURNAMENT",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(confirmContext),
                            child: Container(
                              height: 40,
                              width: 40,
                              color: Colors.white,
                              child: const Icon(Icons.close, size: 30, color: Color(0xFF1E1E24)),
                            ),
                          )
                        ],
                      ),
            
                      const SizedBox(height: 90),
            
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          spacing: 40,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Enter password", style: TextStyle(color: Colors.grey, fontSize: 18)),
                            Expanded(
                              child: TextField(
                                controller: _passVerifyController,
                                obscureText: _obsecurePassword,
                                decoration: InputDecoration(
                                  hintText: "Tap to enter password",
                                  suffixIcon: IconButton(
                                    onPressed: () => setDialogState(() => _obsecurePassword = !_obsecurePassword),
                                    icon: Icon(_obsecurePassword? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1E24),
                                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(color: Colors.white10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 90),
            
                      Row(
                        spacing: 40,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cancel Button
                          ElevatedButton(
                            onPressed: () => Navigator.pop(confirmContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            child: Text("CANCEL", style: const TextStyle(color: Color(0xFF1E1E24), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ),
                          
                          ElevatedButton(
                            onPressed: (){
                              if(_passVerifyController.text == password){
                                Navigator.pop(confirmContext);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentDashboard(tournamentId: tournamentId)));
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error: Password incorrect.", style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF1E1E24)),
                                );
                                Navigator.pop(confirmContext);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            child: Text("CONFIRM", style: const TextStyle(color: Color(0xFF1E1E24), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
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