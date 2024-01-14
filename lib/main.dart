import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//import 'home_page.dart';
import 'theme.dart';

import 'package:flutter_ai_chat/screens/chats/chats_screen.dart';
import 'package:flutter_ai_chat/screens/messages/messages_screen.dart';

// the main function is made async. This enables us to use await keyword with dotenv inside.
Future<void> main() async {
  await dotenv.load(); // loads all the environment variables
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patients Comms Skills Practicer',
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      themeMode: ThemeMode.light,
      initialRoute: ChatsScreen.routeName,
      routes: {
        ChatsScreen.routeName: (context) => const ChatsScreen(),
        MessagesScreen.routeName: (context) => const MessagesScreen(),
      },
    );
  }
}
