import 'package:flutter/material.dart';

class MissingTextInput extends StatefulWidget {
  const MissingTextInput({
    super.key,
    this.isInputSingleLine = true,
    required this.onTextInput,
  });

  final Function(String) onTextInput;
  final bool isInputSingleLine;

  @override
  MissingTextInputState createState() => MissingTextInputState();
}

class MissingTextInputState extends State<MissingTextInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listener to the controller
    _controller.addListener(_handleTextInputChange);
  }

  @override
  void dispose() {
    // Remove listener and dispose the controller when the widget is disposed
    _controller.removeListener(_handleTextInputChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleTextInputChange() {
    // This function is called every time the text changes
    widget.onTextInput(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.isInputSingleLine
            ? 'Task Title'
            : 'Task Details/Description',
      ),
      controller: _controller,
      maxLines: widget.isInputSingleLine ? 1 : null,
      keyboardType: widget.isInputSingleLine
          ? TextInputType.text
          : TextInputType.multiline,
    );
  }
}
