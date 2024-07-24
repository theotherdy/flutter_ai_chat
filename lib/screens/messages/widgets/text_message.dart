import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/constants.dart';
import 'package:flutter_ai_chat/models/local_message.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    this.message,
  }) : super(key: key);

  final LocalMessage? message;

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // Convert text to a UTF-8 string
    String text = utf8.decode(message!.text!.runes.toList());

    // Extracting non-verbal information wrapped in square brackets
    int startIndex = text.indexOf('[');
    int endIndex = text.indexOf(']');
    String nonVerbalInfo = '';
    if (startIndex != -1 && endIndex != -1) {
      nonVerbalInfo = text.substring(startIndex + 1, endIndex);

      // Removing non-verbal information from the text
      text = text.replaceRange(startIndex, endIndex + 1, '');
    }

    // Building the widget with non-verbal information on a separate line and italicized
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 0.75,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: kPrimaryColor
            .withOpacity(message!.role == LocalMessageRole.user ? 1 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.trim(),
            style: TextStyle(
              color: message!.role == LocalMessageRole.user
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          if (nonVerbalInfo
              .isNotEmpty) // Conditionally render non-verbal info Text widget
            Text(
              capitalizeFirstLetter(nonVerbalInfo.trim()),
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: message!.role == LocalMessageRole.user
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
        ],
      ),
    );
  }
}
