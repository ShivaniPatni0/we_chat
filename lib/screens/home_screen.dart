import 'dart:convert';
import 'dart:developer';

import 'package:chat_application/api/api.dart';
import 'package:chat_application/helper/dialogs.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_application/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  //search list
  final List<ChatUser> _searchlist = [];

  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfIntro();

    //for updating user active status acording to lifecycle events
    //resume -- active or online
    //pause -- inactive or offline

    SystemChannels.lifecycle.setMessageHandler((message) {
      log("Message : $message");
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //hinding the keyboard when we tap is detached the screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if serach is on and back button is pressed then close button
          // or else simple close current screen on back button click
          onWillPop: () {
            if (_isSearching) {
              setState(() {
                _isSearching = !_isSearching;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange[400],
              leading: const Icon(CupertinoIcons.home),
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name,Email, ...'),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                      onChanged: (value) {
                        _searchlist.clear();

                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            _searchlist.add(i);
                          }
                          setState(() {
                            _searchlist;
                          });
                        }
                      },
                    )
                  : Center(child: const Text('We Chat')),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(user: APIs.me)));
                    },
                    icon: const Icon(Icons.more_vert)),
              ],
            ),
            body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: APIs.getAllUserId(),
                builder: (context, snapshot) {
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? ['']),
                      //get only those user ,who's ids are provided
                      builder: (context, snapshot) {
                        //if data is loading
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            // return const Center(
                            //   child: CircularProgressIndicator(),
                            // );
                          // if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                          if(snapshot.data!.docs.isNotEmpty){
                              final data = snapshot.data?.docs;
                            
                            _list = data!
                                .map((e) => ChatUser.fromJson(e.data()))
                                .toList();

                          }
                          
                            
                        }
                       if (_list.isNotEmpty) {
                          return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchlist.length
                                  : _list.length,
                              itemBuilder: (context, index) {
                                return CharUserCard(
                                    user: _isSearching
                                        ? _searchlist[index]
                                        : _list[index]);
                              });
                        } else {
                         return const Center(
                              child: Text(
                            'No Connection Found!',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ));
                        }
                      });
                }),
            floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  backgroundColor: Colors.orangeAccent,
                  onPressed: () async {
                    _addChatUserDialog();
                  },
                  child: const Icon(Icons.add_comment_rounded),
                )),
          ),
        ),
      ),
    );
  }

  //add new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.orangeAccent,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //add button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not exits !!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}



              // if (snapshot.hasData) {
              //   final documents = snapshot.data!.docs;
              //   for (var i in documents) {
              //     log('Data ${jsonEncode(i.data())}');
              //     print('Data ${jsonEncode(i.data())}');
              //     list.add(i.data()['name']);
              //   }
              //   return ListView(
              //       children: documents
              //           .map((doc) => Card(
              //                 child: ListTile(title: Text(doc['email'])),
              //               ))
              //           .toList());
              // } else if (snapshot.hasError) {
              //   return Text('Its Error!');
              // }
              // return throw Exception('error');