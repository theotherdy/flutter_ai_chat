import 'dart:convert'; // package to encode/decode JSON data type
import 'dart:async'; //for the Timer
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dot_env package
import 'package:http/http.dart' as http; // http package

import '../classes/assistant_message.dart';
import '../classes/local_message.dart';

var openAIApiKey = dotenv.env[
    'OPEN_AI_API_KEY']; //access the OPEN_AI_API_KEY from the .env file in the root directory

class OpenAiService {
  String _assistantId =
      "asst_oLP6zXce2HxRuR4dDPBDt3IM"; //set to existing asistant - will need to work out how to link with different scenarios on home page
  String _threadId = "";
  String _lastMessageId = "";

  /// Gets a response from the assistant for a message.
  ///
  /// Returns a <List<LocalMessage>> of messages recieved from the Assistant AI

  Future getAssistantResponseFromMessage(String message) async {
    // declaring a messages List to collate chat history
    final List<LocalMessage> messages = [];
    //if no assistant, create assistant - for now just use ID = asst_oLP6zXce2HxRuR4dDPBDt3IM

    //if no thread, create a thread
    if (_threadId == "") {
      _threadId = await _createThread();
    }

    //attach message(s) to thread as user
    var messageId;
    if (_threadId != "" && message != "") {
      messageId = await _addMesageToThread(message, _threadId);
    }

    //run assistant on the thread
    var runId;
    if (_assistantId != "" && _threadId != "") {
      runId = await _runAssistantOnThread(_assistantId, _threadId);
    }

    //poll thread every 500ms until completed then dispose
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      bool? runComplete = false;
      String statusText = "";
      if (runId != null) {
        (runComplete, statusText) =
            await _isRunOnThreadComplete(runId, _threadId);
      }
      if (runComplete == true) {
        timer.cancel();
        //Now that we know the run has completed, return the new messages
        List<dynamic>? returnedMessages;
        if (_threadId != "") {
          if (_lastMessageId != "") {
            (returnedMessages, statusText) =
                await _getMessagesFromThread(_threadId, _lastMessageId);
          } else {
            (returnedMessages, statusText) =
                await _getMessagesFromThread(_threadId);
          }
        }
        //now pull messages out into the messages List
        if (returnedMessages != null) {
          for (var returnedMessage in returnedMessages) {
            final assistantMessage = AssistantMessage.fromJson(returnedMessage);
            debugPrint(assistantMessage.toString());
            if (assistantMessage.role != "user") {
              //discard role:user messages
              messages.add(//{
                  LocalMessage(
                      time: DateTime.now(),
                      role: assistantMessage.role,
                      content: assistantMessage.content[0].text.value));
            }
            _lastMessageId = assistantMessage
                .id; //update the _lastMessageId with the last loaded message so that _getMessagesFromThread can be told to only return messages after that
          }
        }
        debugPrint(messages.toString());
      }
    });
    return messages;
  }

  /// Creates a thread.
  ///
  /// Returns a [threadId] or an error message

  Future<String> _createThread() async {
    // post the prompt to the API and receive response
    try {
      final res = await http.post(
        Uri.parse("https://api.openai.com/v1/threads"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIApiKey",
          "OpenAI-Beta": "assistants=v1",
        },
      );

      if (res.statusCode == 200) {
        // decode the JSON response
        Map<String, dynamic> response = jsonDecode(res.body);
        String threadId = response['id'];
        //debugPrint(threadId);
        return threadId;
      } else {
        var statusCode = res.statusCode.toString();
        return "OOPS! An Error occured in thread creation. Status code: $statusCode";
      }
    } catch (error) {
      return error.toString();
    }
  }

  /// Adds a [message] to a thread with [threadId].
  ///
  /// Returns a [messageId] or an error message

  Future<String> _addMesageToThread(message, threadId) async {
    try {
      final res = await http.post(
        Uri.parse("https://api.openai.com/v1/threads/$threadId/messages"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIApiKey",
          "OpenAI-Beta": "assistants=v1",
        },
        // encode the object to JSON
        body: jsonEncode(
          {
            "role": "user",
            "content": message,
          },
        ),
      );

      if (res.statusCode == 200) {
        // decode the JSON response
        Map<String, dynamic> response = jsonDecode(res.body);
        String messageId = response['id'];
        return messageId;
      } else {
        var statusCode = res.statusCode.toString();
        return "OOPS! An Error occured in message adding. Status code: $statusCode";
      }
    } catch (error) {
      return error.toString();
    }
  }

  /// Runs an assistant with [assistantId] on a thread with [threadId].
  ///
  /// Returns a [runId] or an error message

  Future<String> _runAssistantOnThread(assistantId, threadId) async {
    try {
      final res = await http.post(
        Uri.parse("https://api.openai.com/v1/threads/$threadId/runs"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIApiKey",
          "OpenAI-Beta": "assistants=v1",
        },
        // encode the object to JSON
        body: jsonEncode(
          {
            "assistant_id": assistantId,
          },
        ),
      );

      if (res.statusCode == 200) {
        // decode the JSON response
        Map<String, dynamic> response = jsonDecode(res.body);
        String runId = response['id'];
        return runId;
      } else {
        var statusCode = res.statusCode.toString();
        return "OOPS! An Error occured in running the assistant $assistantId on the thread $threadId. Status code: $statusCode";
      }
    } catch (error) {
      return error.toString();
    }
  }

  /// Checks whether a run with [runId] on thread with [threadId] has status = complete.
  ///
  /// Returns a record of with (true or false, message)

  Future<(bool?, String)> _isRunOnThreadComplete(runId, threadId) async {
    try {
      final res = await http.get(
        Uri.parse("https://api.openai.com/v1/threads/$threadId/runs/$runId"),
        headers: {
          "Authorization": "Bearer $openAIApiKey",
          "OpenAI-Beta": "assistants=v1",
        },
      );

      if (res.statusCode == 200) {
        // decode the JSON response
        Map<String, dynamic> response = jsonDecode(res.body);
        if (response['status'] == "completed") {
          return (true, "No problems");
        } else {
          return (false, "No problems");
        }
      } else {
        var statusCode = res.statusCode.toString();
        return (
          null,
          "OOPS! An Error occured in checking the completion of $runId on the thread $threadId. Status code: $statusCode"
        );
      }
    } catch (error) {
      return (null, error.toString());
    }
  }

  /// Get messages from a completed assistant run from a thread with [threadId], with optionally, a [afterMessageId] to specify message after which to return messages .
  ///
  /// Returns a the messages

  Future<(List<dynamic>?, String)> _getMessagesFromThread(threadId,
      [afterMessageId]) async {
    try {
      String url = "https://api.openai.com/v1/threads/$threadId/messages";
      if (afterMessageId != null) {
        url =
            "$url?order=asc&after=$afterMessageId"; //add after paramter value if fromMessageId
      }
      final res = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIApiKey",
          "OpenAI-Beta": "assistants=v1",
        },
      );

      if (res.statusCode == 200) {
        // decode the JSON response
        Map<String, dynamic> response = jsonDecode(res.body);
        List<dynamic> messageList = response['data'];
        return (messageList, "No problems");
      } else {
        var statusCode = res.statusCode.toString();
        return (
          null,
          "OOPS! An Error occured in getting messages from the thread $threadId. Status code: $statusCode"
        );
      }
    } catch (error) {
      return (null, error.toString());
    }
  }
}
