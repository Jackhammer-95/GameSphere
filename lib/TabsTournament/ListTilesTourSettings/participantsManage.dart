import 'package:flutter/material.dart';

class ManageParticipants extends StatefulWidget {
  final Map<String, dynamic> data;
  final PageController settingsPageController;

  const ManageParticipants({super.key, required this.data, required this.settingsPageController});

  @override
  State<ManageParticipants> createState() => _ManageParticipantsState();
}

class _ManageParticipantsState extends State<ManageParticipants> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
                  onPressed: (){
                    widget.settingsPageController.jumpToPage(1);
                    widget.settingsPageController.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                  },
                ),
                const SizedBox(width: 10),
                const Text("MANAGE  PARTICIPANTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Expanded(child: _buildGroups())
          ],
        ),
      ),
    );
  }

  Widget _buildGroups(){
    int groupCount = widget.data['no_of_groups'] ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: List.generate(groupCount, (index){
              String groupName = String.fromCharCode(65+index);
              return _buildSingleGroupTable("GROUP $groupName");
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSingleGroupTable(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                horizontalMargin: 5,
                headingTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                columns: [
                  DataColumn(label: SizedBox(width: 300, child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15)))),
                ],
                rows: List.generate(widget.data['teams_per_group'], (index) => DataRow(cells: [
                  DataCell(SizedBox(width: 300, child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.shield),
                      const SizedBox(width: 10),
                      SingleChildScrollView(scrollDirection: Axis.horizontal,
                        child: SizedBox(width: 205,
                          child: Text(
                            "Empty slot ${index + 1}",
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white)
                          )
                        )
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: (){},
                      )
                    ],
                  ))),
                ])),
              ),
            ),
          ),
        ),
      ],
    );
  }
}