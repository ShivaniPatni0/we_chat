import 'package:chat_application/screens/auth/login/login_screen.dart';
import 'package:chat_application/screens/auth/signup/register_screen.dart';
import 'package:flutter/material.dart';

import '../../auth/component/constant.dart';

class LoginAndSignupBtn extends StatefulWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginAndSignupBtn> createState() => _LoginAndSignupBtnState();
}

class _LoginAndSignupBtnState extends State<LoginAndSignupBtn> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding * 6),
              child: Text(
                "Login".toUpperCase(),
                style: const TextStyle(color: kPrimaryLightColor),
              ),
            )),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const RegistrationScreen();
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLightColor,
            elevation: 0,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 6),
            child: Text(
              "Sign Up".toUpperCase(),
              style: const TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
