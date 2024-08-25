import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

//import 'home_page.dart';
import 'theme.dart';

import 'package:flutter_ai_chat/screens/chats/chats_screen.dart';
import 'package:flutter_ai_chat/screens/messages/messages_screen.dart';

// Import the generated adapter files
import 'package:flutter_ai_chat/models/local_message.dart'; // Your LocalMessage class
import 'package:flutter_ai_chat/models/attempt.dart'; // Your Attempt class
import 'package:flutter_ai_chat/models/local_message_adapters.dart'; // Enum adapters

// the main function is made async. This enables us to use await keyword with dotenv inside.
Future<void> main() async {
  await dotenv.load(); // loads all the environment variables

  // Initialize Hive
  await Hive.initFlutter();

  // Register the adapters
  Hive.registerAdapter(LocalMessageTypeAdapter());
  Hive.registerAdapter(LocalMessageRoleAdapter());
  Hive.registerAdapter(LocalMessageAdapter());
  Hive.registerAdapter(AttemptAdapter());

  // Open a box (or whatever your first operation is)
  var box = await Hive.openBox('myBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comm Skills Chatbot',
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      themeMode: ThemeMode.light,
      initialRoute: ChatsScreen.routeName,
      routes: {
        ChatsScreen.routeName: (context) => const ChatsScreen(),
        MessagesScreen.routeName: (context) => MessagesScreen(),
      },
    );
  }
}
