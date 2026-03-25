import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gamesphere/structures/Explore.dart';
import 'package:gamesphere/structures/MyTournament.dart';
import 'package:gamesphere/structures/SearchTeams.dart';
import 'TheProvider.dart';
import 'Login_actions/LoginPage.dart';
import 'firebase_options.dart';
import 'package:gamesphere/widgets/ProfileDialog.dart';
import 'package:provider/provider.dart'; // is it package?
import 'structures/CreateTournmnt.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const GameSphereApp(),
      )
    );
}

class GameSphereApp extends StatelessWidget {
  const GameSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 75, 75, 162),
          secondary: Color.fromARGB(255, 0, 229, 255),
          surface: Color.fromARGB(255, 30, 30, 36),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ),
      home: const GameSphereHome(),
    );
  }
}

class GameSphereHome extends StatelessWidget {
  const GameSphereHome({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bool loggedIn = snapshot.hasData && (snapshot.data != null);
        final User? user = snapshot.data;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              spacing: 0.0,
              children: [
                // ITS LOGO TIME!!!
                Container(
                  padding: context.isMobile? const EdgeInsets.all(4): const EdgeInsets.all(8),
                  child: Image.asset("Assets/images/icon_GameSphere.png", height: context.isMobile? 35.0: 45.0,)
                ),
                Image.asset("Assets/images/title_GameSphere.png", height: context.isMobile? 30.0 : 45.0,)
              ],
            ),
            actions: [
              // Login button time!!!
              if(loggedIn) IconButton(
                onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchTeamPage()),)},
                icon: const Icon(Icons.notifications_outlined, size: 25.0, color: Colors.white),
              ),
              context.isMobile ? const SizedBox(width: 2.0) : const SizedBox(width: 18.0),
              buildProfileOrLogin(context, loggedIn, user)
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                VideoBackground(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          "ORGANIZE • COMPETE • WIN",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "The Ultimate\nTournament Manager",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(
                          width: 600,
                          child: Text(
                            "Automate scheduling, track live results, and manage teams in one centralized hub. Designed for organizers, players, and spectators.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // BUTTONS SETUP HERE
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                loggedIn ? {Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTournamentPage()),)}
                                :{
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GameSphereLogin()),),
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text("Please login into your account first.", style: TextStyle(color: Colors.white)),
                                    backgroundColor: Color(0xFF1E1E24),
                                  ))
                                };
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              child: const Text("CREATE TOURNAMENT"),
                            ),
                            if(loggedIn) ElevatedButton(
                              onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MyTournament()),);},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 57, 57, 81),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              child: const Text(" MY TOURNAMENTS "),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0,),
                        TextButton(
                          onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const ExplorePage()),);},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("EXPLORE →"),
                        ),
                        SizedBox(height: 200.0,),
                      ],
                    ),
                  ),
                ),
                _featuresSection(context),
                _theFooter(),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _featuresSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF0E0E12),
      child: Column(
        children: [
          Text(
            "Why GameSphere?",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 60),
          
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                context,
                Icons.calendar_month_outlined,
                "Auto Scheduling",
                "Automate match scheduling effortlessly.",
              ),
              _buildFeatureCard(
                context,
                Icons.bolt_outlined,
                "Match Updates",
                "Match results and standings for participants and spectators.",
              ),
              _buildFeatureCard(
                context,
                Icons.groups_outlined,
                "Team Management",
                "Centralized system for managing players, teams, and registrations.",
              ),
              _buildFeatureCard(
                context, 
                Icons.analytics_outlined, 
                "AI Insights", // 
                "Get insights into a team's or player's historical performance.",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String desc) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _theFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.black,
      width: double.infinity,
      child: const Text(
        "© 2026 GameSphere. Department of CSE, CUET.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}


class VideoBackground extends StatefulWidget {
  final Widget child;
  const VideoBackground({super.key, required this.child});

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground>{
  late VideoPlayerController _controller;

  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.asset("Assets/videos/HD_homeBG_GameSphere.mp4")..initialize().then((_){
      if(mounted){
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        setState(() {});
      }
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
            ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
            : Image.asset(
              "Assets/images/Homepage_extended_GameSphere.jpg",
              fit: BoxFit.cover,
            )
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          widget.child,
        ],
      ),
    );
  }
}