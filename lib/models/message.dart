class Message {
  Message({
    required this.msg,
    required this.read,
    this.told,
    required this.type,
    required this.fromId,
    required this.sent,
    this.toldIDs,
  });
  late String msg;
  late String read;
  String? told;
  late Type type;
  late String fromId;
  late String sent;
  List<dynamic>? toldIDs;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    toldIDs = json['toldIDs'] ?? [];
    told = json['told'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = told;
    data['toldIDs'] = toldIDs;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
