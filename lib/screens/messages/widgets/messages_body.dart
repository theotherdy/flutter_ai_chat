import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_ai_chat/constants.dart';

import 'package:flutter_ai_chat/services/open_ai_service.dart';
import 'package:flutter_ai_chat/services/whisper_transcription_service.dart';

import 'package:flutter_ai_chat/models/local_message.dart';

//import 'package:chat/models/ChatMessage.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/message.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/camera_modal.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/input_bar.dart';

class MessagesBody extends StatefulWidget {
  final String assistantId;
  const MessagesBody({super.key, this.assistantId = ''});

  @override
  State<MessagesBody> createState() => _MessagesBodyState();
}

class _MessagesBodyState extends State<MessagesBody> {
  //final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAiService openAiService = OpenAiService();
  final WhisperTranscriptionService whisperTranscriptionService =
      WhisperTranscriptionService();

  String tempChatHistoryContent = '';
  final List<LocalMessage> _chatHistory = [];

  //String _cameraFilePath = ''; // Store the file path received from CameraModal

  /// Shows a loading message of [role] by adding to end of [_chatHistory] and scrolling down.
  ///
  ///
  void _showLoadingMessage(LocalMessageRole role) {
    setState(() {
      _chatHistory.add(LocalMessage(
          time: DateTime.now(),
          type: LocalMessageType.loading,
          role: role,
          text: "..."));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  /// Shows a text message of [role] by adding to end of [_chatHistory] and scrolling down.
  ///
  ///
  void _showTextMessage(LocalMessageRole role, String text) {
    setState(() {
      _chatHistory.add(LocalMessage(
          time: DateTime.now(),
          type: LocalMessageType.text,
          role: role,
          text: text));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  void _showCameraModal(BuildContext context) async {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Set to true for full-screen modal
      builder: (BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(16.0),
            child: CameraModal(onVideoRecorded: (filePath) async {
              // Callback function when file is selected in CameraModal
              //debugPrint('I have file path in MessagesBody $filePath');
              setState(() {
                //add video message to list of messages
                _chatHistory.add(LocalMessage(
                    time: DateTime.now(),
                    type: LocalMessageType.video,
                    role: LocalMessageRole.user,
                    filePath: filePath));
                //_cameraFilePath = path;
              });

              //now show a loading message whiole awaiting transcript
              _showLoadingMessage(LocalMessageRole.user);

              //final filePath = '/path/to/your/video/file.mp4';
              final transcription =
                  await whisperTranscriptionService.transcribeVideo(filePath);

              _chatHistory.removeLast(); //our loading message

              if (transcription != null) {
                // debugPrint('Transcription: ${transcription.text}');
                _showTextMessage(LocalMessageRole.user,
                    transcription.text); //show user what video transcript says
                _sendTextMessageAndShowTextResponse(
                    transcription.text); //send off to chat api to respond to
              } else {
                //debugPrint('Failed to transcribe video.');
              }
            }));
      },
    );
  }

  void _showAdvisorModal(BuildContext context, String advisorResponse) async {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Set to true for full-screen modal
      builder: (BuildContext context) {
        return Text(advisorResponse);
      }
    );
  }

  void _sendTextMessageAndShowTextResponse(String text) {
    _showLoadingMessage(LocalMessageRole.ai);

    openAiService
        .getAssistantResponseFromMessage(text, widget.assistantId)
        .then((aiResponses) {
      _chatHistory.removeLast(); //remove our loading message
      for (var aiResponse in aiResponses) {
        _showTextMessage(LocalMessageRole.ai, aiResponse.text);
      }
    });
  }

  void _sendConversationAndShowAdvisorFeedback() {
    //_showLoadingMessage(LocalMessageRole.ai);

    //todo add spinner

    //get conversation - text only - from _chatHistory
    String textToSend = '';
    for (var localMessage in _chatHistory) {
      if(localMessage.type == LocalMessageType.text) {
        if(localMessage.role == LocalMessageRole.user) {
          textToSend += 'Doctor (' + DateFormat('kk:mm:ss').format(localMessage.time) + '):';
        } else {
          textToSend += 'Patient (' + DateFormat('kk:mm:ss').format(localMessage.time) + '):';
        }
        textToSend += localMessage.text!;
      }
    }

    //debugPrint(textToSend);

    String _advisorId =
      "asst_YEv4v9UdwtTd4NoJzh3iwHw7"; //assistant set up to give feedback on the user's interaction with the ai patient

    openAiService
        .getAssistantResponseFromMessage(textToSend, _advisorId)
        .then((aiResponses) {
          String advisorResponse = '';
          for (var aiResponse in aiResponses) {
            advisorResponse += aiResponse.text;
          }
          debugPrint('Got response');
          _showAdvisorModal(context, advisorResponse);
      //_chatHistory.removeLast(); //remove our loading message
      /*for (var aiResponse in aiResponses) {
        _showTextMessage(LocalMessageRole.ai, aiResponse.text);
      }*/
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the available height dynamically
    //final availableHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        Expanded(
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: ListView.builder(
                itemCount: _chatHistory.length,
                shrinkWrap: true,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) =>
                    Message(message: _chatHistory[index]),
              ),
            ),
            Visibility(
              visible: _chatHistory.length > 0,
              child: Positioned(
                bottom: kDefaultPadding, // Adjust the bottom position as needed
                right: kDefaultPadding, // Adjust the right position as needed
                child: FloatingActionButton(
                  onPressed: () {
                    _sendConversationAndShowAdvisorFeedback();
                  },
                  child: Icon(
                    Icons.tips_and_updates,
                    //color: kPrimaryColor,
                  ),
                ),
              ),
            ),
          ]),
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
              child: InputBar(onBtnSendPressed: (textOfMessage) {
              // Callback function when message is sent in InputBar
              tempChatHistoryContent =
                  textOfMessage; //hold on to this even afetr we've cleared input
              _showTextMessage(LocalMessageRole.user, tempChatHistoryContent);
              _sendTextMessageAndShowTextResponse(tempChatHistoryContent);
            }, onBtnVideoPressed: () {
              // Callback function when video button pressed is selected in InputBar
              _showCameraModal(context);
            })
          ),
        )
      ],
    );
  }
}
