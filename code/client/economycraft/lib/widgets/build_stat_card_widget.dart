import 'package:flutter/material.dart';

class BuildStatCardWidget extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const BuildStatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<BuildStatCardWidget> createState() => _BuildStatCardWidgetState();
}

class _BuildStatCardWidgetState extends State<BuildStatCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(255, 201, 201, 201),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 244, 244, 244),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.color,
                  ),
                ),
                Icon(widget.icon, size: 18, color: widget.color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
