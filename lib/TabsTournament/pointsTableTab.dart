import 'package:flutter/material.dart';

Widget buildPointsTableTab() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("GROUP A", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1000),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.purple),
              columnSpacing: 25,
              horizontalMargin: 15,
              headingTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Center(child: Text("TEAM NAME", ))),
                DataColumn(label: Center(child: Text("PLAYED"))),
                DataColumn(label: Center(child: Text("WON"))),
                DataColumn(label: Center(child: Text("LOST"))),
                DataColumn(label: Center(child: Text("GOAL\nDIFFERENCE", textAlign: TextAlign.center,))),
                DataColumn(label: Center(child: Text("POINTS"))),
              ],
              rows: List.generate(4, (index) => DataRow(cells: [
                DataCell(Center(child: Text("Team ${index + 1}", style: const TextStyle(color: Colors.white)))),
                const DataCell(Center(child: Text("3", style: TextStyle(color: Colors.white)))),
                const DataCell(Center(child: Text("2", style: TextStyle(color: Colors.white)))),
                const DataCell(Center(child: Text("1", style: TextStyle(color: Colors.white)))),
                const DataCell(Center(child: Text("+4", style: TextStyle(color: Colors.white)))),
                const DataCell(Center(child: Text("6", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)))),
              ])),
            ),
          ),
        ),
      ],
    ),
  );
}