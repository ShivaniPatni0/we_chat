import 'package:chat_application/screens/auth/login/login_screen.dart';
import 'package:chat_application/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
         const kPrimaryColor = Color(0xFF6F35A5);
    const kPrimaryLightColor = Color(0xFFF1E6FF);

    const double defaultPadding = 16.0;
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
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 6),
            child: Text(
              "Login".toUpperCase(),
              style: const TextStyle(color: kPrimaryLightColor),
                     ),
          ) ),
        
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
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding *6),
            child: Text(
              "Sign Up".toUpperCase(),
              style: const TextStyle(color: kPrimaryColor,fontSize: 12 ),
            ),
          ),
        ),
      ],
    );
  }
}