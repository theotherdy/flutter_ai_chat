import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import 'package:provider/provider.dart';
import 'package:flutter_ai_chat/models/chats_data.dart';

import 'package:flutter_ai_chat/screens/messages/messages_screen.dart'; // Import MessagesScreen
//import 'package:flutter_ai_chat/services/chat_history_service.dart.old';
import 'package:flutter_ai_chat/screens/chats/widgets/difficulty_indicator.dart';
import 'package:flutter_ai_chat/screens/chats/chat_history_screen.dart'; // Import ChatHistoryScreen

import 'package:flutter_ai_chat/models/attempt.dart'; 

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});
  static const routeName = '/chats';

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

enum SortOption {
  titleAscending,
  titleDescending,
  difficultyAscending,
  difficultyDescending,
  attemptsAscending,
  attemptsDescending,
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<ChatsData> chats = ChatsData.getChats();
  SortOption sortOption = SortOption.titleAscending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Registering the pop callback using the registerPopEntry
      ModalRoute.of(context)?.navigator?.registerPopEntry(
        PopEntry(onPop: _loadAttemptsForChats),
      );
    });
    //_loadAttemptsForChats(); // Load attempts for each chat
  }

  Future<void> _loadAttemptsForChats() async {
    // Access the Hive box using Provider
    final box = Provider.of<Box<Attempt>>(context, listen: false);

    debugPrint('Hello');

    for (var chat in chats) {

      debugPrint('Chat id: $chat.id');
      // Count attempts for this specific chatId
      int attemptCount = box.values
          .where((attempt) => attempt.chatId == chat.id)
          .length;

      debugPrint('Text: $attemptCount');

      setState(() {
        chat.attemptCount = attemptCount; // Update the attempts count in the UI
        chat.pastAttempts = box.values
            .where((attempt) => attempt.chatId == chat.id)
            .toList(); // Store past attempts if needed later
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadAttemptsForChats(); // This will call every time build is called
    chats.sort((a, b) {
      switch (sortOption) {
        case SortOption.titleAscending:
          return a.title.compareTo(b.title);
        case SortOption.titleDescending:
          return b.title.compareTo(a.title);
        case SortOption.difficultyAscending:
          return a.difficulty.compareTo(b.difficulty);
        case SortOption.difficultyDescending:
          return b.difficulty.compareTo(a.difficulty);
        case SortOption.attemptsAscending:
          return a.attemptCount.compareTo(b.attemptCount);
        case SortOption.attemptsDescending:
          return b.attemptCount.compareTo(a.attemptCount);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Chats'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<SortOption>(
                  value: sortOption,
                  items: const [
                    DropdownMenuItem<SortOption>(
                      value: SortOption.titleAscending,
                      child: Text('Sort by Title (Ascending)'),
                    ),
                    DropdownMenuItem<SortOption>(
                      value: SortOption.titleDescending,
                      child: Text('Sort by Title (Descending)'),
                    ),
                    DropdownMenuItem<SortOption>(
                      value: SortOption.difficultyAscending,
                      child: Text('Sort by Difficulty (Ascending)'),
                    ),
                    DropdownMenuItem<SortOption>(
                      value: SortOption.difficultyDescending,
                      child: Text('Sort by Difficulty (Descending)'),
                    ),
                    DropdownMenuItem<SortOption>(
                      value: SortOption.attemptsAscending,
                      child: Text('Sort by Attempts (Ascending)'),
                    ),
                    DropdownMenuItem<SortOption>(
                      value: SortOption.attemptsDescending,
                      child: Text('Sort by Attempts (Descending)'),
                    )
                  ],
                  onChanged: (SortOption? newValue) {
                    setState(() {
                      sortOption = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(chats[index].avatar),
                  ),
                  title: Text(chats[index].title),
                  subtitle:
                      DifficultyIndicator(difficulty: chats[index].difficulty),
                  trailing: () {
                    //todo extract to a widget
                    if (chats[index].attemptCount == 1) {
                      return const Icon(Icons.check, color: Colors.green);
                    } else if (chats[index].attemptCount > 1) {
                      return Badge.count(
                        count: chats[index].attemptCount,
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.check, color: Colors.green),
                      );
                    } else {
                      return const Icon(Icons.check, color: Colors.grey);
                    }
                  }(),
                  onTap: () {
                    if (chats[index].pastAttempts.length > 0) {
                      //navigate intermediate ChatHistoryScreen
                      Navigator.pushNamed(context, '/chat_history', arguments: {
                        'chatData': chats[index],
                        'chat_index':
                            index, // Pass the index as needed when calling back to incrementAttempts
                        /*'incrementAttempts':
                            incrementAttempts, // Pass the callback function},*/
                      }

                          /*MaterialPageRoute(
                          builder: (context) =>
                              ChatHistoryScreen(chatData: chats[index]),
                        ),*/
                          );
                    } else {
                      //navigate straight to MessagesScreen
                      Navigator.pushNamed(
                        context,
                        '/messages',
                        arguments: {
                          'assistantId': chats[index].assistantId,
                          'advisorId': chats[index].advisorId,
                          'instructions': chats[index].instructions,
                          'avatar': chats[index].avatar,
                          'voice': chats[index].voice,
                          'title': chats[index].title,
                          'chat_index':
                              index, // Pass the index as needed when calling back to incrementAttempts
                          /*'incrementAttempts':
                              incrementAttempts, // Pass the callback function*/
                          'attempt_index': 0,
                          'systemMessage': chats[index].systemMessage,
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
