import 'package:chat_application/api/api.dart';
import 'package:chat_application/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../../component/constant.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    bool showSpinner = false;
    String? email;
    String? password;
    String? name;
    final _formKey = GlobalKey<FormState>();

    //validation condition Email
    String? validateEmail(String? value) {
      const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
          r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
          r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
          r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
          r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
          r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
          r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
      final regex = RegExp(pattern);

      return value!.isNotEmpty && !regex.hasMatch(value)
          ? 'Enter a valid email address'
          : null;
    }

    //validation condition password
    String? validatePassword(String? value) {
      RegExp regex = RegExp(
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
      var passNonNullValue = value ?? "";
      if (passNonNullValue.isEmpty) {
        return ("Password is required");
      } else if (passNonNullValue.length < 6) {
        return ("Password Must be more than 5 characters");
      } else if (!regex.hasMatch(passNonNullValue)) {
        return ("Password should contain upper,lower,digit and Special character ");
      }
      return null;
    }

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              email = value;
            },
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              hintText: "Your email",
              label: const Text('Email'),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              cursorColor: kPrimaryColor,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                name = value;
              },
              decoration: InputDecoration(
                label: const Text('Name'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                hintText: "Your name",
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.man),
                ),
              ),
            ),
          ),
          TextFormField(
            validator: validatePassword,
            textInputAction: TextInputAction.done,
            obscureText: true,
            cursorColor: kPrimaryColor,
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(
              label: const Text('Password'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              hintText: "Your password",
              prefixIcon: const Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock),
              ),
            ),
          ),

          const SizedBox(height: defaultPadding / 1),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                showSpinner = true;
              });
              try {
                if (_formKey.currentState?.validate() ?? false) {
                  final newUser = await APIs.auth
                      .createUserWithEmailAndPassword(
                          email: email!, password: password!);

                  if (newUser != null) {
                    newUser.user?.updateDisplayName(name!);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  }
                  setState(() {
                    showSpinner = false;
                  });
                }
              } catch (e) {
                print(e);
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding * 6),
              child: Text(
                "Sign Up".toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          // const SizedBox(height: defaultPadding),
          // AlreadyHaveAnAccountCheck(
          //   login: false,
          //   press: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) {
          //           return const LoginScreen();
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
