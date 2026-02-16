import 'package:flutter/material.dart';

Widget buildInfoTab(BuildContext context, Map<String, dynamic> data) {
  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _infoStatCard("HOST", data['host_name'] ?? "N/A", Icons.person_pin_rounded),
                  const SizedBox(width: 10),
                  _infoStatCard("SPORT", data['sport'] ?? "General", Icons.sports_basketball_rounded),
                ],
              ),
              const SizedBox(height: 30),
              _sectionTitle("ABOUT TOURNAMENT"),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_outlined, color: Colors.blueAccent.withOpacity(0.8), size: 24),
                        const SizedBox(width: 8),
                        const Text("Description", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                      child: Divider(color: Colors.white10),
                    ),
                    Text(
                      (data['description'].isEmpty || data['description'] == null)? "(No description provided for this tournament.)": data['description'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _infoStatCard(String label, String value, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E24), const Color(0xFF1E1E24).withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11,)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
        ],
      ),
    ),
  );
}

Widget _sectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      color: Colors.blueAccent,
      fontSize: 12,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    ),
  );
}