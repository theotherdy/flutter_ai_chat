import 'package:flutter/material.dart';
import 'package:flutter_ai_chat/models/chats_data.dart';

class ChatHistoryScreen extends StatelessWidget {
  ChatHistoryScreen({super.key});
  static const routeName = '/chat_history';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    ChatsData chatData = args['chatData'];
    int chatIndex = args['chat_index'];
    //int? attemptIndex = args['attempt_index'];
    //Function(int) incrementAttempts = args['incrementAttempts'];

    return Scaffold(
      appBar: AppBar(title: Text('Chat History - ${chatData.title}')),
      body: Stack(
        children: [
          chatData.pastAttempts.isEmpty
              ? const Center(child: Text('No past attempts found.'))
              : ListView.builder(
                  itemCount: chatData.pastAttempts.length,
                  itemBuilder: (context, index) {
                    final attempt = chatData.pastAttempts[index];
                    return ListTile(
                      title: Text('Attempt on ${attempt.date}'),
                      //subtitle: Text('Messages: ${attempt.numberOfMessages}'),
                      onTap: () {
                        // Handle loading and displaying messages for this attempt
                        Navigator.pushNamed(
                          context,
                          '/messages',
                          arguments: {
                            'assistantId': chatData.assistantId,
                            'advisorId': chatData.advisorId,
                            'instructions': chatData.instructions,
                            'avatar': chatData.avatar,
                            'voice': chatData.voice,
                            'title': chatData.title,
                            'chat_index':
                                chatIndex, // Pass the index as needed when calling back to incrementAttempts
                            'attempt_index': attempt.index,
                            'messages': attempt.messages,
                          },
                        );
                      },
                    );
                  },
                ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                    context,
                    '/messages',
                    arguments: {
                      'assistantId': chatData.assistantId,
                      'advisorId': chatData.advisorId,
                      'instructions': chatData.instructions,
                      'avatar': chatData.avatar,
                      'voice': chatData.voice,
                      'title': chatData.title,
                      'chat_index':
                          chatIndex, // Pass the index as needed when calling back to incrementAttempts
                      'attempt_index': null  //ie start a new one with new attempt index
                    },
                  );
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
