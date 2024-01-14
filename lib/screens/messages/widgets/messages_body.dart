import 'package:flutter/material.dart';

import 'package:flutter_ai_chat/constants.dart';

import 'package:flutter_ai_chat/services/open_ai_service.dart';

import 'package:flutter_ai_chat/models/local_message.dart';

//import 'package:chat/models/ChatMessage.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/message.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/camera_modal.dart';

class MessagesBody extends StatefulWidget {
  final String assistantId;
  const MessagesBody({super.key, this.assistantId = ''});

  @override
  State<MessagesBody> createState() => _MessagesBodyState();
}

class _MessagesBodyState extends State<MessagesBody> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAiService openAiService = OpenAiService();

  String tempChatHistoryContent = '';
  final List<LocalMessage> _chatHistory = [];

  String _cameraFilePath = ''; // Store the file path received from CameraModal

  void _showCameraModal(BuildContext context) async {
    final filePath = showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Set to true for full-screen modal
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: CameraModal(onVideoRecorded: (path) {
            // Callback function when file is selected in CameraModal
            debugPrint('I have file path in MessagesBody $path');
            setState(() {
              _cameraFilePath = path;
            });
          })
        );
      },
    );
    // Handle the result (file path) returned from CameraModal
    if (filePath.toString() != "cancelled") {
      setState(() {
        _cameraFilePath = filePath.toString();
        debugPrint(_cameraFilePath);
      });
    }
  }

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
                IconButton(
                  icon: Icon(
                    Icons.videocam,
                    color: kPrimaryColor,
                  ),
                  // the method which is called
                  // when button is pressed
                  onPressed: () {
                    _showCameraModal(context);
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
                            setState(() {
                              tempChatHistoryContent = _chatController.text;
                              debugPrint(tempChatHistoryContent);
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

                            setState(() {
                              _chatHistory.add(LocalMessage(
                                  time: DateTime.now(),
                                  type: LocalMessageType.loading,
                                  role: LocalMessageRole.ai,
                                  text: "..."));
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
                                    tempChatHistoryContent, widget.assistantId)
                                .then((aiResponses) {
                              //debugPrint("checking I'm here");
                              //debugPrint(aiResponses.toString());
                              for (var aiResponse in aiResponses) {
                                debugPrint(aiResponse.text);
                                _chatHistory.removeLast(); //our loading message
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
