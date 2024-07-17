import 'dart:io';
import 'dart:math';

import 'package:chat_application/screens/auth/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../api/api.dart';
import '../../../helper/dialogs.dart';
import '../../home_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        // log('\nUser : ${user.user}');
        // log('\nUserAdditionalInfo : ${user.additionalUserInfo}');

        if (await APIs.userExists()) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ));
        } else {
          await APIs.createUser().then((value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              )));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('\n_signInWithGoogle : $e');
      Dialogs.showSnackbar(context, 'Something went wrong(Check Internet)');
    }
  }

  @override
  Widget build(BuildContext context) {
    const kPrimaryColor = Color(0xFF6F35A5);
    const kPrimaryLightColor = Color(0xFFF1E6FF);
    bool showSpinner = false;
    String? email;
    String? password;
    LoginScreen login;

    const double defaultPadding = 16.0;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,

      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
             onChanged: (value) {
                email = value;
              },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              hintText: "Your email",
              label: const Text('Email'),
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              onChanged: (value) {
                password = value;
              },
              decoration: InputDecoration(
                fillColor: kPrimaryLightColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                hintText: "Your password",
                label: const Text('Password'),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              elevation: 0,
            ),
            onPressed: () async {
              setState(() {
                showSpinner = true;
              });
              try {
                final user = await APIs.auth.signInWithEmailAndPassword(
                    email: email!, password: password!);
                if (user != null) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => HomeScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password Incorect')));
                }
      
                setState(() {
                  showSpinner = false;
                });
              } catch (e) {
                (e);
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding * 6),
              child: Text(
                "Login".toUpperCase(),
                style: TextStyle(color: kPrimaryLightColor),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
      
          InkWell(
              onTap: () {
                _handleGoogleBtnClick();
              },
              child: Image.asset(
                'assets/images/google.png',
                height: 20,
              ))
          // AlreadyHaveAnAccountCheck(
          //   press: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) {
          //           return const SignUpScreen();
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
