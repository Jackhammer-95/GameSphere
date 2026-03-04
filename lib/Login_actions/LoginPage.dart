import 'package:flutter/material.dart';
import 'package:gamesphere/Login_actions/SignUpPage.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameSphereLogin extends StatefulWidget {
  const GameSphereLogin({super.key});

  @override
  State<GameSphereLogin> createState() => _GameSphereLoginState();
}

class _GameSphereLoginState extends State<GameSphereLogin> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
            toolbarHeight: 50.0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 23,),
              onPressed: () => Navigator.pop(context),
            ),
          ),
      body: Row(
        children: [
          if (!context.isMobile)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      const Color.fromARGB(255, 71, 71, 168),
                      Theme.of(context).colorScheme.primary,
                      const Color.fromARGB(255, 57, 40, 117)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Image.asset("Assets/images/icon_GameSphere.png", height: (context.screenHeight < 650)? 70 : 100,),
                          Image.asset("Assets/images/title_GameSphere.png", height: (context.screenHeight < 650)? 40 : 62.0,)
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Manage your\ntournaments with\nprecision.",
                        style: TextStyle(
                          fontSize: (context.screenHeight < 650)? 25 : 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Join GameSphere to see standings and match schedules.",
                        style: TextStyle(
                          fontSize: (context.screenHeight < 650)? 15 : 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // RIGHT SIDE: Login part
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF0E0E12),
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile? 24: size.width*0.08,
              ),
              child: Center(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (context.isMobile) ...[
                          Image.asset("Assets/images/icon_GameSphere.png", height: 60.0,),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          "Log In To Your Account",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                  
                        _buildLabel("Email Address"),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: _inputDecoration(
                            hint: "name@email.com",
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 24),
                  
                        _buildLabel("Password"),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _inputDecoration(
                            hint: "",
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                  
                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async{
                              // Firebase Auth link korsi
                              setState(() {_isLoading = true;});
                              try {
                                await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                                if (mounted) Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Login Failed: ${e.toString()}", style: TextStyle(color: Colors.white)),
                                    backgroundColor: Color(0xFF1E1E24)
                                  ),
                                );
                                if(mounted) setState(() {_isLoading = false;});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading? null: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading? CircularProgressIndicator()
                            : const Text(
                              "LOGIN",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                  
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));},
                              child: const Text("Sign Up"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF1E1E24),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
    );
  }
}