import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data'; //Uint8List
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:just_audio/just_audio.dart';

//import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';

import 'package:flutter_ai_chat/constants.dart';

import 'package:flutter_ai_chat/services/open_ai_service.dart';
import 'package:flutter_ai_chat/services/whisper_transcription_service.dart';

import 'package:flutter_ai_chat/models/local_message.dart';

//import 'package:chat/models/ChatMessage.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/message.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/camera_modal.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/information_modal.dart';
import 'package:flutter_ai_chat/screens/messages/widgets/input_bar.dart';

class MessagesBody extends StatefulWidget {
  final String assistantId;
  final String advisorId;
  final String avatar;
  final String voice;
  final int chat_index; // Receive the index
  final Function(int) incrementAttempts; // Receive the callback function
  final int attempt_index;

  MessagesBody({
    super.key,
    required this.assistantId,
    required this.advisorId,
    required this.avatar,
    required this.voice,
    required this.chat_index, // Receive the index
    required this.incrementAttempts, // Receive the callback function
    required this.attempt_index,
  });

  @override
  State<MessagesBody> createState() => _MessagesBodyState();
}

class _MessagesBodyState extends State<MessagesBody> {
  //final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAiService openAiService =
      OpenAiService(); //todo NEW INSTANCE of service (ie new thread) every time we come to this page - may want to do this explictly to allow people to continue a conversation?
  final WhisperTranscriptionService whisperTranscriptionService =
      WhisperTranscriptionService();

  String tempChatHistoryContent = '';
  final List<LocalMessage> _chatHistory = [];
  String _lastAdvisorResponse = ''; //to hold last respnse from advisor
  bool _attemptsIncremented =
      false; //so that we only increment attempts once per load

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

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
    _lastAdvisorResponse = ''; //new message so can't reuse
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
            height: MediaQuery.of(context).size.height, // Full height
            padding: const EdgeInsets.all(0),
            child: CameraModal(onVideoRecorded: (filePath) async {
              // Callback function when file is selected in CameraModal
              //debugPrint('I have file path in MessagesBody $filePath');
              _lastAdvisorResponse = ''; //new message so can't reuse

              //now show a loading message whiole awaiting transcript
              //_showLoadingMessage(LocalMessageRole.user);

              // Audio Extraction with ffmpeg_kit_flutter and path_provider
              final tempDirectory =
                  await getTemporaryDirectory(); // Get temporary directory
              final audioOutputPath =
                  '${tempDirectory.path}/extracted_audio.mp3'; // Use a suitable extension
              await _extractAudio(filePath, audioOutputPath);

              //debugPrint(audioOutputPath);

              //final filePath = '/path/to/your/video/file.mp4';
              //final transcription =
              //await whisperTranscriptionService.transcribeVideo(filePath);
              final transcription = await whisperTranscriptionService
                  .transcribeVideo(audioOutputPath);

              //setState(() {
              //  _chatHistory.removeLast(); //our loading message
              //});

              String transcribedText = '';

              if (transcription != null &&
                  transcription.text != '' &&
                  transcription.text.toLowerCase() != 'you') {
                //for some reason, it seems to hallucinate 'you' if no sound!
                //_showTextMessage(LocalMessageRole.user,
                //    transcription.text); //show user what video transcript says
                transcribedText = transcription.text;
                setState(() {
                  //add video message to list of messages
                  _chatHistory.add(LocalMessage(
                      time: DateTime.now(),
                      type: LocalMessageType.video,
                      role: LocalMessageRole.user,
                      text: transcribedText,
                      filePath: filePath));
                  //_cameraFilePath = path;
                });
                _sendTextMessageAndShowTextResponse(
                    transcription.text); //send off to chat api to respond to
              } else {
                //show an eror dialogue
                _showWhisperErrorDialog();
              }
            }));
      },
    );
  }

  void _showWhisperErrorDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext newContext) {
        // Capture a new BuildContext
        return AlertDialog(
          title: Text("Sorry"),
          content: Text(
              "I'm afraid couldn't find any speech in that video, or something went wrong - please try again, or type your message instead"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(newContext).pop(); // Use the new BuildContext
              },
            ),
          ],
        );
      },
    );
  }

  // Helper function for audio extraction using FFmpegKit
  Future<void> _extractAudio(String inputPath, String outputPath) async {
    String command =
        '-y -i $inputPath -vn -acodec libmp3lame $outputPath'; //-y tells it to autooverwrite
    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS, audio extracted
        debugPrint('Audio extraction success');
      } else if (ReturnCode.isCancel(returnCode)) {
        // Operation was canceled
        debugPrint('Audio extraction canceled');
      } else {
        // ERROR
        debugPrint('Error extracting audio. Error Code: $returnCode');
      }

      // Access logs
      await session.getLogs().then((logs) {
        logs.forEach((log) => debugPrint(log.getMessage()));
      });
    });
  }

  void _showAdvisorSpinnerModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Prevent users from dismissing the dialog
      builder: (BuildContext context) {
        return Stack(
          children: [
            Container(
              color: Colors.black
                  .withOpacity(0.5), // Semi-transparent black background
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }

  void _hideAdvisorSpinnerModal(BuildContext context) {
    Navigator.pop(context); // Dismiss the bottom sheet to hide the spinner
  }

  void _showAdvisorModal(BuildContext context, String advisorResponse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InformationModal(
            information: advisorResponse, title: 'AI feedback');
      },
      barrierDismissible: true,
    );
  }

  // Updated function to handle sending a text message and showing the AI response using the Chat API
  void _sendTextMessageAndShowTextResponse(String text) {
    _showLoadingMessage(LocalMessageRole.ai);

    List<LocalMessage> updatedConversationHistory = List.from(_chatHistory);
    updatedConversationHistory.add(LocalMessage(
      time: DateTime.now(),
      role: LocalMessageRole.user,
      type: LocalMessageType.text,
      text: text,
    ));

    openAiService.getChatResponseFromMessage(updatedConversationHistory).then((aiResponses) async {
      setState(() {
        _chatHistory.removeLast(); // Remove the loading message
      });

      String textToSend = aiResponses.map((msg) => msg.text).join(" ");

      final audioFuture = openAiService.generateAudio(
        text: textToSend,
        voice: widget.voice,
      );

      try {
        final audioBytes = await audioFuture.timeout(const Duration(seconds: 3));
        if (audioBytes != null) {
          _playAudio(audioBytes);
        }
      } catch (e) {
        debugPrint('Audio generation timed out, showing text messages instead.');
      }

      setState(() {
        _chatHistory.addAll(aiResponses);
      });
    });
  }

  /*void _sendTextMessageAndShowTextResponse(String text) {
    _showLoadingMessage(LocalMessageRole.ai);
    openAiService
        .getAssistantResponseFromMessage(text, widget.assistantId)
        .then((aiResponses) async {
      _chatHistory.removeLast(); //remove our loading message
      //collate text from multiple messages to send to the speech_to_text
      String textToSend = '';
      for (var aiResponse in aiResponses) {
        //_showTextMessage(LocalMessageRole.ai, aiResponse.text);
        textToSend += aiResponse.text;
      }

      // Set a timeout duration of 5 seconds for generating audio
      final audioFuture = openAiService.generateAudio(
        text: textToSend,
        voice: widget.voice, // Specify the voice here
      );

      try {
        final audioBytes = await audioFuture.timeout(Duration(seconds: 3));
        if (audioBytes != null) {
          _playAudio(audioBytes);
        }
      } catch (e) {
        // Handle timeout exception
        debugPrint(
            'Audio generation timed out, showing text messages instead.');
      }
      for (var aiResponse in aiResponses) {
        _showTextMessage(LocalMessageRole.ai, aiResponse.text);
      }
    });
  }*/

  void _sendConversationAndShowAdvisorFeedback() {
    //check if we have a _lastAdvisorResponse - if so, then no new messages have been posted/received so just redisplay that
    if (_lastAdvisorResponse != '') {
      _showAdvisorModal(context, _lastAdvisorResponse);
    } else {
      _showAdvisorSpinnerModal(
          context); // Show spinner before making the API call
      //get conversation - text only - from _chatHistory
      String textToSend = '';
      for (var localMessage in _chatHistory) {
        if (localMessage.type == LocalMessageType.text) {
          if (localMessage.role == LocalMessageRole.user) {
            textToSend +=
                'Doctor (${DateFormat('kk:mm:ss').format(localMessage.time)}):';
          } else {
            textToSend +=
                'Patient (${DateFormat('kk:mm:ss').format(localMessage.time)}):';
          }
          textToSend += localMessage.text!;
        }
      }

      //debugPrint(textToSend);

      //String _advisorId =
      //    "asst_YEv4v9UdwtTd4NoJzh3iwHw7"; //assistant set up to give feedback on the user's interaction with the ai patient

      openAiService
          .getAssistantResponseFromMessage(textToSend, widget.advisorId)
          .then((aiResponses) {
        String advisorResponse = '';
        for (var aiResponse in aiResponses) {
          advisorResponse += aiResponse.text;
        }
        debugPrint('Got response');
        _hideAdvisorSpinnerModal(context); // Hide spinner when request ends
        _lastAdvisorResponse = advisorResponse;
        _showAdvisorModal(context, advisorResponse);
      });

      if (!_attemptsIncremented) {
        widget.incrementAttempts(widget
            .chat_index); // Call the callback function to increment attempts
        _attemptsIncremented = true;
      }
    }
  }

  /*void _playAudio(Uint8List audioBytes) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/temp.mp3';
    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(audioBytes); // Asynchronous write
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(tempPath)));
    _audioPlayer.play();
  }*/

  void _playAudio(Uint8List audioBytes) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/temp.mpg';  // Change to 'temp.aac'?
    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(audioBytes); // Asynchronous write
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(tempPath)));
    _audioPlayer.play();
    //debugPrint('Trying to play $tempPath');
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the available height dynamically

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
                itemBuilder: (context, index) => Message(
                    message: _chatHistory[index], avatar: widget.avatar),
              ),
            ),
            Visibility(
              visible: _chatHistory.isNotEmpty,
              child: Positioned(
                bottom: kDefaultPadding, // Adjust the bottom position as needed
                right: kDefaultPadding, // Adjust the right position as needed
                child: FloatingActionButton(
                  onPressed: () {
                    _sendConversationAndShowAdvisorFeedback();
                  },
                  child: const Icon(
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
            horizontal: kDefaultPadding * 0.2,
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
          })),
        )
      ],
    );
  }
}
