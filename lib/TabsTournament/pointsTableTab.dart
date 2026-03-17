import 'package:flutter/material.dart';
import 'package:gamesphere/TheProvider.dart';

class buildPointsTableTab extends StatelessWidget {
  final Map<String, dynamic> data;

  const buildPointsTableTab({super.key, required this.data});

  @override
  Widget build(BuildContext context){
    int groupCount = data['no_of_groups'] ?? 0;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groupCount,
      itemBuilder: (context, index){
        String groupName = String.fromCharCode(65+index);

        return Column(
          children: [
            _buildSingleGroupTable(context, "GROUP $groupName"),
            const SizedBox(height: 32)
          ],
        );
      },
    );
  }

  Widget _buildSingleGroupTable(BuildContext context, String title) {
    DataCell buildCenterCell(int value){
      return DataCell(SizedBox(width:context.isMobile? 45:90, child: Text("$value", style: TextStyle(color: Colors.white), textAlign: TextAlign.center)));
    }

    DataColumn buildCenterColumn(String text){
      return DataColumn(label: SizedBox(width:context.isMobile?45: 90, child: Text(text, textAlign: TextAlign.center)));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E24)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.purple),
                  columnSpacing: 0,
                  horizontalMargin: 15,
                  columns: [
                    DataColumn(label: SizedBox(width: 150, child: Text("TEAM NAME", textAlign: TextAlign.center))),
                  ],
                  rows: List.generate(data['teams_per_group'], (index) => DataRow(
                    cells: [
                      DataCell(SizedBox(width: 150, child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                        child: Text("Paris Saint Germain ${index + 1}", style: const TextStyle(color: Colors.white))
                      ))),
                    ]
                  )),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.purple),
                      columnSpacing: 0,
                      horizontalMargin: 15,
                      headingTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      columns: [
                        buildCenterColumn(context.isMobile? "P":"PLAYED"),
                        buildCenterColumn(context.isMobile? "W":"WON"),
                        buildCenterColumn(context.isMobile? "D":"DRAWN"),
                        buildCenterColumn(context.isMobile? "L":"LOST"),
                        buildCenterColumn(context.isMobile? "PTS":"POINTS"),
                        buildCenterColumn(context.isMobile? "GS":"GOALS\nSCORED"),
                        buildCenterColumn(context.isMobile? "GC":"GOALS\nCONCECDED"),
                        buildCenterColumn(context.isMobile? "GD":"GOAL\nDIFFERENCE"),
                      ],
                      rows: List.generate(data['teams_per_group'], (index) => DataRow(cells: [
                        buildCenterCell(3),
                        buildCenterCell(2),
                        buildCenterCell(0),
                        buildCenterCell(1),
                        DataCell(SizedBox(width:context.isMobile? 45:90, child: Text("6", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                        buildCenterCell(6),
                        buildCenterCell(2),
                        buildCenterCell(4),
                      ])),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}