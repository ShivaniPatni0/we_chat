
import 'dart:developer';

import 'package:chat_application/firebase_options.dart';
import 'package:chat_application/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initilizeFirebase();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   final FirebaseFirestore db = FirebaseFirestore.instance;
//   final CollectionReference users = db.collection('users');
// // final Map<String,dynamic> userFeilds = {
// //   'emails': 'shivanijain934@gmail.com',
// //   'username': 'balu',
// // };
// // await users.doc('balu').set(userFeilds);
//   final DocumentSnapshot snapshot = await users.doc('l6bg6BwJFtqRJbHr7bkN').get();
//   final userFeild = snapshot.data();
//   log(userFeild.toString());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

_initilizeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);

    var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
    visibility: NotificationVisibility.VISIBILITY_PUBLIC,
);
log(result);
  
}



// web       1:758299826793:web:b18210baf905e88ec7a0f8
// android   1:758299826793:android:6ff534f3ab6e5b1ec7a0f8
// ios       1:758299826793:ios:33d32231b4f5ac1dc7a0f8
// macos     1:758299826793:ios:33d32231b4f5ac1dc7a0f8
// windows   1:758299826793:web:7ef39a1b22b8b3a0c7a0f8