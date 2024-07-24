import 'package:flutter/material.dart';

import 'package:flutter_ai_chat/models/chats_data.dart';

import 'package:flutter_ai_chat/screens/messages/messages_screen.dart'; // Import MessagesScreen
import 'package:flutter_ai_chat/services/chat_history_service.dart';
import 'package:flutter_ai_chat/screens/chats/widgets/difficulty_indicator.dart';
import 'package:flutter_ai_chat/screens/chats/chat_history_screen.dart'; // Import ChatHistoryScreen

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

  /// Increment the attempts property of chats[index]
  ///
  void incrementAttempts(int index) {
    setState(() {
      chats[index].attempts++;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          return a.attempts.compareTo(b.attempts);
        case SortOption.attemptsDescending:
          return b.attempts.compareTo(a.attempts);
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
                    if (chats[index].attempts == 1) {
                      return const Icon(Icons.check, color: Colors.green);
                    } else if (chats[index].attempts > 1) {
                      return Badge.count(
                        count: chats[index].attempts,
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
                        'incrementAttempts':
                            incrementAttempts, // Pass the callback function},
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
                          'incrementAttempts':
                              incrementAttempts, // Pass the callback function
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
