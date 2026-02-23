import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void confirmDeleteTournament(BuildContext context, String tournamentId, {bool call = false}) {
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
                    "Do you want to delete this tournament?",
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

                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                          onTap: () {
                            againConfirmDeleteTournament(context, confirmContext, tournamentId, call: call);
                          },

                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: const Text(
                              "Delete",
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


void againConfirmDeleteTournament(BuildContext context, BuildContext confirmContext, String tournamentId, {bool call = false}) {
  showDialog(
    context: confirmContext,
    builder: (againConfirmContext) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 310,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Text(
                    "You are deleting this tournament.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Text(
                    "Are you sure?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),

                const Divider(color: Colors.red, height: 1),
                IntrinsicHeight( // Ensures the divider matches button height
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
                          onTap: (){
                            Navigator.pop(againConfirmContext);
                            Navigator.pop(confirmContext);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: const Text("Cancel", style: TextStyle(color: Colors.purple, fontSize: 16.0, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      
                      const VerticalDivider(color: Colors.red, width: 1),

                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
                          onTap: () async {
                            try{
                              await FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).delete();

                              if(againConfirmContext.mounted){
                                Navigator.pop(againConfirmContext);
                                if(confirmContext.mounted) Navigator.of(confirmContext).pop();
                                if(context.mounted && call) Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Tournament deleted Successfully!", style: TextStyle(color: Colors.white)),
                                  backgroundColor: Color(0xFF1E1E24)),
                                );
                              }
                            }
                            catch (e){
                              if(againConfirmContext.mounted){
                                Navigator.pop(againConfirmContext);
                                if(confirmContext.mounted) Navigator.of(confirmContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e", style: TextStyle(color: Colors.white)),
                                  backgroundColor: Color(0xFF1E1E24)),
                                );
                              }
                            }
                          },

                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: const Text(
                              "Delete",
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