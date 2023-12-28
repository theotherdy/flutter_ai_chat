import 'dart:convert'; // package to encode/decode JSON data type
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dot_env package
import 'package:http/http.dart' as http; // http package

var openAIApiKey = dotenv.env[
    'OPEN_AI_API_KEY']; //access the OPEN_AI_API_KEY from the .env file in the root directory

class OpenAiService {
  var assistant;
  var thread;

  // declaring a messages List to maintain chat history
  final List<Map<String, String>> messages = [
    {
      "role": "user",
      "content": "Ensure all responses within 200         words",
    },
  ];

  Future getAssistantResponseFromMessage(String message) async {
    //if no assistant, create assistant - for now just use ID = asst_oLP6zXce2HxRuR4dDPBDt3IM

    //if no thread, create a thread
    thread ??= createThread().then((value) => {
          // ignore: avoid_print
          //print(value)
          //return value
          //return value
        });

    //attach message(s) to thread as user

    //run assistnat on the thread

    //poll thread every 500ms until completed then dispose
    //Timer.periodic(Duration(seconds: 1), (_) => loadUser());

    return thread;
  }

  Future createThread() async {
    // post the prompt to the API and receive response
    //try {
    final res = await http.post(
      Uri.parse("https://api.openai.com/v1/threads"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $openAIApiKey",
        "OpenAI-Beta": "assistants=v1",
      },
      // encode the object to JSON
      body: jsonEncode(
        {},
      ),
    );

    if (res.statusCode == 200) {
      // decode the JSON response

      Map<String, dynamic> response = jsonDecode(res.body);
      String threadId = response['id'];
      debugPrint(threadId);
      //response = response.trim();
      // add the response to messages and return response
      /*messages.add({
          "role": "assistant",
          "content": response,
        });*/
      return threadId;
    } else {
      return "OOPS! An Error occured. \n Please try again after sometime";
    }
    //} catch (error) {
    //  print(error.toString());
    //  return error.toString();
    //}
  }

  // this async function with return a future which will resolve to a string
  Future<String> chatGPTApi(String prompt) async {
    // add the prompt to messages
    messages.add({
      "role": "user",
      "content": prompt,
    });

    // post the prompt to the API and receive response
    try {
      final res = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openAIApiKey"
        },
        // encode the object to JSON
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": messages,
          },
        ),
      );

      if (res.statusCode == 200) {
        // decode the JSON response
        String response =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        response = response.trim();
        // add the response to messages and return response
        messages.add({
          "role": "assistant",
          "content": response,
        });
        return response;
      } else {
        return "OOPS! An Error occured. \n Please try again after sometime";
      }
    } catch (error) {
      return error.toString();
    }
  }
}
