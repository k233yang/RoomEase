import 'package:flutter/material.dart';

class CommandTextInput extends StatefulWidget {
  const CommandTextInput(
      {super.key,
      this.isInputSingleLine = true,
      required this.onTextInput,
      required this.placeHolder,
      this.message = ""});

  final Function(String) onTextInput;
  final bool isInputSingleLine;
  final String placeHolder;
  final String message;

  @override
  CommandTextInputState createState() => CommandTextInputState();
}

class CommandTextInputState extends State<CommandTextInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message);
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
    String textInput = _controller.text.isEmpty ? 'Missing' : _controller.text;
    widget.onTextInput(textInput);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.placeHolder,
      ),
      controller: _controller,
      maxLines: widget.isInputSingleLine ? 1 : null,
      keyboardType: widget.isInputSingleLine
          ? TextInputType.text
          : TextInputType.multiline,
    );
  }
}
