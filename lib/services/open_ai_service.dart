import 'dart:convert'; // package to encode/decode JSON data type
import 'dart:async'; //for the Timer
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dot_env package
import 'package:http/http.dart' as http; // http package

import '../models/assistant_message.dart';
import '../models/local_message.dart';

var openAIApiKey = dotenv.env[
    'OPEN_AI_API_KEY']; //access the OPEN_AI_API_KEY from the .env file in the root directory
var openAIApiAssistantsEndpoint = dotenv.env[
    'ASSISTANTS_API_URL']; //access the OPEN_AI_API_KEY from the .env file in the root directory

class OpenAiService {
  String _assistantId =
      "asst_oLP6zXce2HxRuR4dDPBDt3IM"; //default value, as passed in with call 
  
  String _threadId = "";
  String _lastMessageId = "";
  String _runId = "";
  bool _runComplete = false;

  /// Gets a response from the assistant for a message.
  ///
  /// Returns a <List<LocalMessage>> of messages recieved from the Assistant AI

  Future getAssistantResponseFromMessage(String message, assistantId) async {
    // declaring a messages List to collate chat history
    List<LocalMessage> messages = [];
    _assistantId = assistantId;

    //debugPrint(message);
    //if no assistant, create assistant - for now just use ID = asst_oLP6zXce2HxRuR4dDPBDt3IM

    //if no thread, create a thread
    if (_threadId == "") {
      _threadId = await _createThread();
    }

    //attach message(s) to thread as user
    String messageId;
    if (_threadId != "" && message != "") {
      messageId = await _addMesageToThread(message, _threadId);
    }

    //run assistant on the thread
    if (_assistantId != "" && _threadId != "") {
      _runId = await _runAssistantOnThread(_assistantId, _threadId);
    }

    //is run complete
    if (_runId != "" && _threadId != "") {
      _runComplete = await _isRunComplete(_threadId, _runId);
    }

    //get messages from completed run
    if (_runComplete && _threadId != "") {
      messages = await _getCompletedResponse(_threadId);
    }

    return messages;
  }

  /// Creates a thread.
  ///
  /// Returns a [threadId] or an error message

  Future<String> _createThread() async {
    // post the prompt to the API and receive response
    try {
      final res = await http.post(
        Uri.parse("$openAIApiAssistantsEndpoint"),
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
    //debugPrint(message);
    try {
      final res = await http.post(
        Uri.parse("$openAIApiAssistantsEndpoint/$threadId/messages"),
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
        Uri.parse("$openAIApiAssistantsEndpoint/$threadId/runs"),
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
  /// Adapted from code written by ChatGPT

  Future<bool> _isRunComplete(String threadId, String runId) async {
    bool isComplete = false;
    int maxAttempts = 10; // Set the maximum number of attempts
    int attempt = 0;

    while (!isComplete && attempt < maxAttempts) {
      //debugPrint('$openAIApiAssistantsEndpoint/$threadId/runs/$runId');
      final response = await http.get(
        Uri.parse('$openAIApiAssistantsEndpoint/$threadId/runs/$runId'),
        headers: {
          'Authorization': 'Bearer $openAIApiKey',
          "OpenAI-Beta": "assistants=v1",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final runStatus = responseData['status'];

        if (runStatus == 'completed') {
          isComplete = true;
          //debugPrint('Run $runId on Thread $threadId is complete.');
        } else {
          //debugPrint('Run $runId on Thread $threadId is still processing...');
        }
      } else {
        //debugPrint('Error checking run status: ${response.statusCode}');
      }

      await Future.delayed(
          const Duration(seconds: 5)); // Wait for 5 seconds before next attempt
      attempt++;
    }

    return isComplete;
  }

  /// Get messages from a completed assistant run from a thread with [threadId], with optionally, a [afterMessageId] to specify message after which to return messages .
  ///
  /// Returns a list of the messages

  Future<(List<dynamic>?, String)> _getMessagesFromThread(threadId,
      [afterMessageId]) async {
    try {
      String url = "$openAIApiAssistantsEndpoint/$threadId/messages";
      if (afterMessageId != null) {
        debugPrint('afterMessageId coming through as $afterMessageId');
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

  /// Chcek for completion of run with [runId] from a thread with [threadId]
  ///
  /// Returns a <List<LocalMessage>> of the the messages

  Future<List<LocalMessage>> _getCompletedResponse(threadId) async {
    List<LocalMessage> messages = [];

    //Now that we know the run has completed, return the new messages
    List<dynamic>? returnedMessages = [];
    String statusText = "";
    if (_threadId != "") {
      //debugPrint("going in $_lastMessageId");
      if (_lastMessageId != "") {
        (returnedMessages, statusText) =
            await _getMessagesFromThread(_threadId, _lastMessageId);
            //debugPrint('Im using $_lastMessageId');
      } else {
        (returnedMessages, statusText) =
            await _getMessagesFromThread(_threadId);
            //debugPrint('Im not using a last message Id');
      }
    }
    //debugPrint(statusText);
    //now pull messages out into the messages List
    if (returnedMessages != null) {
      for (var returnedMessage in returnedMessages) {
        final assistantMessage = AssistantMessage.fromJson(returnedMessage);
        debugPrint('${assistantMessage.content[0].text.value} id: ${assistantMessage
            .id}');
        if (assistantMessage.role != "user") {
          //discard role:user messages
          messages.add(//{
              LocalMessage(
                  time: DateTime.now(),
                  role: LocalMessageRole.ai,
                  type: LocalMessageType.text,
                  text: assistantMessage.content[0].text.value));
        
          _lastMessageId = assistantMessage
            .id; //update the _lastMessageId with the last loaded message so that _getMessagesFromThread can be told to only return messages after that
        }
        
        //debugPrint("coming out $_lastMessageId");
      }
    }
    //debugPrint(messages.toString());
    return messages;
  }
}
