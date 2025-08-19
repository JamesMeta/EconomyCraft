import 'package:flutter/material.dart';

class BuildEditDialogWidget extends StatefulWidget {
  final String title;
  final Function(String) onSave;
  final String initialValue;

  const BuildEditDialogWidget({
    super.key,
    required this.title,
    required this.onSave,
    required this.initialValue,
  });

  @override
  State<BuildEditDialogWidget> createState() => _BuildEditDialogWidgetState();
}

class _BuildEditDialogWidgetState extends State<BuildEditDialogWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(controller.text);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 74, 237, 217),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
