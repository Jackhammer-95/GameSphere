import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';

class SearchTeamPage extends StatefulWidget {
  const SearchTeamPage({super.key});

  @override
  State<SearchTeamPage> createState() => _SearchTeamPageState();
}

class _SearchTeamPageState extends State<SearchTeamPage> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _teams = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _documentLimit = 10;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch(){
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void initState(){
    super.initState();
    _fetchTeams();

    _scrollController.addListener((){
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = 200.0;

      if(maxScroll - currentScroll <= delta){
        _fetchTeams();
      }
    });
  }

  @override
  void dispose(){
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeams() async {
    if(_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance.collection('teams').orderBy('created_at', descending: true).limit(_documentLimit);

      if(_lastDocument != null){
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if(querySnapshot.docs.length < _documentLimit){
        _hasMore = false;
      }

      if(querySnapshot.docs.isNotEmpty){
        _lastDocument = querySnapshot.docs.last;
        setState(() => _teams.addAll(querySnapshot.docs));
      }
    } catch (e){
      debugPrint("Error fetching tournaments: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // onRefresh here
  Future<void> _onRefresh() async {
    setState(() {
      _teams.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    await _fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bool loggedIn = snapshot.hasData && (snapshot.data != null);
        final User? user = snapshot.data;

        final filteredList = _teams.where((doc){
          final data = doc.data() as Map<String, dynamic>;
          final String title = (data['name'] ?? "").toString().toLowerCase();
          final String teamId = doc.id.toString().toLowerCase();

          if(_searchQuery.isEmpty) return true;
          return title.contains(_searchQuery) || teamId == _searchQuery;
        }).toList();

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
                title: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text("EXPLORE TEAMS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
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
                              child: const Icon(Icons.search, color: Color(0xFF1E1E24)),
                            ),
                          ),
                          const SizedBox(width: 10)
                        ],
                      )
                    ),
                  ),
                  buildProfileOrLogin(context, loggedIn, user)
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Colors.blueAccent,
                child: (filteredList.isEmpty && !_isLoading)? _buildEmptyState()
                :ListView.builder(
                  controller: _scrollController,
                  cacheExtent: context.screenHeight*4,
                  itemCount: filteredList.length + (_hasMore? 1 : 0),
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    if (index < filteredList.length){
                      var doc = filteredList[index];
                      var data = doc.data() as Map<String, dynamic>;

                      return _buildTournamentCard(context, data, doc.id, loggedIn);
                    }
                    else{
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: _hasMore? const CircularProgressIndicator(color: Colors.blueAccent)
                          : const Text("No more teams", style: TextStyle(color: Colors.white24)),
                        ),
                      );
                    }
                  },
                ),
              ),
              bottomNavigationBar: (context.isMobile)? _buildMobileSearchBar(): null,
            ),
          ],
        );
      }
    );
  }

  Widget _buildMobileSearchBar(){
    return Transform.translate(
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
    );
  }

  Widget _buildSearchField(){
    return TextField(
      controller: _searchController,
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(color: Colors.white),
      onSubmitted: (_) => _handleSearch(),
      decoration: InputDecoration(
        hintText: "Search Team",
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

  Widget _buildTournamentCard(BuildContext context, Map<String, dynamic> data, String teamId, bool isLoggedIn){
    int playerCount = data['players'] is List ? (data['players'] as List).length : 0;
    
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
                      spacing: 10,
                      children: [
                        SizedBox(
                          height:context.isMobile? 60: 80,
                          width:context.isMobile? 60: 80,
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
                          :Center(child: Icon(Icons.shield, color: Colors.grey, size:context.isMobile? 55: 65)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.group, color: Theme.of(context).colorScheme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text("$playerCount", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                  Spacer(),
                                  Text(data['flag'], style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: Text(data['name'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:context.isMobile?18: 24,))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              onTap: (){
                // Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDashboard(teamId: teamId)));
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
          Icon(Icons.shield_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text(
            "NO TEAMS FOUND",
            style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}