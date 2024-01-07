import 'package:flutter/material.dart';

import '../../../constants.dart';

import 'package:flutter_ai_chat/models/local_message.dart';

//import 'audio_message.dart';
import 'text_message.dart';
//import 'video_message.dart';

class Message extends StatelessWidget {
  const Message({
    Key? key,
    required this.message,
  }) : super(key: key);

  final LocalMessage message;

  @override
  Widget build(BuildContext context) {
    Widget messageContent(LocalMessage message) {
      switch (message.type) {
        case LocalMessageType.text:
          return TextMessage(message: message);
        /*case LocalMessageType.audio:
          return AudioMessage(message: message);
        case LocalMessageType.video:
          return const VideoMessage();*/
        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        mainAxisAlignment: message.role == "user"
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (message.role != LocalMessageRole.user) ...[
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage("assets/images/back_pain.png"),
            ),
            const SizedBox(width: kDefaultPadding / 2),
          ],
          messageContent(message),
          //if (message.role == "user") MessageStatusDot(status: message.messageStatus)*/
        ],
      ),
    );
  }
}

/*class MessageStatusDot extends StatelessWidget {
  final MessageStatus? status;

  const MessageStatusDot({Key? key, this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color dotColor(MessageStatus status) {
      switch (status) {
        case MessageStatus.not_sent:
          return kErrorColor;
        case MessageStatus.not_view:
          return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return kPrimaryColor;
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: kDefaultPadding / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.not_sent ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}*/
