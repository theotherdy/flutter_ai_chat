import 'dart:convert'; // package to encode/decode JSON data type
import 'dart:async'; //for the Timer
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dot_env package
import 'package:http/http.dart' as http; // http package

import 'assistant_message.dart';

var openAIApiKey = dotenv.env[
    'OPEN_AI_API_KEY']; //access the OPEN_AI_API_KEY from the .env file in the root directory

class OpenAiService {
  String _assistantId = "asst_oLP6zXce2HxRuR4dDPBDt3IM";
  String _threadId = "";
  String _lastMessageId = "";

  // declaring a messages List to maintain chat history
  final List<Map<String, String>> messages = [
    {
      "role": "user",
      "content": "Ensure all responses within 200 words",
    },
  ];

  /// Gets a response from the assistant for a message.
  ///
  /// Returns a [?] or an error message

  Future getAssistantResponseFromMessage(String message) async {
    //if no assistant, create assistant - for now just use ID = asst_oLP6zXce2HxRuR4dDPBDt3IM

    //if no thread, create a thread
    if (_threadId == "") {
      _threadId = await _createThread();
    }
    //debugPrint(_threadId);

    //attach message(s) to thread as user
    var messageId;
    if (_threadId != "" && message != "") {
      messageId = await _addMesageToThread(message, _threadId);
    }
    //debugPrint(messageId);

    //run assistant on the thread
    var runId;
    if (_assistantId != "" && _threadId != "") {
      runId = await _runAssistantOnThread(_assistantId, _threadId);
    }
    //debugPrint(runId);

    //poll thread every 500ms until completed then dispose
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      bool? runComplete = false;
      String statusText = "";
      if (runId != null) {
        (runComplete, statusText) =
            await _isRunOnThreadComplete(runId, _threadId);
      }
      //debugPrint(runComplete.toString());
      //debugPrint(statusText);
      if (runComplete == true) {
        timer.cancel();
        //Now that we know the run has completed, return the new messages
        List<dynamic>? returnedMessages;
        //String statusText = "";
        if (_threadId != "") {
          //debugPrint("About to read messages");
          if (_lastMessageId != "") {
            (returnedMessages, statusText) =
                await _getMessagesFromThread(_threadId, _lastMessageId);
          } else {
            (returnedMessages, statusText) =
                await _getMessagesFromThread(_threadId);
          }
        }
        //debugPrint(returnedMessages.toString());
        //debugPrint(statusText);
        //now pull messages out into the messages Map, and update the last loaded message so we don't have to work out where we had got to...
        if (returnedMessages != null) {
          for (var returnedMessage in returnedMessages) {
            final assistantMessage = AssistantMessage.fromJson(returnedMessage);
            //debugPrint(returnedMessage.toString());
            debugPrint(assistantMessage.toString());
            messages.add({
              'role': assistantMessage.role,
              'content': assistantMessage.content[0].text.value,
            });
            _lastMessageId = assistantMessage.id;
          }
        }
        debugPrint(messages.toString());
      }
    });
    return _threadId;
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
