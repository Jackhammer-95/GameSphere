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
            constraints: const BoxConstraints(maxWidth: 1000),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.purple),
                columnSpacing: 0,
                horizontalMargin: 15,
                headingTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                columns: [
                  DataColumn(label: SizedBox(width: 150, child: Text("TEAM NAME", textAlign: TextAlign.center))),
                  _buildCenterColumn("PLAYED"),
                  _buildCenterColumn("WON"),
                  _buildCenterColumn("DRAWN"),
                  _buildCenterColumn("LOST"),
                  _buildCenterColumn("GOALS\nSCORED"),
                  _buildCenterColumn("GOALS\nCONCECDED"),
                  _buildCenterColumn("GOAL\nDIFFERENCE"),
                  _buildCenterColumn("POINTS"),
                ],
                rows: List.generate(4, (index) => DataRow(cells: [
                  DataCell(SizedBox(width: 150, child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Text("Paris Saint Germain ${index + 1}", style: const TextStyle(color: Colors.white))
                  ))),
                  _buildCenterCell(3),
                  _buildCenterCell(2),
                  _buildCenterCell(0),
                  _buildCenterCell(1),
                  _buildCenterCell(6),
                  _buildCenterCell(2),
                  _buildCenterCell(4),
                  const DataCell(SizedBox(width: 90, child: Text("6", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                ])),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

DataCell _buildCenterCell(int value){
  return DataCell(SizedBox(width: 90, child: Text("$value", style: TextStyle(color: Colors.white), textAlign: TextAlign.center)));
}

DataColumn _buildCenterColumn(String text){
  return DataColumn(label: SizedBox(width: 90, child: Text(text, textAlign: TextAlign.center)));
}