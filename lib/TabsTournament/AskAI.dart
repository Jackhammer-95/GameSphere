import 'package:flutter/material.dart';

Widget buildAskAiTab(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.analytics_outlined, size: 100, color: Colors.white.withOpacity(0.05)),
        const SizedBox(height: 20),
        Center(child: Text("Ask AI", style: TextStyle(color: Colors.white24))),
      ],
    );
  }