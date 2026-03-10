import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/TheProvider.dart';

class SignUpPage extends StatefulWidget{
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _passwordvisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async{
    if(_emailController.text.isEmpty || _passwordController.text.isEmpty || _firstnameController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields",style: TextStyle(color: Colors.white)),backgroundColor: Color(0xFF1E1E24))
      );
      return;
    }

    setState(() => _isLoading = true);
    try{
      // Creates user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'firstname': _firstnameController.text.trim(),
        'lastname' : _lastnameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'bio': '',
        'createAt': DateTime.now(),
        'country': 'unknown',
        'flag': '🌍',
        'phone': '',
        'institution': '',
        'dob': '(Select Date of Birth)',
        'age': 0,
      });

      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created!", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1E1E24))
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
    on FirebaseAuthException catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Error", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF1E1E24))
        );
    }
    finally{
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 23),
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Row(
        children: [
          if(!context.isMobile)Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    const Color.fromARGB(255, 87, 87, 201),
                    Theme.of(context).colorScheme.primary,
                    const Color.fromARGB(255, 77, 71, 177),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: SingleChildScrollView(
                padding: context.isMobile? const EdgeInsets.symmetric(horizontal: 40): const EdgeInsets.symmetric(horizontal: 80),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset("Assets/images/icon_GameSphere.png", height: 50.0),
                    SizedBox(height: 20),
                    Text("Join GameSphere", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 40),
            
                    _buildField("First Name", _firstnameController, Icons.person_outlined),
                    const SizedBox(height: 16),
                    _buildField("Last Name", _lastnameController, Icons.person_outlined),
                    const SizedBox(height: 16),
                    _buildField("Student ID", _studentIdController, Icons.badge_outlined),
                    const SizedBox(height: 16),
                    _buildField("Email", _emailController, Icons.email_outlined),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordvisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E1E24),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                            _passwordvisible = !_passwordvisible;
                          }),
                          icon: Icon(
                            _passwordvisible? Icons.visibility: Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    _isLoading? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                        child: const Text(
                          "CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          if(!context.isMobile)Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    const Color.fromARGB(255, 67, 56, 139),
                    Theme.of(context).colorScheme.primary,
                    const Color.fromARGB(255, 57, 40, 117),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, IconData icon, {bool isPass = false}){
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E24),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }
}