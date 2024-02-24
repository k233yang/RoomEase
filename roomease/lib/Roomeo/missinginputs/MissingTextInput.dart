import 'package:flutter/material.dart';

class MissingTextInput extends StatefulWidget {
  const MissingTextInput({
    super.key,
    this.isInputSingleLine = true,
    this.isMessageInput = false,
    required this.onTextInput,
  });

  final Function(String) onTextInput;
  final bool isInputSingleLine;
  final bool isMessageInput;

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

  String determinePlaceholder() {
    if (widget.isMessageInput) {
      return 'Message';
    }
    if (widget.isInputSingleLine) {
      return 'Task Title';
    }
    return 'Task Details/Desctiption';
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: determinePlaceholder(),
      ),
      controller: _controller,
      maxLines: widget.isInputSingleLine ? 1 : null,
      keyboardType: widget.isInputSingleLine
          ? TextInputType.text
          : TextInputType.multiline,
    );
  }
}
