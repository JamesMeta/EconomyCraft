import 'package:flutter/material.dart';

class BuildEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const BuildEmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[350], size: 36),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
