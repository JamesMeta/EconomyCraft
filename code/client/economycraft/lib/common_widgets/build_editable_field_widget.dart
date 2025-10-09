import 'package:flutter/material.dart';

class BuildEditableFieldWidget extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const BuildEditableFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  State<BuildEditableFieldWidget> createState() =>
      _BuildEditableFieldWidgetState();
}

class _BuildEditableFieldWidgetState extends State<BuildEditableFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: widget.onEdit,
          color: const Color.fromARGB(255, 74, 237, 217),
          tooltip: 'Edit $widget.label',
        ),
      ],
    );
  }
}
