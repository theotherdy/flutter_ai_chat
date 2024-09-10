import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/constants.dart';

class InputBar extends StatefulWidget {
  final Function(String) onBtnSendPressed;
  final Function() onBtnVideoPressed;
  final Function() onBtnAudioPressed;

  const InputBar(
      {super.key,
      required this.onBtnSendPressed,
      required this.onBtnVideoPressed,
      required this.onBtnAudioPressed,});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0.0, right:0.0), // Reduce space to the left
          child: IconButton(
            icon: const Icon(
              Icons.mic_outlined,
              color: kPrimaryColor,
            ),
            onPressed: () {
              widget.onBtnAudioPressed();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0, right:0.0), // Reduce space to the left
          child: IconButton(
            icon: const Icon(
              Icons.videocam,
              color: kPrimaryColor,
            ),
            onPressed: () {
              widget.onBtnVideoPressed();
            },
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: kDefaultPadding * 0.8, right:0.0), // Reduce space to the left
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 4, // Set max lines to 4
                    minLines: 1, // Set min lines to 1
                    decoration: const InputDecoration(
                      hintText: "Type message",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 8.0), // Reduce space inside the text field
                    ),
                    controller: _chatController,
                    scrollController: _scrollController,
                    keyboardType: TextInputType.multiline, // Enable multiline input
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0.0), // Reduce space to the right
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.64),
                    ),
                    onPressed: () {
                      widget.onBtnSendPressed(_chatController.text);
                      _chatController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}