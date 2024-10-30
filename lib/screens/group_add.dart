import 'package:chat_application/api/api.dart';
import 'package:chat_application/helper/dialogs.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GroupChat_Screen_add extends StatefulWidget {
  const GroupChat_Screen_add({super.key});

  @override
  State<GroupChat_Screen_add> createState() => _GroupChat_ScreenState();
}

class _GroupChat_ScreenState extends State<GroupChat_Screen_add> {
  @override
  Widget build(BuildContext context) {
    final groupchat = TextEditingController();
    final member = TextEditingController();
    List<ChatUser> _list = [];

    String emails = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              TextField(
                controller: groupchat,
                onChanged: (value) {
                  value = groupchat as String;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    hintText: 'Enter groupChat name',
                    labelText: 'Group Chat name'),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: member,
                onChanged: (value) => emails = value,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    hintText: 'Members',
                    labelText: 'Members'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () {
                    if (groupchat.text.isNotEmpty) {
                      // Split the input string into a list of emails
                      List<String> emailList = emails
                          .split(',')
                          .map((email) => email.trim())
                          .toList();

                      APIs.addGroupChatUsers(emailList, groupchat.text)
                          .then((value) {
                        if (value.isEmpty) {
                          Dialogs.showSnackbar(
                              context, 'User does not exits !!');
                        } else {
                          Dialogs.showSnackbar(context, 'Group is created');
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => HomeScreen()));
                        }
                      });
                    }
                  },
                  child: const Text('submit'))
            ],
          ),
        ),
      ),
    );
  }
}
