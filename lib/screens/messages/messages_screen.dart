import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/constants.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/messages_body.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/information_modal.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({super.key});
  static const routeName = '/messages';
  bool _isFirstLoad = true; // Introduce the variable
  //bool _attemptsIncremented = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String assistantId = args['assistantId'];
    String advisorId = args['advisorId'];
    String instructions = args['instructions'];
    String avatar = args['avatar'];
    String voice = args['voice'];
    String title = args['title'];
    int chat_index = args['chat_index'];
    Function(int) incrementAttempts = args['incrementAttempts'];
    int attempt_index = args['attempt_index'];

    // Show the dialog on initial load
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isFirstLoad = false; // Make sure it only shows once
        _showInstructionsDialog(context, instructions);
      });
    }

    return Scaffold(
        appBar: buildAppBar(title, avatar, context, instructions),
        body: MessagesBody(
          assistantId: assistantId,
          advisorId: advisorId,
          avatar: avatar,
          voice: voice,
          chat_index: chat_index, // Pass the index
          incrementAttempts: incrementAttempts, // Pass the callback function),
          attempt_index: attempt_index,
        ));
  }

  AppBar buildAppBar(
      String title, String avatar, BuildContext context, String instructions) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(children: [
        const BackButton(),
        CircleAvatar(backgroundImage: AssetImage(avatar)),
        const SizedBox(width: kDefaultPadding * 0.75),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16)),
          ]),
        ),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInstructionsDialog(context, instructions),
        ),
      ],
    );
  }

  void _showInstructionsDialog(BuildContext context, String instructions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InformationModal(
            information: instructions, title: 'Instructions');
      },
    );
  }
}
