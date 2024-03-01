import 'package:flutter/material.dart';

class AdvisorModal extends StatelessWidget {
  const AdvisorModal({
    super.key,
    required this.advisorResponse,
  });

  final String advisorResponse;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(advisorResponse),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
