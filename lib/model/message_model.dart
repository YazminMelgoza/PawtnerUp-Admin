class MessageModel {
  String content;
  String? imageURL;
  String senderName;
  int time;

  MessageModel({
    required this.content,
    this.imageURL,
    required this.senderName,
    required this.time,
  });

  // Método para convertir un objeto de mensaje a un mapa
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'imageURL': imageURL,
      'senderName': senderName,
      'time': time,
    };
  }

  // Método para crear un objeto de mensaje desde un mapa
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      content: map['content'],
      imageURL: map['imageURL'],
      senderName: map['senderName'],
      time: map['time'],
    );
  }
}
