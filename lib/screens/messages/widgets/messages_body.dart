import 'package:flutter/material.dart';

import 'package:flutter_ai_chat/constants.dart';

import 'package:flutter_ai_chat/services/open_ai_service.dart';

import 'package:flutter_ai_chat/models/local_message.dart';

//import 'package:chat/models/ChatMessage.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/message.dart';

class MessagesBody extends StatefulWidget {
  const MessagesBody({Key? key}) : super(key: key);

  @override
  State<MessagesBody> createState() => _MessagesBodyState();
}

class _MessagesBodyState extends State<MessagesBody> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAiService openAiService = OpenAiService();

  String tempChatHistoryContent = '';
  List<LocalMessage> _chatHistory = [];

  @override
  Widget build(BuildContext context) {
    //return Column(
    //  children: [
    //    Expanded(
    //      child: Padding(

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          //get max height
          height: MediaQuery.of(context).size.height - 160,
          child: ListView.builder(
            itemCount: _chatHistory.length,
            shrinkWrap: false,
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) =>
                Message(message: _chatHistory[index]),
          ),
          //),
        ),
        //todo - move this out into a separate chat_input widget
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 32,
                color: const Color(0xFF087949).withOpacity(0.08),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                const Icon(Icons.mic, color: kPrimaryColor),
                const SizedBox(width: kDefaultPadding),
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
                            decoration: InputDecoration(
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
                            setState(() {
                              tempChatHistoryContent = _chatController.text;
                              _chatHistory.add(LocalMessage(
                                  time: DateTime.now(),
                                  type: LocalMessageType.text,
                                  role: LocalMessageRole.user,
                                  text: _chatController.text));
                              _chatController.clear();
                            });

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(seconds: 1),
                                curve: Curves.fastOutSlowIn,
                              );
                            });

                            openAiService
                                .getAssistantResponseFromMessage(
                                    tempChatHistoryContent)
                                .then((aiResponses) {
                              debugPrint("checking I'm here");
                              debugPrint(aiResponses.toString());
                              for (var aiResponse in aiResponses) {
                                debugPrint(aiResponse.text);
                                setState(() {
                                  _chatHistory.add(aiResponse);
                                });
                              }
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastOutSlowIn,
                                );
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
