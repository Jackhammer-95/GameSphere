import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:gamesphere/screens/ProfileDashboard.dart';
import 'package:provider/provider.dart';


void showProfileDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (context) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 60, right: 20),
          child: Material(
            color: Colors.transparent,
            child: Consumer<UserProvider>(
              builder: (context, userprov, child) {
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // User Info Section
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  user.email!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 12),
                                CircleAvatar(
                                  backgroundColor: Colors.white30,
                                  radius: 37,
                                  child: CircleAvatar(
                                    radius: 36,
                                    backgroundColor: const Color.fromARGB(255, 57, 92, 109),
                                    child: Text(
                                      userprov.initial,
                                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                    
                                // role display
                                Text(
                                  userprov.role,
                                  style: TextStyle(color: userprov.role == "superAdmin" ? Colors.amber: Colors.grey, fontSize: 14),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Hi, ",
                                      style: TextStyle(color: Colors.white, fontSize: 24),
                                    ),
                                    Flexible(
                                      child: Text(
                                        userprov.firstName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white, fontSize: 24),
                                      ),
                                    ),
                                    const Text(
                                      "!",
                                      style: TextStyle(color: Colors.white, fontSize: 24),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          
                          // Menu Options
                          ListTile(
                            leading: const Icon(Icons.emoji_events_outlined, color: Colors.white70),
                            title: const Text("Showcase", style: TextStyle(color: Colors.white, fontSize: 14)),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.person_outlined, color: Colors.white70),
                            title: const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 14)),
                            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileDashboard()),);},
                          ),
                          
                          const Divider(color: Colors.white10, height: 1),
                          
                          // Sign Out
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextButton.icon(
                              onPressed: () {
                                confirmSignOut(context);
                              },
                              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                              label: const Text("Sign Out", style: TextStyle(color: Colors.redAccent)),
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      );
    },
  );
}


//alertdialog by dialogbox here
void confirmSignOut(BuildContext context) {
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Text(
                    "Are you sure you want to sign out?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                
                const Divider(color: Colors.white10, height: 1),

                IntrinsicHeight( // Ensures the divider matches button height
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

                      // Sign Out Button
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);      // Close profile dialog
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: const Text(
                              "Sign Out",
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