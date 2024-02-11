import 'package:flutter/material.dart';

import 'package:flutter_ai_chat/constants.dart';

class InputBar extends StatefulWidget {
  final Function(String) onBtnSendPressed;
  final Function() onBtnVideoPressed;

  const InputBar({super.key, required this.onBtnSendPressed, required this.onBtnVideoPressed});

  @override
  State<InputBar> createState() => _InputBarState();

 
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.videocam,
            color: kPrimaryColor,
          ),
          // the method which is called
          // when button is pressed
          onPressed: () {
            widget.onBtnVideoPressed();
            //_showCameraModal(context);
          }
        ),
        //const Icon(Icons.videocam, color: kPrimaryColor),
        const SizedBox(width: kDefaultPadding),
        /*const Icon(Icons.mic, color: kPrimaryColor),
        const SizedBox(width: kDefaultPadding),*/
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 0.75,
            ),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                const SizedBox(width: kDefaultPadding / 4),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Type message",
                      border: InputBorder.none,
                    ),
                    controller: _chatController,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.64),
                  ),
                  // the method which is called
                  // when button is pressed
                  onPressed: () {
                    widget.onBtnSendPressed(_chatController.text);
                    //tempChatHistoryContent = _chatController.text; //hold on to this even afetr we've cleared input
                    //_showTextMessage(LocalMessageRole.user, tempChatHistoryContent);
                    _chatController.clear();

                    //_sendTextMessageAndShowTextResponse(tempChatHistoryContent);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
