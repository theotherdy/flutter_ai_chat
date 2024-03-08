import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/constants.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/messages_body.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/information_modal.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({super.key});
  static const routeName = '/messages';
  bool _isFirstLoad = true; // Introduce the variable

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String assistantId = args['assistantId'];
    String advisorId = args['advisorId'];
    String instructions = args['instructions'];
    String avatar = args['avatar'];
    String title = args['title'];

    // Show the dialog on initial load
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructionsDialog(context, instructions);
        _isFirstLoad = false; // Make sure it only shows once
      });
    }

    return Scaffold(
      appBar: buildAppBar(title, avatar, context, instructions),
      body: MessagesBody(assistantId: assistantId, advisorId: advisorId),
    );
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
        return InformationModal(information: instructions);
      },
    );

    /*showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          // Add scrollable behavior
          child: Scrollbar(
            // Include the scrollbar
            child: SingleChildScrollView(
              child: Text(instructions),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );*/
  }
}
