import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyOrderFooter extends StatelessWidget {
  final void Function(void Function()) setParentState;

  const CompanyOrderFooter({super.key, required this.setParentState});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color.fromARGB(255, 229, 255, 252), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Order data last updated at: ${DateFormat('MMM d, yyyy - h:mm a').format(DateTime.now())}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          TextButton.icon(
            onPressed: () {
              setParentState(() {});
            },
            icon: const Icon(
              Icons.refresh,
              size: 18,
              color: Color.fromARGB(255, 74, 237, 217),
            ),
            label: const Text(
              'Refresh',
              style: TextStyle(color: Color.fromARGB(255, 74, 237, 217)),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
