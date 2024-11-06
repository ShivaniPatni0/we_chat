class ChatUser {
  ChatUser({
    required this.name,
    required this.about,
    required this.isOnline,
    required this.pushToken,
    required this.lastActive,
    required this.id,
    required this.email,
    required this.image,
    required this.createdAt,
  });
  late String name;
  late String about;
  late bool isOnline;
  late String pushToken;
  late String lastActive;
  late String id;
  late String email;
  late String image;
  late String createdAt;

  ChatUser.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    isOnline = json['is_online'] ?? '';
    pushToken = json['push_token'] ?? '';
    lastActive = json['last_active'] ?? '';
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    image = json['image'] ?? '';
    createdAt = json['created_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['about'] = about;
    _data['is_online'] = isOnline;
    _data['push_token'] = pushToken;
    _data['last_active'] = lastActive;
    _data['id'] = id;
    _data['email'] = email;
    _data['image'] = image;
    _data['created_at'] = createdAt;
    return _data;
  }
}

class GroupChat {
  GroupChat(
      {required this.id,
      required this.chatRoomTitle,
      // required this.deleted,
      required this.deletedAt,
      //this.isGroup,
      required this.groupid,
      required this.members,
      required this.memberIds});
  late String id;
  late String chatRoomTitle;
  late List<dynamic> memberIds;
  //late bool? isGroup;
  // late bool deleted;
  late String? deletedAt;
  late List<dynamic> members;
  late String groupid;

  GroupChat.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    groupid = json['groupid'] ?? '';
    chatRoomTitle = json['chatRoomTitle'] ?? '';
    memberIds = json['memberIds'] ?? [];
    // isGroup = json['isGroup'] ?? false;
    // deleted = json['deleted'] ?? '';
    deletedAt = json['deletedAt'] ?? '';
    members = json['members'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};

    _data['id'] = id;
    _data['groupid'] = groupid;
    _data['chatRoomTitle'] = chatRoomTitle;
    _data['memberIds'] = memberIds;
    //_data['isGroup'] = isGroup;
    // _data['deleted'] = deleted;
    _data['deletedAt'] = deletedAt;
    _data['members'] = members;

    return _data;
  }
}
