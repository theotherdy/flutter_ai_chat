import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TranscriptionText {
  final String text;

  TranscriptionText({required this.text});

  factory TranscriptionText.fromJson(Map<String, dynamic> json) {
    return TranscriptionText(text: json['text'] ?? '');
  }
}

class WhisperTranscription {
  final String apiKey;
  final String apiEndpoint;
  final String model;
  final String language;
  final String prompt;
  final String responseFormat;
  final double temperature;

  WhisperTranscription({
    required this.apiKey,
    required this.apiEndpoint,
    required this.model,
    this.language = 'en',
    this.prompt = '',
    this.responseFormat = 'json',
    this.temperature = 0,
  });

  Future<TranscriptionText?> transcribeVideo(String filePath) async {
    final Uri uri = Uri.parse('$apiEndpoint/v1/audio/transcriptions');
    final File file = File(filePath);

    try {
      final Map<String, String> requestFields = {
        'model': model,
        'language': language,
        'prompt': prompt,
        'response_format': responseFormat,
        'temperature': temperature.toString(),
      };

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields.addAll(requestFields)
        ..files.add(http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: 'audio.${file.path.split('.').last}',
        ));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TranscriptionText.fromJson(data);
      } else {
        print('Error: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }
}

// Example usage:
void main() async {
  final apiKey = 'YOUR_OPENAI_API_KEY';
  final apiEndpoint = 'https://api.openai.com';
  final model = 'whisper-1';

  final whisperTranscription = WhisperTranscription(
    apiKey: apiKey,
    apiEndpoint: apiEndpoint,
    model: model,
  );

  final filePath = '/path/to/your/video/file.mp4';
  final transcription = await whisperTranscription.transcribeVideo(filePath);

  if (transcription != null) {
    print('Transcription: ${transcription.text}');
  } else {
    print('Failed to transcribe video.');
  }
}
