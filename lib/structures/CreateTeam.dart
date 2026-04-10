import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/structures/Team%20Profile/TeamProfile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:provider/provider.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  late TextEditingController _ownerController = TextEditingController();

  String _selectedCountry = "Select Country";
  String _selectedFlag = "🌍";
  
  String? _manualImageUrl;
  File? _pickedImage;
  Uint8List? _webImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final cloudinary = CloudinaryPublic('dt2f6qqvk', 'GameSphere', cache: false);

  @override
  void initState() {
    super.initState();
    final userProv = Provider.of<UserProvider>(context, listen: false);
    _ownerController = TextEditingController(text: "${userProv.firstName} ${userProv.lastName}");
  }

  @override
  void dispose(){
    _ownerController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
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
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.link, color: Colors.blueAccent),
            title: const Text("Enter Image Link", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showLinkInputDialog();
            },
          ),
          if(_manualImageUrl != null || _pickedImage != null || _webImage != null) ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text("Remove Logo", style: TextStyle(color: Colors.white)),
            onTap: () {
              setState(() {
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _pickedImage = File(image.path);
          _manualImageUrl = null;
        });
      } else {
        setState(() {
          _pickedImage = File(image.path);
          _manualImageUrl = null;
        });
      }
    }
  }

  void _showLinkInputDialog() {
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
                setState(() {
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

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;
    
    final userProv = Provider.of<UserProvider>(context, listen: false);
    if (!userProv.isLoggedIn) {
      _showSnackBar("Please login to your account first.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalLogoUrl;

      if (_manualImageUrl != null && _manualImageUrl!.isNotEmpty) finalLogoUrl = _manualImageUrl;

      else if (_pickedImage != null) {
        CloudinaryResponse response;
        if (kIsWeb) {
          response = await cloudinary.uploadFile(
            CloudinaryFile.fromByteData(
              ByteData.view(_webImage!.buffer),
              identifier: 'team_logo_${DateTime.now().millisecondsSinceEpoch}',
              resourceType: CloudinaryResourceType.Image,
            ),
          );
        } else {
          response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(_pickedImage!.path, resourceType: CloudinaryResourceType.Image),
          );
        }
        finalLogoUrl = response.secureUrl;
      }

      DocumentReference docRef = FirebaseFirestore.instance.collection('teams').doc();
      
      await docRef.set({
        'team_id': docRef.id,
        'name': _nameController.text.trim(),
        'name_lowercase': _nameController.text.trim().toLowerCase(),
        'bio': _bioController.text.trim(),
        'owner': _ownerController.text.trim(),
        'country': _selectedCountry,
        'flag': _selectedFlag,
        'logo_url': finalLogoUrl,
        'admins': [userProv.uid],
        'created_at': FieldValue.serverTimestamp(),
        'squad_size': 0,
        'manager': "",
        'stadium': "",
        'league': "",
        'location': "",
        'contact_email': "",
        'founded': "",
      });

      if (mounted) {
        _showSnackBar("Team Created Successfully!");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => TeamDashboard(teamId: docRef.id)),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      debugPrint("Error creating team: $e");
      if (mounted) {
        _showSnackBar("Something went wrong.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        title: const Text("CREATE NEW TEAM", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 5, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildLogoSection(),
                  const SizedBox(height: 30),
                  _buildTextField("Team Name*", _nameController, Icons.shield, required: true),
                  _buildTextField("Bio/Description", _bioController, Icons.info_outline, maxLines: 3),
                  _buildTextField("Owner Name", _ownerController, Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildCountryPicker(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createTeam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("CREATE TEAM", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    ImageProvider? displayImage;

    if (kIsWeb && _webImage != null) {displayImage = MemoryImage(_webImage!);}
    else if (!kIsWeb && _pickedImage != null) {displayImage = FileImage(_pickedImage!);}
    else if (_manualImageUrl != null && _manualImageUrl!.isNotEmpty) {displayImage = NetworkImage(_manualImageUrl!);}

    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(60),
      customBorder: const CircleBorder(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: CircleAvatar(
              radius: 58,
              backgroundColor: const Color(0xFF1E1E24),
              backgroundImage: displayImage,
              child: displayImage == null? const Icon(Icons.add_a_photo, color: Colors.white54, size: 40) : null
            ),
          ),
          if (displayImage != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 18,
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: required ? (value) => value!.isEmpty ? "This field is required" : null : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1E1E24),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
        ),
      ),
    );
  }

  bool _isValidImageLink(String url) {
    return RegExp(r'\.(png|jpg|jpeg)(\?.*)?$', caseSensitive: false).hasMatch(url);
  }

  Widget _buildCountryPicker() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          moveAlongWithKeyboard: true,
          context: context,
          showPhoneCode: false,
          exclude: <String> ['IL', 'IM', 'AX', 'AC', 'IO', 'BQ', 'CX', 'FK', 'PF', 'FO', 'GG', 'JE', 'NF', 'TK', 'WF'],
          onSelect: (Country country){
            setState(() {
              if(country.countryCode == 'PS'){
                _selectedCountry = "Palestine";
              }
              else{
                _selectedCountry = country.name;
              }
              _selectedFlag = country.flagEmoji;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Text(_selectedFlag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 15),
            Text(_selectedCountry, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E1E24))
    );
  }
}