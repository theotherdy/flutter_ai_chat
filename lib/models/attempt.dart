import 'package:hive/hive.dart';

import 'package:flutter_ai_chat/models/local_message.dart'; // Your LocalMessage class

part 'attempt.g.dart'; // The adapter will be generated here by the build_runner using the @HiveType and @HiveField annotations.
                        //cmd is: flutter pub run build_runner build
@HiveType(typeId: 3)
class Attempt {
  @HiveField(0)
  final String attemptId; // Unique ID for this attempt
  
  @HiveField(1)
  final DateTime date; // Date when the attempt started
  
  @HiveField(2)
  final List<LocalMessage> messages; // List of messages in this attempt

  Attempt({
    required this.attemptId,
    required this.date,
    required this.messages,
  });
}