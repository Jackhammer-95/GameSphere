import 'package:flutter/material.dart';

Widget buildKnockoutTab() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.account_tree_outlined, size: 100, color: Colors.white.withOpacity(0.05)),
        const SizedBox(height: 20),
        const Text("KNOCKOUT BRACKET GENERATING...", style: TextStyle(color: Colors.white24)),
      ],
    ),
  );
}