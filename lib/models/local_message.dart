enum LocalMessageType { text, audio, image, video }

enum LocalMessageRole { user, ai }

class LocalMessage {
  DateTime time;
  LocalMessageRole role;
  LocalMessageType type;
  String? text = '';

  LocalMessage({
    required this.time,
    required this.role,
    required this.type,
    this.text,
  });
}
