import 'package:flutter/material.dart';
//import 'package:flutter_ai_chat/models/local_message.dart';

import 'package:flutter_ai_chat/constants.dart';

import 'package:flutter_ai_chat/screens/messages/widgets/messages_body.dart';

//import 'classes/local_message.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  static const routeName = '/messages';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String assistantId = args['assistantId'];
    //debugPrint(assistantId);
    return Scaffold(
      appBar: buildAppBar(),
      body: MessagesBody(assistantId: assistantId),
    );
  }

  /*// Shows a text message of [role] by adding to end of [_chatHistory] and scrolling down.
  ///
  ///
  void _getInteractionFeedback() {
    debugPrint('Im getting feedback');
  }*/

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(children: [
        BackButton(),
        CircleAvatar(
          backgroundImage: AssetImage("assets/images/55yo_back_pain.png"),
        ),
        SizedBox(width: kDefaultPadding * 0.75),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Patient with back pain",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Easy",
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        /*IconButton(
          icon: Icon(
            Icons.tips_and_updates,
            color: kPrimaryColor,
          ),
          onPressed: () => _getInteractionFeedback(),
        ),*/
      ]),
      actions: const [
        /*IconButton(
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {},
        ),
        const SizedBox(width: kDefaultPadding / 2),*/
      ],
    );
  }
}
