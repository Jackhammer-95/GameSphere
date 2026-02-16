import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TournamentSettingsPage extends StatefulWidget {
  final String title;
  final String hostname;
  final String description;
  final String sport;
  final int format;

  const TournamentSettingsPage({
    super.key,
    required this.title,
    required this.hostname,
    required this.description,
    required this.sport,
    required this.format,
  });

  @override
  State<TournamentSettingsPage> createState() => _TournamentSettingsPageState();
}

class _TournamentSettingsPageState extends State<TournamentSettingsPage>{
  int _groupCount = 2;
  int _teamsPerGroup = 4;
  int _legs = 1;
  double _qualifies = 4;
  bool _thirdPlaceMatch = false;
  bool _twolegged = false;

  Future<void> _registerTournament() async{
    try{
      final String? userUid = FirebaseAuth.instance.currentUser?.uid;

      if(userUid == null){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated.", style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF1E1E24)),
        );
      }

      DocumentReference docref = FirebaseFirestore.instance.collection('tournaments').doc();
      String tournamentId = docref.id;
      
      Map<String, dynamic> tournamentData = {
        'tournament_id': tournamentId,
        'title': widget.title,
        'host_name': widget.hostname,
        'description': widget.description,
        'sport': widget.sport,
        'format_index': widget.format,
        'no_of_groups': widget.format != 2? _groupCount: 0,
        'teams_per_group': widget.format != 2? _teamsPerGroup: 0,
        'times_play_all': widget.format != 2? _legs: 0,
        'qualifies_to_KO': widget.format != 0? _qualifies.toInt(): 0,
        'third_place_match': _thirdPlaceMatch,
        'two_legged_knockout': _twolegged,
        'createdAt': FieldValue.serverTimestamp(),
        'admin_uid': userUid,
      };

      await docref.set(tournamentData);

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tournament Created Successfully!", style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF1E1E24)),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
    catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create tournament.: $e", style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF1E1E24)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        centerTitle: true,
        title: Text("${widget.title.toUpperCase()} SETTINGS", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),),
        backgroundColor: const Color(0xFF0E0E12),
        elevation: 0,
        toolbarHeight: 45.0,
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF0E0E12),
            height: double.infinity,
            width: double.infinity,
          ),
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      _buildHeaderTag(),
                      const SizedBox(height: 25),
                      if(widget.format != 2)...[
                        _sectionTitle("GROUP SETTINGS"),
                        const SizedBox(height: 15),
                        _buildNumberSelector(
                          label: "Number of Groups",
                          value: _groupCount,
                          onChanged: (val) => setState((){
                            _groupCount = val;
                            if(_qualifies/2 >= _groupCount*_teamsPerGroup){setState(() {_qualifies = _qualifies/2;});}
                          }),
                          min: 1,
                          max: 24,
                        ),
                        const SizedBox(height: 15),
                        _buildNumberSelector(
                          label: "Teams in a Group",
                          value: _teamsPerGroup,
                          onChanged: (val) => setState((){
                            _teamsPerGroup = val;
                            if(_qualifies/2 >= _groupCount*_teamsPerGroup){setState(() {_qualifies = _qualifies/2;});}
                          }),
                          min: 3,
                          max: 30,
                        ),
                        const SizedBox(height: 15),
                        _buildNumberSelector(
                          label: "Times Play Each Other",
                          value: _legs,
                          onChanged: (val) => setState(() => _legs = val),
                          min: 1,
                          max: 4,
                        ),
                        const SizedBox(height: 35),
                      ],
                  
                      if(widget.format != 0)...[
                        _sectionTitle("KNOCKOUT CONFIGURATION"),
                        const SizedBox(height: 15),
                        _buildQualifySelector(
                          label: widget.format == 2? "Number of Teams" :"Teams Qualifies for Knockout",
                          value: _qualifies,
                          onChanged: (val) => setState((){
                            _qualifies = val;
                            if(_qualifies == 2){_thirdPlaceMatch = false;}
                          }),
                          min: 2,
                          max: widget.format != 2? min(64, _teamsPerGroup*_groupCount) : 64,
                        ),
                        const SizedBox(height: 10),
                        _buildSwitchTile(
                          "Third Place Match", 
                          "Include a bronze medal match for semi-final losers", 
                          _thirdPlaceMatch,
                          (val) => setState((){
                            if(_qualifies == 2){null;}
                            else{_thirdPlaceMatch = val;}
                          }),
                        ),
                        if(widget.sport != 'Cricket')_buildSwitchTile(
                          "Two legged",
                          "Decide winner by aggregate score over two Matches", 
                          _twolegged,
                          (val) => setState(() => _twolegged = val),
                        ),
                        const SizedBox(height: 20),
                      ],
                  
                      _buildSummaryCard(),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 50.0,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerTournament,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("FINALIZE & CREATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag(){
    String formatName = ["GROUP PHASE", "MIXED FORMAT", "KNOCKOUT ONLY"][widget.format];
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).colorScheme.primary)
        ),
        child: Text(
          "${widget.sport.toUpperCase()}  •  $formatName",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNumberSelector({required String label, required int value , required Function(int) onChanged, int min = 2, int max = 32}){
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E24), borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold,)),
          Row(
            
            children: [
              IconButton(onPressed: value > min? () => {onChanged(value-1),}: null, icon: const Icon(Icons.remove_circle_outline, color: Colors.blue, size: 35,)),
              SizedBox(height:36, width:32, child: Center(child: Text(" $value ", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))),
              IconButton(onPressed: value < max? () => {onChanged(value+1),}: null, icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 35,)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualifySelector({required String label, required double value , required Function(double) onChanged, int min = 2, int max = 32}){
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E24), borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis))),
          Row(

            children: [
              IconButton(onPressed: value > min? () => onChanged(value/2): null, icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.blue, size: 35,)),
              SizedBox(height:36, width:32, child: Center(child: Text(" ${value.toInt()} ", style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))),
              IconButton(onPressed: value < max? () => onChanged(value*2): null, icon: const Icon(Icons.keyboard_double_arrow_right, color: Colors.blue, size: 35,)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String sub, bool value, Function(bool) onChanged){
    bool isDisabled = (_qualifies == 2 && title.contains("Third Place Match"));

    return Opacity(
      opacity: isDisabled? 0.4: 1.0,
      child: ListTile(
        enabled: !isDisabled,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Switch(
          value: isDisabled? false : value, onChanged: isDisabled? null: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
          thumbColor: WidgetStateProperty.resolveWith<Color?>((states){
            if(states.contains(WidgetState.disabled)){
              return Colors.grey.shade600;
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color?>((states){
            if(states.contains(WidgetState.disabled)){
              return Colors.white10;
            }
            return null;
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFF1E1E24),
          Theme.of(context).colorScheme.primary.withOpacity(0.05)
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text("SCHEDULING PREVIEW", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 10),
          if(widget.format != 2)... [Text("$_groupCount ${_groupCount == 1? 'Group':'Groups'} of $_teamsPerGroup Teams", style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 5)],
          if(widget.format != 2) Text("(Maximum total teams: ${(_groupCount*_teamsPerGroup).toInt()})", style: const TextStyle(color: Colors.white60, fontSize: 14)),
          if(widget.format == 2) Text("Maximum teams: ${_qualifies.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          if(widget.format == 1)... [Text("Up to ${min(_qualifies.toInt(), (_groupCount*_teamsPerGroup).toInt())} teams may advance to knockout", style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),]
        ],
      ),
    );
  }
  
  Widget _sectionTitle(String title){
    return Center(
      child: Text(title, style:TextStyle(color:Colors.blue, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),),
    );
  }
}