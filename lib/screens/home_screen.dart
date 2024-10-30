import 'dart:developer';
import 'package:chat_application/api/api.dart';
import 'package:chat_application/helper/dialogs.dart';
import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/screens/group_add.dart';
import 'package:chat_application/screens/profile_screen.dart';
import 'package:chat_application/widgets/group_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_application/widgets/chat_user_card.dart';

import 'auth/component/constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<ChatUser> _list = [];
  List<GroupChat> _listGroup = [];
  //search list
  final List<ChatUser> _searchlist = [];
  late TabController tabController;
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfIntro();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    @override
    void dispose() {
      tabController.dispose();
      super.dispose();
    }

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
              backgroundColor: kPrimaryColor,
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
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GroupChat_Screen_add()));
                    },
                    icon: const Icon(Icons.group_add_rounded)),
              ],
            ),
            body: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: [
                      TabBar(
                        controller: tabController,
                        tabs: [
                          Tab(text: 'Chats'),
                          Tab(text: 'Groups'),
                        ],
                      ),
                      SizedBox(
                        height: 400, // Adjust height as needed
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            ChatScreen(
                              isSearching: _isSearching,
                              list: _list,
                              searchlist: _searchlist,
                            ),
                            GroupScreen(
                              list: _listGroup,
                            ),
                          ],
                        ),
                      ),
                    ])),
              ],
            ),
            floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  backgroundColor: kPrimaryColor,
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
                      color: kPrimaryColor,
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

// chat Screens
class ChatScreen extends StatefulWidget {
  List<ChatUser> list = [];
  List<ChatUser> searchlist = [];
  bool isSearching;
  ChatScreen(
      {super.key,
      required this.list,
      required this.searchlist,
      required this.isSearching});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                      if (snapshot.data != null &&
                          snapshot.data!.docs.isNotEmpty) {
                        final data = snapshot.data?.docs;
                        //singleChatUser
                        widget.list = data!
                            .map((e) => ChatUser.fromJson(e.data()))
                            .toList();
                        // //groupChat list
                        // _listGroup = data!
                        //     .map((e) => GroupChat.fromJson(e.data()))
                        //     .toList();
                        // print(_listGroup.length);
                      }
                  }
                  if (widget.list.isNotEmpty) {
                    return ListView.builder(
                        itemCount: widget.isSearching
                            ? widget.searchlist.length
                            : widget.list.length,
                        itemBuilder: (context, index) {
                          return CharUserCard(
                              user: widget.isSearching
                                  ? widget.searchlist[index]
                                  : widget.list[index]);
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
    );
  }
}

// Sample Screens
class GroupScreen extends StatefulWidget {
  List<GroupChat> list = [];
  GroupScreen({
    super.key,
    required this.list,
  });

  @override
  State<GroupScreen> createState() => _groupScreenState();
}

class _groupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: APIs.getAllUserGroupId(),
          builder: (context, snapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: APIs.getAllGroupUsers(
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
                      if (snapshot.data != null &&
                          snapshot.data!.docs.isNotEmpty) {
                        final data = snapshot.data?.docs;

                        // //groupChat list
                        widget.list = data!
                            .map((e) => GroupChat.fromJson(e.data()))
                            .toList();
                        print(widget.list.length);
                      }
                  }
                  if (widget.list.isNotEmpty) {
                    return ListView.builder(
                        itemCount: widget.list.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                              stream: APIs.getAllGroupUsersID(widget
                                  .list[0].members
                                  .map((e) => e)
                                  .toList()),
                              builder: (context, snapshot) {
                                // final data = snapshot.data.docs;

                                // // //groupChat list
                                // final value = data
                                //     .map((e) => ChatUser.fromJson(e.data()))
                                //     .toList();

                                // print(value.length);
                                return GroupUserCard(
                                  user: widget.list[index],
                                );
                              });
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
    );
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