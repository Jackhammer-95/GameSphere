import 'package:flutter/material.dart';
import 'package:gamesphere/structures/NextPageCreateTour.dart';
import 'package:provider/provider.dart';
import 'package:gamesphere/TheProvider.dart';


class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _hostController;
  late TextEditingController _descController;
  late TextEditingController _passwordController;
  late TextEditingController _customSportController;
  bool _isPasswordNeeded = false;
  bool _obsecurePassword = true;
  
  String _selectedSport = 'Football';
  int _selectedFormatIndex = 0; // 0: Group, 1: Mixed, 2: Knockout

  final List<String> _sports = ['Football', 'Cricket', 'Others'];
  
  final List<Map<String, dynamic>> _formats = [
    {
      'title': 'Group Phase only', 
      'image': 'Assets/images/Homepage_extended_GameSphere.jpg',
    },
    {
      'title': 'Group Phase & Knockout Phase',
      'image': 'Assets/images/Homepage_extended_GameSphere.jpg',
    },
    {
      'title': 'Knockout Phase only', 
      'image': 'Assets/images/Homepage_extended_GameSphere.jpg', 
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _titleController = TextEditingController();
    _hostController = TextEditingController(text: "${user.firstName} ${user.lastName}");
    _descController = TextEditingController();
    _passwordController = TextEditingController();
    _customSportController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      extendBodyBehindAppBar: context.isMobile? false: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: context.isMobile? Text("CREATE  TOURNAMENT", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,)): null,
        elevation: 0,
        toolbarHeight: 45.0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: context.isMobile? null
          : DecorationImage(
            image: AssetImage("Assets/images/Homepage_extended_GameSphere.jpg"),
            fit: BoxFit.cover,
          )
        ),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                color: const Color(0xFF0E0E12),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(!context.isMobile) Center(child: const Text("CREATE  TOURNAMENT", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,))),
                      _buildSectionTitle("BASIC INFORMATION"),
                      const SizedBox(height: 20),
                      _buildTextField("Tournament Title*", _titleController, "e.g. Champions League 2026"),
                      const SizedBox(height: 16),
                      _buildTextField("Host Name*", _hostController, "Organizer Name"),
                      const SizedBox(height: 16),
                      _buildTextField("Description", _descController, "Rules, prizes, or general info...", maxLines: 4),
                      const SizedBox(height: 25),
                      _buildPrivacyToggle(),
                      if(_isPasswordNeeded) const SizedBox(height: 16),
                      if(_isPasswordNeeded) _buildTextField("Set Password*", _passwordController, "Enter access password", suffix: true),
                      
                      const SizedBox(height: 40),
                      _buildSectionTitle("CHOOSE SPORT"),
                      const SizedBox(height: 16),
                      _buildSportChips(),
                          
                      const SizedBox(height: 40),
                      _buildSectionTitle("SELECT FORMAT"),
                      const SizedBox(height: 16),
                      
                      context.isMobile? _mobileFormatSelector() : _webFormatSelector(),
                          
                      const SizedBox(height: 60),
                      _buildNextButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1, bool suffix = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  $label", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value){
            if((value == null || value.isEmpty) && label != 'Description'){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Please fill in all required fields.", style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFF1E1E24),
              ));
              return 'Please enter the $label';
            }
            return null;
          },
          maxLines: maxLines,
          obscureText: suffix? _obsecurePassword: false,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: const Color(0xFF1E1E24),
            suffixIcon: (suffix)? IconButton(
              onPressed:() => setState(() {
                _obsecurePassword = !_obsecurePassword;
              }),
              icon: Icon(_obsecurePassword? Icons.visibility_off: Icons.visibility, color: Colors.grey),
            ): null,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle(){
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: IntrinsicHeight( // Ensures kore divider matches button height
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  onTap: () => setState(() {_isPasswordNeeded = false;}),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      color: _isPasswordNeeded? Colors.transparent : Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text("Public", style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              
              const VerticalDivider(color: Colors.white10, width: 1),
        
              Expanded(
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                  onTap: () => setState(() {_isPasswordNeeded = true;}),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                      color: _isPasswordNeeded? Theme.of(context).colorScheme.primary : Colors.transparent,
                    ),
                    child: const Text(
                      "Private",
                      style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          children: _sports.map((sport) {
            bool isSelected = _selectedSport == sport;
            return ChoiceChip(
              showCheckmark: false,
              label: Text(sport),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedSport = sport),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: const Color(0xFF1E1E24),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: isSelected ? Colors.transparent : Colors.white10),
            );
          }).toList(),
        ),
        if (_selectedSport == 'Others') ...[
          const SizedBox(height: 16),
          _buildTextField("Specify Name", _customSportController, "Enter sport name (e.g. Basketball)"),
        ],
      ],
    );
  }

  Widget _webFormatSelector() {
    return Row(
      children: List.generate(_formats.length, (index) {
        bool isSelected = _selectedFormatIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFormatIndex = index),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8, 
                right: index == _formats.length - 1 ? 0 : 8
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white10,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      _formats[index]['image'],
                      width: double.infinity,
                      height: 140.0,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formats[index]['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _mobileFormatSelector() {
    return Column(
      children: List.generate(_formats.length, (index) {
        bool isSelected = _selectedFormatIndex == index;
        return Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              child: GestureDetector(
                onTap: () => setState(() => _selectedFormatIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white10,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Image Section
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                _formats[index]['image'],
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _formats[index]['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentSettingsPage(
                  title: _titleController.text.trim(),
                  hostname: _hostController.text.trim(),
                  description: _descController.text.trim(),
                  sport: _selectedSport == 'Others' ? _customSportController.text.trim() : _selectedSport,
                  format: _selectedFormatIndex,
                  password: _isPasswordNeeded? _passwordController.text.trim():null,
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        child: const Text("NEXT →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}