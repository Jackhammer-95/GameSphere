import 'package:flutter/material.dart';

void showUniversalDeleteDialog({
  required BuildContext context,
  required String content,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (confirmContext) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
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
                    content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                IntrinsicHeight(
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

                      // Delete/Remove
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                          onTap: () {
                            onConfirm();
                            Navigator.pop(confirmContext);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 60,
                            child: const Text("Remove", style: TextStyle(color: Colors.redAccent, fontSize: 16.0, fontWeight: FontWeight.bold)),
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