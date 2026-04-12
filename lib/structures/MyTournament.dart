import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamesphere/structures/HomeTournmtPage.dart';
import 'package:intl/intl.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:gamesphere/widgets/confirmDeleteSomething.dart';

class MyTournament extends StatefulWidget {
  const MyTournament({super.key});

  @override
  State<MyTournament> createState() => _MyTournamentState();
}

class _MyTournamentState extends State<MyTournament> {
  final String? userUid = FirebaseAuth.instance.currentUser?.uid;
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _tournaments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _documentLimit = 10;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

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
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchTournaments() async {
    if(_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance.collection('tournaments').where('admins', arrayContains: userUid);

      if (_searchQuery.isNotEmpty){
        query = query.where('title_lowercase', isGreaterThanOrEqualTo: _searchQuery)
        .where('title_lowercase', isLessThanOrEqualTo: '$_searchQuery\uf8ff').orderBy('title_lowercase');
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
    bool fullEmpty = true;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: (_isSearching && context.isMobile)? null
        : Padding(
          padding: EdgeInsets.only(left: context.isMobile? 0:8),
          child: Text("MY TOURNAMENTS", style: TextStyle(fontSize: context.isMobile? 20: 24, fontWeight: FontWeight.w900)),
        ),
        actions: [
          if(context.isMobile) _isSearching?_buildMobileSearchBar()
          : IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
          ),
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
          buildProfileOrLogin(context)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.blueAccent,
        child: (_tournaments.isEmpty && !_isLoading)? _buildEmptyState(fullEmpty: fullEmpty)
        :ListView.builder(
          controller: _scrollController,
          cacheExtent: max(context.screenHeight*4, 3000),
          itemCount: _tournaments.length + (_hasMore? 1 : 0),
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index){
            if (index < _tournaments.length){
              var doc = _tournaments[index];
              var data = doc.data() as Map<String, dynamic>;

              return _buildTournamentCard(context, data, doc.id);
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
    );
  }

  Widget _buildTournamentCard(BuildContext context, Map<String, dynamic> data, String tournamentId){
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
                              errorBuilder: (context, error, stackTrace){
                                return Icon(Icons.emoji_events_outlined, color: Colors.blueGrey, size: context.isMobile? 55: 65);
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
                                    Spacer(),
                                    Icon(Icons.people_alt_outlined, color: Theme.of(context).colorScheme.primary, size: 18),
                                    const SizedBox(width: 4),
                                    Text("${data['participant_count'] ?? 0}",
                                      style:TextStyle(color: Colors.white70, fontSize: context.isMobile ? 12 : 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(data['title'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:context.isMobile?18: 24,))),
                                    PopupMenuButton(
                                      icon: Icon(Icons.more_vert),
                                      color: const Color(0xFF1E1E24),
                                      offset: const Offset(0, 40),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      onSelected: (value){
                                        confirmDeleteSomething(
                                          context,
                                          data['tournament_id'],
                                          "Tournament",
                                          "Do you want to delete this tournament?",
                                          onSuccess: (){setState(() {
                                            _tournaments.removeWhere((doc) => doc.id == data['tournament_id']);
                                          });}
                                        );
                                      },
                                      itemBuilder: (BuildContext context) =>[
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, color:Colors.redAccent, size: 20),
                                              SizedBox(width: 10),
                                              Text("Delete Tournament", style: TextStyle(color: Colors.redAccent)),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
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
              onTap: () async{
                await Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentDashboard(tournamentId: tournamentId)),);
                _onRefresh();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(){
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
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

  Widget _buildMobileSearchBar(){
    return SizedBox(
      width: 300,
      height: 35,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () {
              _searchFocusNode.unfocus();
              setState(() => _isSearching = false);
            },
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

  Widget _buildEmptyState({bool fullEmpty = true}) {
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
          if(fullEmpty) const Text(
            "Start your journey by creating one.",
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}