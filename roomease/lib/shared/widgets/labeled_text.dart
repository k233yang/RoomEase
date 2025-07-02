import 'package:flutter/cupertino.dart';

class LabeledText extends StatelessWidget {
  final String label;
  final String value;
  const LabeledText(this.label, this.value, {Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}