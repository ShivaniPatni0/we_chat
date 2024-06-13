import 'package:chat_application/api/api.dart';
import 'package:chat_application/helper/my_date_util.dart';
import 'package:chat_application/main.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/models/message.dart';
import 'package:chat_application/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CharUserCard extends StatefulWidget {
  final ChatUser user;
  const CharUserCard({super.key, required this.user});

  @override
  State<CharUserCard> createState() => _CharUserCardState();
}

class _CharUserCardState extends State<CharUserCard> {
  //last message info (if null --> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Card(
        shadowColor: Colors.grey.shade800,
        margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
        // color: Colors.blue.shade100,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
            onTap: () {
              //for navigating to chat screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(
                            user: widget.user,
                          )));
            },
            child: StreamBuilder(
              stream: APIs.getLastMessages(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;

                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _message = list[0];

                return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        height: mq.height * .055,
                        width: mq.height * .055,
                        imageUrl: widget.user.image,
                        // placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child:  Icon(CupertinoIcons.person)),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1,
                    ),
                    trailing: _message == null
                        ? null //show nothing when no message is sent
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ?
                            //show for unread message
                            Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            //message sent time
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: const TextStyle(color: Colors.black54),
                              ));
              },
            )));
  }
}
