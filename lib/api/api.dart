import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_application/models/chat_user.dart';
import 'package:chat_application/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

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

  PushNotificationServices? _notificationServices;

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
        about: "Hey",
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

      var res = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/we-chat-2c0c7/messages:send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer 1//04UhCfGNaoRoICgYIARAAGAQSNwF-L9IrY8deyBrMRwsgVfXLGU9VViq2VRWjh8J_x0Wd590XQe65X8EnT0kQfPv3q1ySEdisZbQ'
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
    await ref.doc(time).set(message.toJson()).then((value) async {
      await PushNotificationServices.getAccessToken();
      await PushNotificationServices.sendNotificationToSelectdDriver(
          me, chatUser, msg);
    });
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

class PushNotificationServices {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "we-chat-2c0c7",
      "private_key_id": "54fe6677ccb13aa01bdab1a06134f7d15a569b96",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDpP/VEsuK1QQ4B\nMgo2UTRqjQ6v76kdoIw6bA8euSkhwq9KidPS8bs84MkRQQrAb8t++jzNnkgeP+XS\nhh7164umUHaSsyreCF5yqUNL/E3hmT/cRBelKqmfZ6JH+Qd8ExsF5AhoXolTHkjk\ntdKveb+5oUeKLgIsxog4qflvt5zNqs+5n2LKY4TD8t47vS5y5iy0X+0fCVdLRyhN\nGYiaYX/rWnmLtl0xV4iujUOzz/hxyeZbLTz3LnHzhnhdP+LD5dx+8eVb6529EGR6\nA27RMntrqK94MR3UthnYwPZPTsJco0I7m6pqUhjsSG9sskmruo535OWSLJhLaNy6\nLOhAPoPVAgMBAAECggEADAAQIpdwfgJJkeqs51QAth2pPIiAQye0JzpRgdNlaBj/\n0z4pkYAB0dU/yv01bCakSdVehPaof7PqY00msSDL98PKgewpX7B/CXenYHSr3hg4\nFqFDNSpvfSXEDd9kUPAbsw8jFpmMh6P2fJvVKdWB9W80gsmwr3SMZBvsmyCPdu5C\nZ90Z8noOY0WMKH28JxmqzDPNOjZxXRIG7T1EQTjGglspzZNiTItlV/J93jqg7XtD\nIU42sS64V8m1ib86yRkrNnTvYrBwtz0sKDKmPz2UFQBathKasmNbamLkcXTlhhSY\nMz1qj3CpqOiZ7qQp7aVDyC3iKD++yTpz34eVXRWBEQKBgQD7JOaXHjasBvhAcWSw\nUTNyCJbK5CNV6K5UTxNcyDkCOMYuoeSIRWKGqzDlXSMCcMnGxcZWINP8IT+6NYQ9\nkO5jfTt96XSfWkBQppeDbGcKYK18yOnDfkpFokjV8E5BtLgaqNaUEaWpRSyIpcJk\ngu6WoGZfFEmOQSxGWtma444tpQKBgQDtwnwvEkZn2dD+7vf2UHtK8Dl4U/DWgWlu\noZb6wVuDlzux8cIzYLcBMJsKI9gX6j8dF4e9S5aSaBKFBmaMyIX6rU+JqS6WZKS7\ncKhqum6su5tFBq6vblo6sWgGOfZ2hY21JeJ3aIs/1WdE4vvsid8DBqZq2FInGi6I\nl+SOBLiGcQKBgH6udGpR4T4RHfRTvnh53TtuPbIGNhTFk/oPETNCBA+s17r6Cq76\nYOKRQ87OljRK9F0BsjQLxyJtGxowmI39p2Ij73hp5FvlSH/mKJMwgSFo9tn09oWY\nFJrfa2IPH0phgGRiOiriY+/oZrhe9JmCuhrcugbH0vqgwVaTySQqGLPJAoGBAMLO\nRDPJNHiopi4LHI3r2WlINL5bgIww0nL74RmpzdKe2iFtZWH1T1yhN5byUX8exgGP\nIv+9bCyfKvVljiaxsdz3naC8Rtigs7yEjOmNwVq0CH9g/0XsE+/dJc9cNI1d1gLj\nfI+7z8RIlOmDVUi0mk3/Z+FJRt6U/CWc1n5qbcpxAoGAdN+P0GbA1el0WxH0GBFu\nyz3QFmg2TDtjWfanQPhRlPOK0Sz8TfSQ7SGgZf4ArjPDjo9y9fLSbhcNvZiaZ+uO\ngdwlaM7Pq6pSJMzOi54dl76NqA3UhVxVPqcGpgpcQad3+PTChxrcdU0fA2fMw4/2\nY3/w9kvzdGFaFb5UFVl0C+A=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-we-chat-shivani-patni@we-chat-2c0c7.iam.gserviceaccount.com",
      "client_id": "112551770191617482670",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-we-chat-shivani-patni%40we-chat-2c0c7.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    //get access token

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    log('accessToken : ${credentials.accessToken.data}');
    return credentials.accessToken.data;
  }

  static sendNotificationToSelectdDriver(
      ChatUser typeID, ChatUser chatUser, String msg) async {
    final String serverKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/we-chat-2c0c7/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "token": chatUser.pushToken,
        "notification": {"title": typeID.name, "body": msg},
        "data": {
          "some_data": "User ID: ${typeID.id}",
        },
      }
    };

    final http.Response response =
        await http.post(Uri.parse(endpointFirebaseCloudMessaging),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $serverKey',
            },
            body: jsonEncode(message));

    if (response.statusCode == 200) {
      log('Notification send');
    } else {
      log('Failed to send FCM message:${response.statusCode}');
    }
  }
}
