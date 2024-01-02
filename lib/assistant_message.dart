//Written by ChatGPT!
class MessageText {
  String value;
  List<dynamic> annotations;

  MessageText({
    required this.value,
    required this.annotations,
  });

  factory MessageText.fromJson(Map<String, dynamic> json) {
    return MessageText(
      value: json['value'],
      annotations: List<dynamic>.from(json['annotations']),
    );
  }
}

class MessageContent {
  String type;
  MessageText text;

  MessageContent({
    required this.type,
    required this.text,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      type: json['type'],
      text: MessageText.fromJson(json['text']),
    );
  }
}

class AssistantMessage {
  String id;
  String object;
  int createdAt;
  String threadId;
  String role;
  List<MessageContent> content;
  List<String> fileIds;
  String? assistantId;
  String? runId;
  Map<String, dynamic> metadata;

  AssistantMessage({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.threadId,
    required this.role,
    required this.content,
    required this.fileIds,
    this.assistantId,
    this.runId,
    required this.metadata,
  });

  factory AssistantMessage.fromJson(Map<String, dynamic> json) {
    return AssistantMessage(
      id: json['id'],
      object: json['object'],
      createdAt: json['created_at'],
      threadId: json['thread_id'],
      role: json['role'],
      content: List<MessageContent>.from(
          json['content'].map((content) => MessageContent.fromJson(content))),
      fileIds: List<String>.from(json['file_ids']),
      assistantId: json['assistant_id'] as String?,
      runId: json['run_id'] as String?,
      metadata: json['metadata'],
    );
  }
}
