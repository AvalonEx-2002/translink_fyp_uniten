import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const UserTile({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black,
                width: 1.5,
              ),
            ),
            margin: const EdgeInsets.fromLTRB(25, 5, 25, 5),
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // Icon
                const Icon(Icons.chat),

                const SizedBox(
                  width: 15,
                ),

                // Username
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
