// Higher-level message type that is used for the purposes of rendering and
// database interaction
class ChatMessage {
  String otherHandle; // Handle of a friend
  bool mine; // Whether the message is mine
  String text; // Contents of a message
  DateTime sentAt; // Time of message reception

  ChatMessage(this.otherHandle, this.mine, this.text, this.sentAt);
}

// Lower-level network representationg of a message object
class NetworkMessage {
  String handle; // Handle of a message source
  int randomId; // Random ID designed for message duplicate avoidance
  String text; // Message contents (will be encoded in)
  DateTime sentAt; // Time of message creation

  // TODO Maybe insert time for rendering as well
  NetworkMessage(this.handle, this.randomId, this.text, this.sentAt);

  NetworkMessage.fromChatMessage(ChatMessage msg, int randomId, String handle)
      : handle = handle,
        randomId = randomId,
        text = msg.text,
        sentAt = msg.sentAt;

  NetworkMessage.fromJson(Map<String, dynamic> json)
      : handle = json['handle'],
        randomId = json['randomId'],
        text = json['text'],
        sentAt = json['sentAt'];

  Map<String, dynamic> toJson() => {
        'handle': handle,
        'randomId': randomId,
        'text': text,
        'sentAt': sentAt,
      };
}
