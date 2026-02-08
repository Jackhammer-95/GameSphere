import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import 'package:gamesphere/TheProvider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _studentIdController;
  late TextEditingController _bioController;
  late TextEditingController _instController;
  late TextEditingController _phoneController;
  String selectedCountry = "Select Country";
  String selectedFlag = "🌍";
  String selectedDob = "(Select Date of Birth)";
  int age = 0;

  @override
  void initState(){
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _fnameController = TextEditingController(text: user.firstName);
    _lnameController = TextEditingController(text: user.lastName);
    _studentIdController = TextEditingController(text: user.id);
    _bioController = TextEditingController(text: user.bio);
    _instController = TextEditingController(text: user.institution);
    _phoneController = TextEditingController(text: user.phone);
    selectedCountry = user.country;
    selectedFlag = user.flag;
    selectedDob = user.dob;
    age = user.age;
  }

  @override
  void dispose(){
    _fnameController.dispose();
    _lnameController.dispose();
    _studentIdController.dispose();
    _bioController.dispose();
    _instController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime(2025),
      builder: (context, child){
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E24),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      }
    );
    if(picked != null){
      setState(() {
        age = (DateTime.now().year - picked.year);
        if(DateTime.now().month < picked.month) {age--;}
        else if((DateTime.now().month == picked.month) && (DateTime.now().day < picked.day)) {age--;}
        selectedDob = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFF1E1E24),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 50.0,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 23,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          if(!context.isMobile)Expanded(
            flex: 10,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0E0E12),
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              ),
            ),
          ),
          if(!context.isMobile) VerticalDivider(width: 2.0, color: Colors.white30),
          Expanded(
            flex: 30,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 37, 37, 45),
                ),
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // const SizedBox(height: 24.0),
                        Container(
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(24.0),
                            // border: context.isMobile? Border.all() : Border.symmetric(vertical: BorderSide(width: 2.0, color: Colors.white30)),
                            color: Colors.black26,
                          ),
                          child: ClipRRect(
                            // borderRadius: BorderRadius.circular(22.0),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          height: 180,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context).colorScheme.primary,
                                                const Color(0xFF1E1E24),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: const Color(0xFF0E0E12),
                                          padding: EdgeInsets.all(30.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 50.0),
                                              _buildEditField("Bio", _bioController, maxLines: 3),
                                              Divider(height: 1.0, color: Colors.white30),
                                              const SizedBox(height: 30.0),
                                              _buildEditField("First Name", _fnameController),
                                              _buildEditField("Last Name", _lnameController),
                                              _buildEditField("ID", _studentIdController),
                                              _buildEditField("Institution", _instController),
                                              _buildEditField("Phone Number", _phoneController),
                                              SizedBox(height: 5.0,),
                                              // Date of birth
                                              Text("     Date of Birth", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              const SizedBox(height: 5.0),
                                              InkWell(
                                                onTap:() => _selectDob(context),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF1E1E24),
                                                    border: Border.all(color: Colors.white30),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        selectedDob,
                                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                                      ),
                                                      const Spacer(),
                                                      const Icon(Icons.edit, color: Colors.grey, size: 16)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10.0,),
                                              Text("     Country", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              SizedBox(height: 5.0),
                                              InkWell(
                                                onTap: (){
                                                  showCountryPicker(
                                                    moveAlongWithKeyboard: true,
                                                    context: context,
                                                    showPhoneCode: false,
                                                    exclude: <String> ['IL', 'IM', 'AX', 'AC', 'IO', 'BQ', 'CX', 'FK', 'PF', 'FO', 'GG', 'JE', 'NF', 'TK', 'WF'],
                                                    onSelect: (Country country){
                                                      setState(() {
                                                        if(country.countryCode == 'PS'){
                                                          selectedCountry = "Palestine";
                                                        }
                                                        else{
                                                          selectedCountry = country.name;
                                                        }
                                                        selectedFlag = country.flagEmoji;
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
                                                      Text(selectedFlag, style: const TextStyle(fontSize: 24),),
                                                      Text(
                                                        selectedCountry,
                                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                                      ),
                                                      Spacer(),
                                                      const Icon(Icons.arrow_drop_down, color: Colors.grey,)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20.0),
                                              Row(
                                                children: [
                                                  Spacer(),
                                                  SizedBox(
                                                    height: 40,
                                                    width: 90,
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        if(_fnameController.text.trim().isEmpty){
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                            content: Text("Please fill in all required fields.",
                                                            style: TextStyle(color: Colors.white)),
                                                            backgroundColor: Color(0xFF1E1E24),
                                                          ));
                                                          return;
                                                        }
                                                        bool success = await userProv.updateProfile(
                                                          fname: _fnameController.text,
                                                          lname: _lnameController.text,
                                                          bio: _bioController.text,
                                                          id: _studentIdController.text,
                                                          inst: _instController.text,
                                                          phone: _phoneController.text,
                                                          country: selectedCountry,
                                                          flag: selectedFlag,
                                                          dob: selectedDob,
                                                          age: age,
                                                        );
                                                        if(success && mounted) Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                      child: Text("Save", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Positioned(
                                      top: 120.0,
                                      left: 30.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.black, width: 5),
                                        ),
                                        child: CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          child: Text(
                                            userProv.initial,
                                            style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(!context.isMobile) VerticalDivider(width: 2.0, color: Colors.white30),
          if(!context.isMobile)Expanded(
            flex: 10,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 57, 40, 117),
                    const Color(0xFF0E0E12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              ),
            ),
          ),
        ],
      )
    );
  }
}


Widget _buildEditField(String label, TextEditingController controller, {int maxLines = 1}){
  return Padding(
    padding: (label == "Phone Number") ? const EdgeInsets.only(bottom: 5) : const EdgeInsets.only(bottom: 25),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E24),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    ),
  );
}