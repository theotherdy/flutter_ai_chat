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

    //debugPrint('Text: $tempPath');

    String text = utf8.decode(message!.text!.runes.toList(), allowMalformed: true);

    // Extracting all non-verbal information wrapped in square brackets
    final RegExp regex = RegExp(r'\[([^\]]+)\]');
    final List<String> nonVerbalInfos = [];

    text = text.replaceAllMapped(regex, (match) {
      nonVerbalInfos.add(capitalizeFirstLetter(match.group(1)!));
      return '';
    });

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
          // Conditionally render non-verbal info Text widgets
          for (String nonVerbalInfo in nonVerbalInfos)
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
