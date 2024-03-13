import 'package:flutter/material.dart';

class MissingPointInput extends StatefulWidget {
  const MissingPointInput({
    super.key,
    required this.onPointInput,
    required this.placeholder,
    this.points = "",
  });

  final Function(int) onPointInput;
  final String placeholder;
  final String points;

  @override
  MissingPointInputState createState() => MissingPointInputState();
}

class MissingPointInputState extends State<MissingPointInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.points);

  @override
  void initState() {
    super.initState();
    // Add listener to the controller
    _controller.addListener(_handlePointInputChange);
  }

  @override
  void dispose() {
    // Remove listener and dispose the controller when the widget is disposed
    _controller.removeListener(_handlePointInputChange);
    _controller.dispose();
    super.dispose();
  }

  void _handlePointInputChange() {
    // This function is called every time the text changes
    int pointInput =
        _controller.text.isEmpty ? 0 : int.tryParse(_controller.text) ?? 0;
    widget.onPointInput(pointInput);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.placeholder,
      ),
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(
          decimal: true), // Adjusted for numeric input
    );
  }
}
