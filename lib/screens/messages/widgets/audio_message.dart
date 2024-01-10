import 'package:flutter/material.dart';

import 'package:flutter_ai_chat/constants.dart';

import 'package:flutter_ai_chat/models/local_message.dart';

class AudioMessage extends StatelessWidget {
  final LocalMessage? message;

  const AudioMessage({super.key, this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 0.75,
        vertical: kDefaultPadding / 2.5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: kPrimaryColor
            .withOpacity(message!.role == LocalMessageRole.user ? 1 : 0.1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_arrow,
            color: message!.role == LocalMessageRole.user
                ? Colors.white
                : kPrimaryColor,
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: message!.role == LocalMessageRole.user
                        ? Colors.white
                        : kPrimaryColor.withOpacity(0.4),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: message!.role == LocalMessageRole.user
                            ? Colors.white
                            : kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Text(
            "0.37",
            style: TextStyle(
                fontSize: 12,
                color: message!.role == LocalMessageRole.user
                    ? Colors.white
                    : null),
          ),
        ],
      ),
    );
  }
}
