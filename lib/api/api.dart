import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs {
//for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase Messaging (Push Notification)
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  // for accessing  firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;
  static get user => auth.currentUser!;
  static late ChatUser me;

  //for getting firebase messaging token

  static Future<void> getFirebaseMessagingToken() async {
    await fmessaging.requestPermission();

    await fmessaging.getToken().then((t) => {
          if (t != null) {me.pushToken = t, log('Push Token : $t')}
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // if user exit or not checking
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.email).get()).exists;
  }

  // for adding chat user for our conversion
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //user doesn't exit

      return false;
    }
  }

  static Future<void> getSelfIntro() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async => {
              if (user.exists)
                {
                  me = ChatUser.fromJson(user.data()!),
                  await getFirebaseMessagingToken(),
                  //for setting user status to active
                  APIs.updateActiveStatus(true),
                  print("My Data : ${user.data()}")
                }
              else
                {await createUser().then((value) => getSelfIntro())}
            });
  }

  //for creating new user

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        name: user.displayName.toString(),
        about:"Hey",
        isOnline: false,
        pushToken: '',
        lastActive: time,
        id: user.uid,
        email: user.email.toString(),
        image: user.photoURL.toString(),
        createdAt: time);

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  // for getting all user from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

// for getting all user from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds : $userIds');
    return userIds.isNotEmpty
        ? firestore
            .collection('users')
            .where('id', whereIn: userIds)
            .snapshots()
        : Stream.empty();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => {sendMessage(chatUser, msg, type)});
  }

  // update user info
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  //send push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {"title": chatUser.name, "body": msg},
          "data": {
            "some_data": "User ID: ${me.id}",
          },
        }
      };

      var res = await post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/we-chat-2c0c7/messages:send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ya29.a0AXooCgsoOaoZJZ2V6559fux8z5RhNOWzhrpB5IdwJ1s-0a-7w38k_G6Jh3JQt3wN84btWVIRRIsMapewhR08kyEGdWU4HGcQzWkLmdML1fv8eoZRlbQRVo4F5TTmk1xhdhnMP9p8gsTSvW9P7CQSkx3JLKqSk_ppRN0daCgYKAVUSARMSFQHGX2MiOoxdqjhGpC6MIM5acEGopQ0171'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      throw Exception('Error : $e');
    }
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension : $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => {log('Data Transfered : ${p0.bytesTransferred / 1000} kb')});

    //update image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  // --------------------Chat Related api ---------------------

  // for getting user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

//update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

//useful for getting conversion of

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

// for getting all messages of a specific conversion from firestore firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time(also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message send to
    final Message message = Message(
        msg: msg,
        read: '',
        told: chatUser.id,
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

//update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

//get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .limit(1)
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now()}.$ext');

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then(
        (p0) => {log('Data Transfered : ${p0.bytesTransferred / 1000} kb')});

    //update image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static void updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.told)}/messages')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
