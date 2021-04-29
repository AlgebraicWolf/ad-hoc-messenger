class Contact {
  String handle;
  String publicKey;
  String name;

  Contact(this.handle, this.publicKey, this.name);
}

class Message {
  String otherHandle;
  String text;
  DateTime date;
  bool isFromMe;

  Message(this.otherHandle, this.text, this.date, this.isFromMe);
}
