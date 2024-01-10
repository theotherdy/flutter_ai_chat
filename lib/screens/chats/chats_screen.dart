import 'package:flutter/material.dart';

import 'package:flutter_ai_chat/models/chats_data.dart';

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
        title: Text('Patient Chats'),
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
                  items: [
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
                  subtitle: Row(
                    children: [
                      Text(chats[index].subTitle),
                      SizedBox(width: 10),
                      if (chats[index].attempts > 0)
                        Text('(${chats[index].attempts} attempts)'),
                    ],
                  ),
                  trailing: Icon(
                    chats[index].attempts > 0
                        ? Icons.check
                        : Icons.check_box_outline_blank,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/messages',
                      arguments: {'assistantId': chats[index].assistantId},
                    );
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
