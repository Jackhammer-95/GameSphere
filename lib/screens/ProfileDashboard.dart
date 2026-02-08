import 'package:flutter/material.dart';
import 'package:gamesphere/screens/EditProfile.dart';
import 'package:provider/provider.dart';
import 'package:gamesphere/TheProvider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileDashboard extends StatelessWidget {
  const ProfileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFF1E1E24),
      body: Row(
        children: [
          if (!context.isMobile)
            Expanded(
            flex: 10,
            child: Container(
              height: double.infinity,
              color: const Color(0xFF1E1E24),
              padding: const EdgeInsets.fromLTRB(18.0, 5.0, 18.0, 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(width: 2.0, color: Colors.white30),
                        color: const Color.fromARGB(255, 37, 37, 45),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("MEMBER SINCE", 
                              style: TextStyle(fontSize: 11.0, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Colors.white70)),
                            const SizedBox(height: 4.0),
                            Text(userProv.joinedDate, style: const TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w500)),
                            
                            const SizedBox(height: 40.0),
                            
                            Row(
                              children: [
                                Text("PLAYER HISTORY", 
                                  style: TextStyle(fontSize: 11.0, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Colors.white70)),
                              ],
                            ),
                            const SizedBox(height: 20.0),

                            // History Timeline Items
                            _buildHistoryItem("2018", "2021", "Darkrai Sylhet Royals"),
                            _buildHistoryItem("2021", "2022", "Al Qadsiah"),
                            _buildHistoryItem("2022", "2024", "Newcastle United"),
                            _buildHistoryItem("2024", "2025", "FC Barcelona"),
                            _buildHistoryItem("2025", "Present", "Al Hilal"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if(!context.isMobile) VerticalDivider(width: 2.0, color: Colors.white30),
          Expanded(
            flex: 28,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: (!context.isMobile) ? Color(0xFF1E1E24) : const Color.fromARGB(255, 37, 37, 45),
                ),
                Padding(
                  padding: (context.isMobile) ? const EdgeInsets.all(0.0) : const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 0.0),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if(!context.isMobile) const SizedBox(height: 18.0),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.0),
                              border: (context.isMobile)? Border.all(width: 0.0)
                                :Border.all(width: 2.0, color: Colors.white30),
                              color: Color(0xFF1E1E24),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22.0),
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
                                            color: const Color.fromARGB(255, 37, 37, 45),
                                            padding: EdgeInsets.all(30.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 50.0),
                                                Row(
                                                  children: [
                                                    Text(userProv.firstName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)),
                                                    Text("   "),
                                                    Text(userProv.lastName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0)),
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                if(userProv.role == "superAdmin") Text(
                                                  userProv.role, style: TextStyle(color: Colors.amber, fontSize: 14)
                                                ),
                                                const SizedBox(height: 15.0),
                                                Text(userProv.bio),
                                                const SizedBox(height: 30.0),
                                                Divider(height: 1.0, color: Colors.white30),
                                                const SizedBox(height: 20.0),
                                                if(userProv.id.isNotEmpty)_buildDetailTile(Icons.badge_outlined, "ID", userProv.id),
                                                if(userProv.institution.isNotEmpty)_buildDetailTile(Icons.school_outlined, "Institution", userProv.institution),
                                                _buildDetailTile(Icons.public_outlined, "Country", "${userProv.flag} ${userProv.country}"),
                                                _buildDetailTile(Icons.email_outlined, "Email Address", userProv.email),
                                                if(userProv.phone.isNotEmpty)_buildDetailTile(Icons.phone_outlined, "Contact No.", userProv.phone),
                                                if(userProv.dob != "(Select Date of Birth)")_buildDetailTile(Icons.calendar_month_outlined, "Date of Birth", "${userProv.dob} (age ${userProv.age} years)"),
                                                const SizedBox(height: 15.0,),
                                                if(context.isMobile) Text("Member Since", 
                                                  style: TextStyle(fontSize: 11.0, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Colors.white70)),
                                                if(context.isMobile) const SizedBox(height: 4.0),
                                                if(context.isMobile) Text(userProv.joinedDate, style: const TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w500)),
                                                if(context.isMobile) const SizedBox(height: 20),
                                                if(context.isMobile) Center(
                                                  child: TextButton(
                                                    onPressed: () {
                                                      // Navigate to full showcase
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "VIEW FULL SHOWCASE →",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w900,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                                      Positioned(
                                        top: 200.0,
                                        right: 30.0,
                                        child: ElevatedButton(
                                          onPressed: () => {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()),)
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            spacing: 5.0,
                                            children: [
                                              Icon(Icons.edit),
                                              Text("Edit Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        )
                                      )
                                    ]
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if(!context.isMobile) const SizedBox(height: 18.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(!context.isMobile) VerticalDivider(width: 2.0, color: Colors.white30),
          if (!context.isMobile)
            Expanded(
              flex: 12,
              child: Container(
                height: double.infinity,
                color: const Color(0xFF1E1E24),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(width: 2.0, color: Colors.white30),
                          color: const Color.fromARGB(255, 37, 37, 45),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Row(
                              children: [
                                Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 30),
                                const SizedBox(width: 8),
                                Text(
                                  "HIGHLIGHTED TROPHIES",
                                  style: TextStyle(
                                    letterSpacing: 1.2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Trophy Boxes(Up to 6)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildTrophyBox(context, 3, "https://png.pngtree.com/png-clipart/20250621/original/pngtree-3d-ballon-d-or-football-trophy-no-background-png-image_21215466.png"),
                                _buildTrophyBox(context, 1, "https://png.pngtree.com/png-vector/20250923/ourmid/pngtree-the-fifa-world-cup-trophy-png-image_17551611.webp"),
                                _buildTrophyBox(context, 2, "https://png.pngtree.com/png-vector/20250611/ourmid/pngtree-fifa-club-world-cup-3d-trophy-png-image_16517957.png"),
                                _buildTrophyBox(context, 5, "https://upload.wikimedia.org/wikipedia/commons/2/2c/Premier_league_trophy_icon.png"),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to full showcase
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                                  ),
                                ),
                                child: Text(
                                  "VIEW FULL SHOWCASE →",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
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
            ),
        ],
      )
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyBox(BuildContext context, int num, String photo) {
    double boxSize = context.screenWidth; 

    return Stack(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Image.network(
                photo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.workspace_premium,
                  color: Colors.amber.withOpacity(0.8), 
                  size: 35
                ),
              ),
            ),
          ),
        ),
        if(num > 1) Positioned(
          bottom: 5.0,
          right: 5.0,
          child: CircleAvatar(
            radius: 12.0,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 11.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text("$num", style: GoogleFonts.aBeeZee(color: Colors.white),),
            ),
          ),
        )
      ],
    );
  }


  Widget _buildHistoryItem(String startYear, String endYear, String teamName) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: (endYear == "Present") ? const Color.fromARGB(255, 205, 200, 217): const Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
              ),
              if(endYear != "Present") Expanded(
                child: Container(
                  width: 2,
                  color: Colors.white10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          // Team Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "$startYear — $endYear",
                      style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teamName,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}