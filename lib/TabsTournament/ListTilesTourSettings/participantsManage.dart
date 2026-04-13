import 'dart:math';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

import 'package:provider/provider.dart';

class ManageParticipants extends StatefulWidget {
  final Map<String, dynamic> data;
  final PageController settingsPageController;
  final String tournamentId;

  const ManageParticipants({super.key, required this.data, required this.settingsPageController, required this.tournamentId});

  @override
  State<ManageParticipants> createState() => _ManageParticipantsState();
}

class _ManageParticipantsState extends State<ManageParticipants> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedflag;
  String? _selectedCountry;
  
  String? _manualImageUrl;
  File? _pickedImage;
  Uint8List? _webImage;
  bool _isDialogLoading = false;
  final cloudinary = CloudinaryPublic('dt2f6qqvk', 'GameSphere', cache: false);
  final ImagePicker _picker = ImagePicker();

  bool _showCountry = false;
  bool _showLogo = true;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
                  onPressed: (){
                    widget.settingsPageController.jumpToPage(1);
                    widget.settingsPageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                  },
                ),
                const SizedBox(width: 10),
                const Text("MANAGE  PARTICIPANTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _showLogo = !_showLogo),
                  icon: Icon(_showLogo? Icons.check_box :Icons.check_box_outline_blank, color: Colors.blueAccent),
                ),
                Text("Logo", style: TextStyle(color: Colors.blueAccent))
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _showCountry = !_showCountry),
                  icon: Icon(_showCountry? Icons.check_box :Icons.check_box_outline_blank, color: Colors.blueAccent),
                ),
                Text("Country", style: TextStyle(color: Colors.blueAccent))
              ],
            ),
            Expanded(child: _buildGroups())
          ],
        ),
      ),
    );
  }

  Widget _buildGroups(){
    int groupCount = widget.data['no_of_groups'] ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: List.generate(groupCount, (index){
              String groupName = String.fromCharCode(65+index);
              return _buildSingleGroupTable("GROUP $groupName");
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSingleGroupTable(String title){
    String groupName = title.split(" ")[1];
    
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).collection('participants')
      .where('group', isEqualTo: groupName).snapshots(),
      builder: (context, snapshot) {
        Map<int, DocumentSnapshot> participantMap = {};
        if(snapshot.hasData){
          for(var doc in snapshot.data!.docs){
            participantMap[doc['slot_index']] = doc;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.purple),
                  columnSpacing: 0,
                  horizontalMargin: 5,
                  headingTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  columns: [
                    DataColumn(label: Expanded(child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15)))),
                  ],
                  rows: List.generate(widget.data['teams_per_group'], (index){
                    var participant = participantMap[index];
                    bool isEmptySlot = participant == null || participant['team_id'] == null;
                    bool canEdit = isEmptySlot || (participant['imported'] == false);
                
                    return DataRow(cells: [
                      DataCell((isEmptySlot || participant['team_id'] == null)? _buildEmptySlot(groupName, index, isEmptySlot):
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('teams').doc(participant['team_id']).snapshots(),
                        builder: (context, teamSnapshot) {
                          if(!teamSnapshot.hasData) return const SizedBox(height: 30, child: LinearProgressIndicator());

                          var teamData = teamSnapshot.data!.data() as Map<String, dynamic>?;

                          String team_name = teamData?['name']?? "Unknown team";
                          String? logo = teamData?['logo_url'];
                          String? flag = teamData?['flag'];
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: min(400, context.screenWidth*0.95)),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                (_showLogo)? SizedBox(
                                  height: 30,
                                  width: 30,
                                  child:(logo != null)
                                  ? Image.network(
                                      logo,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress){
                                        if(loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(strokeWidth: 3),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace){
                                        return const Icon(Icons.shield, color: Colors.white, size: 30);
                                      },
                                    )
                                  : Icon(Icons.shield, color: Colors.white)
                                )
                                :(_showCountry)? Text((flag != null && flag != "🌍")? flag :"", style: TextStyle(fontSize: 16))
                                : const SizedBox.shrink(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 100),
                                      child: Text(
                                        "$team_name ${(_showCountry && _showLogo)? ((flag != null && flag != "🌍")? flag :"") : ""}",
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white, fontSize: 16)
                                      )
                                    )
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(canEdit)IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed:() {
                                        _clearDialogData();
                                        _showAddTeamDialog(groupName.codeUnitAt(0)-65, index, isEmptySlot);
                                      },
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => confirmDeleteTeam(context, team_name, participant.id),
                                    ),
                                    if(!context.isMobile) const SizedBox(width: 8)
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      )),
                    ]);
                  }),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  void _showAddTeamDialog(int groupIndex, int slotIndex, bool isEmptySlot){
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState){
          return DefaultTabController(
            length: 2,
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E24),
              title: const Text("Assign Team", style: TextStyle(color: Colors.white, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 500, maxWidth: min(400, context.screenWidth*0.9)),
                child: SizedBox(
                  height: 380,
                  width: 400,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [Tab(text: "Import ID"), Tab(text: "Create New")],
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildDialogField("Enter team ID", _idController),
                                  const SizedBox(height: 20),
                                  _isDialogLoading? const CircularProgressIndicator()
                                  : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => _importTeam(groupIndex, slotIndex, setDialogState, isEmptySlot),
                                    child: const Text("Assign", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                            ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildTeamLogoSetter(setDialogState),
                                    const SizedBox(height: 10),
                                    _buildDialogField("Team Name*", _nameController),
                                    const SizedBox(height: 20),
                                    InkWell(
                                      onTap: (){
                                        showCountryPicker(
                                          moveAlongWithKeyboard: true,
                                          context: context,
                                          showPhoneCode: false,
                                          exclude: <String> ['IL', 'IM', 'AX', 'AC', 'IO', 'BQ', 'CX', 'FK', 'PF', 'FO', 'GG', 'JE', 'NF', 'TK', 'WF'],
                                          onSelect: (Country country){
                                            setDialogState(() {
                                              if(country.countryCode == 'PS'){
                                                _selectedCountry = "Palestine";
                                              }
                                              else{
                                                _selectedCountry = country.name;
                                              }
                                              _selectedflag = country.flagEmoji;
                                            });
                                          },
                                          countryListTheme: CountryListThemeData(
                                            borderRadius: BorderRadius.circular(20),
                                            backgroundColor: const Color(0xFF1E1E24),
                                            textStyle: const TextStyle(color: Colors.white),
                                            searchTextStyle: const TextStyle(color: Colors.white),
                                            inputDecoration: InputDecoration(
                                              hintText: 'Search Country',
                                              hintStyle: const TextStyle(color: Colors.grey),
                                              prefixIcon: const Icon(Icons.search, color: Colors.grey,),
                                              filled: true,
                                              fillColor: Colors.black26,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1E24),
                                          border: Border.all(color: Colors.white30),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Text(_selectedflag?? "🌍", style: const TextStyle(fontSize: 24)),
                                            Text(
                                              _selectedCountry?? "Select country",
                                              style: const TextStyle(color: Colors.white, fontSize: 16),
                                            ),
                                            Spacer(),
                                            const Icon(Icons.arrow_drop_down, color: Colors.grey,)
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _isDialogLoading ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => _createNewTeam(groupIndex, slotIndex, setDialogState, isEmptySlot),
                                        child: const Text("Assign", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ),
              )
            ),
          );
        },
      )
    );
  }

  Widget _buildEmptySlot(String groupName, int index, bool isEmptySlot) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: min(400, context.screenWidth * 0.95)),
      child: Row(
        children: [
          const SizedBox(width: 8),
          if(_showLogo) SizedBox(
            height: 30,
            width: 30,
            child: Icon(Icons.shield, color: Colors.white38, size: 24),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Empty slot",
              style: TextStyle(
                color: Colors.white38, 
                fontSize: 16, 
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed:() {
              _clearDialogData();
              _showAddTeamDialog(groupName.codeUnitAt(0)-65, index, isEmptySlot);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogoSetter(StateSetter setDialogState) {
    ImageProvider? displayImage;

    if (kIsWeb && _webImage != null) {displayImage = MemoryImage(_webImage!);}
    else if (!kIsWeb && _pickedImage != null) {displayImage = FileImage(_pickedImage!);}
    else if (_manualImageUrl != null && _manualImageUrl!.isNotEmpty) {displayImage = NetworkImage(_manualImageUrl!);}

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF0E0E12),
            backgroundImage: displayImage,
            child: displayImage == null? const Icon(Icons.shield, size: 40, color: Colors.white24): null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: () => _showImageSourceDialog(setDialogState),
              child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1E1E24), width: 2),
              ),
              child: const Icon(Icons.add_a_photo, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0E0E12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog(StateSetter setDialogState) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Select Source", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blueAccent),
            title: const Text("Upload from Device", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _pickImage(setDialogState);
            },
          ),
          ListTile(
            leading: const Icon(Icons.link, color: Colors.blueAccent),
            title: const Text("Enter Image Link", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showLinkInputDialog(setDialogState);
            },
          ),
          if(_manualImageUrl != null || _pickedImage != null || _webImage != null) ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text("Remove Logo", style: TextStyle(color: Colors.white)),
            onTap: () {
              setDialogState(() {
                _manualImageUrl = null;
                _pickedImage = null;
                _webImage = null;
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLinkInputDialog(StateSetter setDialogState) {
    final TextEditingController urlController = TextEditingController(text: _manualImageUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text("Image URL", style: TextStyle(color: Colors.white)),
        content: TextField(
          decoration: InputDecoration(
            hintText: "Enter image URL(jpg/png)",
            hintStyle: const TextStyle(color: Colors.white24),
          ),
          controller: urlController,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              String url = urlController.text.trim();

              if (url.isEmpty) {
                Navigator.pop(context);
                return;
              }

              if (_isValidImageLink(url)) {
                setDialogState(() {
                  _manualImageUrl = urlController.text.trim();
                  _pickedImage = null;
                  _webImage = null;
                });
                Navigator.pop(context);
              }
              else{
                _showSnackBar("Please provide a valid .png or .jpg link.");
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage([StateSetter? setDialogState]) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        (setDialogState ?? setState)(() {
          _webImage = bytes;
          _pickedImage = File(image.path);
          _manualImageUrl = null;
        });
      } else {
        (setDialogState ?? setState)(() {
          _pickedImage = File(image.path);
          _manualImageUrl = null;
        });
      }
    }
  }


  //import
  Future<void> _importTeam(int group, int slot, StateSetter setDialogState, bool isEmptySlot) async{
    String teamId = _idController.text.trim();
    if (teamId.isEmpty) return;

    setDialogState(() => _isDialogLoading = true);

    try{
      var duplicateCheck = await FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).collection('participants')
         .where('team_id', isEqualTo: teamId).get();

      if (duplicateCheck.docs.isNotEmpty) {
        if (mounted) {
          _showSnackBar("This team is already registered in this tournament!");
        }
        Navigator.pop(context);
        return;
      }

      var teamDoc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();

      if (teamDoc.exists) {
        await _saveParticipant(group, slot, teamDoc.id, true, isEmptySlot);
        if(mounted) Navigator.pop(context);
      }
      else {
        _showSnackBar("Team not found.");
        Navigator.pop(context);
      }
    }
    catch(e){
      _showSnackBar("Something went wrong.");
      Navigator.pop(context);
    }
    finally {
      setDialogState(() => _isDialogLoading = false);
    }
  }


  // create
  Future<void> _createNewTeam(int group, int slot, StateSetter setDialogState, bool isEmptySlot) async {
    if (_nameController.text.isEmpty) return;

    final String currentUserUid = Provider.of<UserProvider>(context, listen: false).uid;

    if (currentUserUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to create a team.", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1E1E24))
      );
      return;
    }

    setDialogState(() => _isDialogLoading = true);

    try {
      String? logoUrl;

      if (_manualImageUrl != null && _manualImageUrl!.isNotEmpty) {
        logoUrl = _manualImageUrl;
      }
      else if (kIsWeb && _webImage != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromByteData(
            ByteData.view(_webImage!.buffer),
            identifier: 'team_${DateTime.now().millisecondsSinceEpoch}',
            resourceType: CloudinaryResourceType.Image,
          )
        );
        logoUrl = response.secureUrl;
      }
      else if(!kIsWeb && _pickedImage != null){
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_pickedImage!.path, resourceType: CloudinaryResourceType.Image),
        );
        logoUrl = response.secureUrl;
      }

      DocumentReference newTeam = await FirebaseFirestore.instance.collection('teams').add({
        'name': _nameController.text.trim(),
        'name_lowercase': _nameController.text.toLowerCase().trim(),
        'logo_url': logoUrl,
        'created_at': FieldValue.serverTimestamp(),
        'country': _selectedCountry,
        'flag': _selectedflag,
        'admins': [currentUserUid],
      });

      await _saveParticipant(group, slot, newTeam.id, false, isEmptySlot);

      if(mounted) Navigator.pop(context);
    } catch(e){
      debugPrint("Error creating team: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong.", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1E1E24))
      );
    } finally {
      setDialogState(() => _isDialogLoading = false);
    }
  }


  // Save
  Future<void> _saveParticipant(int groupIndex, int slotIndex, String teamId, bool imported, bool isEmptySlot) async {
    String groupName = String.fromCharCode(65 + groupIndex);
    String slotId = "Group${groupName}_Slot$slotIndex";

    DocumentReference tournamentRef = FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId);
    DocumentReference participantRef = tournamentRef.collection('participants').doc(slotId);

    DocumentSnapshot existingDoc = await participantRef.get();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (!existingDoc.exists){
      batch.set(participantRef, {
      'team_id': teamId,
      'group': groupName,
      'slot_index': slotIndex,
      'played': 0,
      'won': 0,
      'drawn': 0,
      'lost': 0,
      'points': 0,
      'scored': 0,
      'conceded': 0,
      'difference': 0,
      'imported': imported,
      'added_at': FieldValue.serverTimestamp(),
      });
    }
    else{
      batch.update(participantRef, {
        'team_id': teamId,
        'imported': imported,
        'added_at': FieldValue.serverTimestamp(),
      });
    }

    if(isEmptySlot) {
      batch.update(tournamentRef, {
        'participant_count': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  void _clearDialogData() {
    _idController.clear();
    _nameController.clear();
    _manualImageUrl = null;
    _pickedImage = null;
    _webImage = null;
    _selectedflag = null;
    _selectedCountry = null;
  }


  void confirmDeleteTeam(BuildContext context, String team, String slotId) {
    showDialog(
      context: context,
      builder: (confirmContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Text(
                      "You are removing $team. Are you sure?",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  
                  const Divider(color: Colors.white10, height: 1),

                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
                            onTap: () => Navigator.pop(confirmContext),
                            child: Container(
                              alignment: Alignment.center,
                              height: 60,
                              child: const Text("Cancel", style: TextStyle(color: Colors.purple, fontSize: 16.0, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        
                        const VerticalDivider(color: Colors.white10, width: 1),

                        // Remove Button
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                            onTap: () {
                              _deleteParticipant(slotId);
                              Navigator.pop(confirmContext);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 60,
                              child: const Text(
                                "Remove",
                                style: TextStyle(color: Colors.redAccent, fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteParticipant(String slotId) async {
    DocumentReference tournamentRef = FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId);
    DocumentReference participantRef = tournamentRef.collection('participants').doc(slotId);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.update(participantRef, {
      'team_id': null,
      'team_name': null,
      'team_logo': null,
    });

    batch.update(tournamentRef, {
      'participant_count': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  bool _isValidImageLink(String url) {
    return RegExp(r'\.(png|jpg|jpeg)(\?.*)?$', caseSensitive: false).hasMatch(url);
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E1E24))
    );
  }
}