import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void confirmDeleteSomething(
  BuildContext context,
  String somethingID,
  String thing,
  String confirmText,
  {bool call = false, VoidCallback? onSuccess}
) {

  showDialog(
    context: context,
    builder: (confirmContext) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Text(
                    confirmText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
                            againConfirmDeleteTournament(context, confirmContext, somethingID, thing, call: call, onSuccess: onSuccess);
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


void againConfirmDeleteTournament(
  BuildContext context,
  BuildContext confirmContext,
  String somethingID,
  String thing,
  {bool call = false, VoidCallback? onSuccess}
) {

  showDialog(
    context: confirmContext,
    builder: (againConfirmContext) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 310),
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
                    "Warning: This action is permanent. All data will be deleted and cannot be recovered.",
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
                              if(thing == "Tournament"){
                                WriteBatch batch = FirebaseFirestore.instance.batch();
                                DocumentReference tournamentRef = FirebaseFirestore.instance.collection('tournaments').doc(somethingID);

                                var matches = await tournamentRef.collection('matches').get();
                                for (var doc in matches.docs) {
                                  batch.delete(doc.reference);
                                }

                                var participants = await tournamentRef.collection('participants').get();
                                for (var doc in participants.docs) {
                                  batch.delete(doc.reference);
                                }

                                batch.delete(tournamentRef);

                                await batch.commit();

                                if(onSuccess != null) onSuccess();
                              }
                              
                              else if(thing == "Team"){
                                WriteBatch batch = FirebaseFirestore.instance.batch();
                                DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(somethingID);

                                var squadMembers = await teamRef.collection('players').get();
                                for (var doc in squadMembers.docs) {
                                  batch.delete(doc.reference);
                                }

                                batch.delete(teamRef);

                                await batch.commit();
                              }

                              if(againConfirmContext.mounted){
                                Navigator.pop(againConfirmContext);
                                if(confirmContext.mounted) Navigator.of(confirmContext).pop();
                                if(thing != "Team" && context.mounted && call) {Navigator.of(context).pop();}
                                else if(thing == "Team"){
                                  if(onSuccess != null) onSuccess();
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("$thing deleted Successfully!", style: TextStyle(color: Colors.white)),
                                  backgroundColor: Color(0xFF1E1E24)),
                                );
                              }
                            }
                            catch (e){
                              if(againConfirmContext.mounted){
                                Navigator.pop(againConfirmContext);
                                if(confirmContext.mounted) Navigator.of(confirmContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: something went wrong.", style: TextStyle(color: Colors.white)),
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