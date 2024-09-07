import 'package:chat_application/main.dart';
import 'package:chat_application/screens/auth/component/background.dart';
import 'package:chat_application/screens/auth/component/constant.dart';
import 'package:chat_application/screens/auth/login/login_screen_top_image.dart';
import 'package:flutter/material.dart';
import 'login_form.dart';
import '../component/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Background(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 30,
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        child: Responsive(
          mobile:  MobileLoginScreen(),
          desktop: Row(
            children: [
              Expanded(
                child: LoginScreenTopImage(),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: LoginForm(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));

    // Stack(
    //   children: [
    //     AnimatedPositioned(
    //         top: mq.height * .10,
    //         right: _isAnimate ? mq.width * .25 : -mq.width * .5,
    //         width: mq.width * .5,
    //         duration: const Duration(seconds: 1),
    //         child: Image.asset('assets/images/chat.png')),
    //     Positioned(
    //         bottom: mq.height * .10,
    //         left: mq.width * .25,
    //         width: mq.width * .5,
    //         height: mq.height * .21,
    //         child: Column(
    //           children: [
    //             ElevatedButton(
    //                 style: ElevatedButton.styleFrom(
    //                     padding: const EdgeInsets.symmetric(horizontal: 60)),
    //                 onPressed: () {
    //                   Navigator.push(context,
    //                       MaterialPageRoute(builder: (_) => SignInScreen()));
    //                 },
    //                 child: const Text(
    //                   'Login',
    //                   style: TextStyle(
    //                     color: Colors.orangeAccent,
    //                   ),
    //                 )),
    //             const SizedBox(
    //               height: 10,
    //             ),
    //             ElevatedButton(
    //                 style: ElevatedButton.styleFrom(
    //                     padding: const EdgeInsets.symmetric(horizontal: 50)),
    //                 onPressed: () {
    //                   Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                           builder: (_) => RegistrationScreen()));
    //                 },
    //                 child: const Text(
    //                   'Register',
    //                   style: TextStyle(color: Colors.orangeAccent),
    //                 )),
    //             const SizedBox(
    //               height: 20,
    //             ),
    //             InkWell(
    //                 onTap: () {
    //                   _handleGoogleBtnClick();
    //                 },
    //                 child: Image.asset(
    //                   'assets/images/google.png',
    //                   height: 20,
    //                 ))
    //           ],
    //         )),
    //   ],
    // ),
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
