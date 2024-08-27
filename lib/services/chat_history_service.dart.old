import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_ai_chat/models/local_message.dart';

class ChatHistoryService {
  // Key prefix for storing chat history
  static const _chatHistoryKeyPrefix = 'chist_';
  static const _chatIdPrefix = 'cid_';
  static const _attemptIdPrefix = 'aid_';

  // Save a message to a chat's history
  Future<void> saveMessage(int chatId, int attemptId, LocalMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatHistoryKeyPrefix + _chatIdPrefix + chatId.toString() + _attemptIdPrefix + attemptId.toString();

    // Retrieve existing history or initialize an empty list
    final existingData = prefs.getString(key);
    List<LocalMessage> chatHistory = existingData != null
        ? (jsonDecode(existingData) as List)
            .map((data) => LocalMessage.fromJson(data))
            .toList()
        : [];

    // Add new message and save
    chatHistory.add(message);
    final jsonData =
        jsonEncode(chatHistory.map((msg) => msg.toJson()).toList());
    await prefs.setString(key, jsonData);
  }

  // Load chat history
  Future<List<LocalMessage>?> loadHistory(int chatId, int attemptId, ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatHistoryKeyPrefix + _chatIdPrefix + chatId.toString() + _attemptIdPrefix + attemptId.toString();
    final jsonData = prefs.getString(key);

    if (jsonData != null) {
      return (jsonDecode(jsonData) as List)
          .map((data) => LocalMessage.fromJson(data))
          .toList();
    } else {
      return null;
    }
  }
}
