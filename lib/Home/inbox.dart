
import 'package:flutter/material.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 12),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF252525),
              child: Icon(
                Icons.layers_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: const Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.blue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome to your workspace',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(left: 16, top: 5),
              child: Text(
                'Welcome to the workspace · now',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
