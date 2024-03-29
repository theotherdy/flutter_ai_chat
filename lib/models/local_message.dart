enum LocalMessageType { text, audio, image, video, loading }

enum LocalMessageRole { user, ai }

class LocalMessage {
  DateTime time;
  LocalMessageRole role;
  LocalMessageType type;
  String? text = '';
  String? filePath = '';

  LocalMessage({
    required this.time,
    required this.role,
    required this.type,
    this.text,
    this.filePath,
  });
}
