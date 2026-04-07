import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamesphere/structures/HomeTournmtPage.dart';
import 'package:gamesphere/structures/SearchTeams.dart';
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
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _tournaments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _documentLimit = 10;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _obsecurePassword = true;
  bool _isSearching = false;

  void _handleSearch(){
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _tournaments.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _fetchTournaments();
    FocusScope.of(context).unfocus();
  }

  @override
  void initState(){
    super.initState();
    _fetchTournaments();

    _scrollController.addListener((){
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = 200.0;

      if(maxScroll - currentScroll <= delta){
        _fetchTournaments();
      }
    });
  }

  @override
  void dispose(){
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTournaments() async {
    if(_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance.collection('tournaments');

      if (_searchQuery.isNotEmpty){
        query = query.where('title_lowercase', isGreaterThanOrEqualTo: _searchQuery)
        .where('title_lowercase', isLessThanOrEqualTo: '$_searchQuery\uf8ff').orderBy('title_lowercase');
      }
      else{
        query = query.orderBy('createdAt', descending: true);
      }

      if(_lastDocument != null){
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_documentLimit);

      final querySnapshot = await query.get();

      if(querySnapshot.docs.length < _documentLimit){
        _hasMore = false;
      }

      if(querySnapshot.docs.isNotEmpty){
        _lastDocument = querySnapshot.docs.last;
        setState(() => _tournaments.addAll(querySnapshot.docs));
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
      _tournaments.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    await _fetchTournaments();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();

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
            title: (_isSearching && context.isMobile)? null
            : Padding(
              padding: EdgeInsets.only(left: context.isMobile? 0:8),
              child: Text("EXPLORE EVENTS", style: TextStyle(fontSize: context.isMobile? 20: 24, fontWeight: FontWeight.w900)),
            ),
            actions: [
              if(context.isMobile) _isSearching?_buildMobileSearchBar()
              : IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              if(!context.isMobile)ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchTeamPage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 57, 57, 81),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  spacing: 5.0,
                  children: [
                    Icon(Icons.sync),
                    Text("Explore Teams", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
              buildProfileOrLogin(context)
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.blueAccent,
            child: (_tournaments.isEmpty && !_isLoading)? _buildEmptyState()
            :ListView.builder(
              controller: _scrollController,
              itemCount: _tournaments.length + (_hasMore? 1 : 0),
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index){
                if (index < _tournaments.length){
                  var doc = _tournaments[index];
                  var data = doc.data() as Map<String, dynamic>;

                  return _buildTournamentCard(context, data, doc.id, userProv.isLoggedIn);
                }
                else{
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: _hasMore? const CircularProgressIndicator(color: Colors.blueAccent)
                      : const Text("No more tournaments", style: TextStyle(color: Colors.white24)),
                    ),
                  );
                }
              },
            ),
          ),
          bottomNavigationBar: (context.isMobile)
          ? BottomAppBar(
            color: Colors.transparent,
            height: 85,
            elevation: 0,
            padding: EdgeInsets.fromLTRB(10, 15, 10, 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchTeamPage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 57, 57, 81),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  spacing: 5.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync),
                    Text("Explore Teams", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ):null,
        ),
      ],
    );
  }

  Widget _buildMobileSearchBar(){
    return SizedBox(
      width: 300,
      height: 35,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _isSearching = false),
          ),
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
    );
  }

  // Widget _buildMobileSearchBar(){
  //   return Transform.translate(
  //     offset: Offset(0, -MediaQuery.of(context).viewInsets.bottom),
  //     child: BottomAppBar(
  //       color: Colors.transparent,
  //       elevation: 0,
  //       height: 85,
  //       padding: EdgeInsets.fromLTRB(10, 15, 10, 20),
  //       child: Align(
  //         alignment: Alignment.topLeft,
  //         child: SizedBox(
  //           width: 300,
  //           height: 35,
  //           child: Row(
  //             children: [
  //               Expanded(child: _buildSearchField()),
  //               InkWell(
  //                 borderRadius: BorderRadius.circular(2),
  //                 onTap: _handleSearch,
  //                 child: Container(
  //                   width: 35,
  //                   height: double.infinity,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(2),
  //                     color: Colors.white
  //                   ),
  //                   child: Icon(Icons.search, color: const Color(0xFF1E1E24)),
  //                 ),
  //               ),
  //               const SizedBox(width: 10)
  //             ],
  //           )
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                  setState(() => _searchQuery = "");
                  _onRefresh();
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

  Widget _buildTournamentCard(BuildContext context, Map<String, dynamic> data, String tournamentId, bool isLoggedIn){
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
                        spacing: 5,
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
                            :Center(child: Icon(Icons.emoji_events_outlined, color: Colors.amber, size:context.isMobile? 55: 65,)),
                          ),
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
                  final bool amIAdmin = admins.contains(userProvider.uid) || (userProvider.role == "superAdmin");
                  final bool isPrivate = data['is_private'] ?? false;

                  if(isPrivate && !amIAdmin) {
                    _showEnterPasswordDialog(context, data['tournament_id'], data['password']);
                  }
                  else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentDashboard(tournamentId: tournamentId)));
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
                  constraints: BoxConstraints(maxWidth: 650),
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
            
                      SizedBox(height: context.isMobile? 60 : 90),
            
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.isMobile? 20 : 30),
                        child: Row(
                          spacing: context.isMobile? 25 : 40,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Enter password", style: TextStyle(color: Colors.grey, fontSize: context.isMobile? 15 : 18)),
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
            
                      SizedBox(height: context.isMobile? 60 : 90),
            
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
        ],
      ),
    );
  }
}