import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/classes/local_message.dart';

import 'services/open_ai_service.dart';
//import 'classes/local_message.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  //List<Map<String, dynamic>> _chatHistory = [];
  final OpenAiService openAiService = OpenAiService();
  List<LocalMessage> _chatHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Container(
            //get max height
            height: MediaQuery.of(context).size.height - 160,
            child: ListView.builder(
              itemCount: _chatHistory.length,
              shrinkWrap: false,
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    //alignment: (_chatHistory[index]["isSender"]
                    //    ? Alignment.topRight
                    //    : Alignment.topLeft),
                    alignment: (_chatHistory[index].role == "user"
                        ? Alignment.topRight
                        : Alignment.topLeft),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        /*color: (_chatHistory[index]["isSender"]
                            ? Color(0xFFF69170)
                            : Colors.white),*/
                        color: (_chatHistory[index].role == "user"
                            ? Color(0xFFF69170)
                            : Colors.white),
                      ),
                      padding: EdgeInsets.all(16),
                      /*child: Text(_chatHistory[index]["message"],
                          style: TextStyle(
                              fontSize: 15,
                              color: _chatHistory[index]["isSender"]
                                  ? Colors.white
                                  : Colors.black)),*/
                      child: Text(_chatHistory[index].content,
                          style: TextStyle(
                              fontSize: 15,
                              color: _chatHistory[index].role == "user"
                                  ? Colors.white
                                  : Colors.black)),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                        ),
                        color: Color(0xFFF69170),
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Type a message",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          controller: _chatController,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      if (_chatController.text.isNotEmpty) {
                        String tempChatHistoryContent = _chatController.text;
                        setState(() {
                          /*_chatHistory.add({
                              "time": DateTime.now(),
                              "message": _chatController.text,
                              "isSender": true,
                            });*/
                          String tempChatHistoryContent = _chatController.text;
                          _chatHistory.add(LocalMessage(
                              time: DateTime.now(),
                              role: "user",
                              content: _chatController.text));
                          _chatController.clear();
                        });

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastOutSlowIn,
                          );
                        });

                        /*_scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );*/

                        openAiService
                            .getAssistantResponseFromMessage(
                                tempChatHistoryContent)
                            .then((aiResponses) {
                          debugPrint("checking I'm here");
                          debugPrint(aiResponses.toString());
                          for (var aiResponse in aiResponses) {
                            debugPrint(aiResponse.content);
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
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: const EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF69170),
                              Color(0xFF7D96E6),
                            ]),
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                      child: Container(
                          constraints: const BoxConstraints(
                              minWidth: 88.0,
                              minHeight:
                                  36.0), // min sizes for Material buttons
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
