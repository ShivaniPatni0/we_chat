import 'package:chat_application/screens/auth/component/background.dart';
import 'package:flutter/material.dart';
import '../component/constant.dart';
import '../component/responsive.dart';
import 'component/sign_up_form.dart';
import 'component/sign_up_top_image.dart';
import 'component/social_sign_up.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
  });

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {


  @override
  Widget build(BuildContext context) {
    
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
            mobile: MobileSignupScreen(),
            desktop: Row(
              children: [
                 Expanded(
                  child: SignUpScreenTopImage(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 450,
                        child: SignUpForm(),
                      ),
                      SizedBox(height: defaultPadding / 2),
                      //const SocalSignUp(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer(),
          ],
        ),
       // SocalSignUp(ontap: ),
        
      ],
    );
  }
}

  // return Form(
  //   autovalidateMode: AutovalidateMode.always,
  //   key: _formKey,
  //   child: Scaffold(
  //     backgroundColor: Colors.white,
  //     body: ModalProgressHUD(
  //       inAsyncCall: showSpinner,
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 24.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: <Widget>[
  //             Flexible(
  //               child: Hero(
  //                 tag: 'logo',
  //                 child: Container(
  //                   height: 200.0,
  //                   child: Image.asset('assets/images/chat.png'),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(
  //               height: 48.0,
  //             ),
  //             TextFormField(
  //               validator: validateEmail,
  //               keyboardType: TextInputType.emailAddress,
  //               textAlign: TextAlign.center,
  //               onChanged: (value) {
  //                 email = value;
  //               },
  //               decoration: InputDecoration(
  //                   prefixIcon: const Icon(Icons.email, color: Colors.orange),
  //                   border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12)),
  //                   hintText: 'Enter email address',
  //                   label: const Text('Email')),
  //             ),
  //             const SizedBox(
  //               height: 8.0,
  //             ),
  //             TextField(
  //               keyboardType: TextInputType.emailAddress,
  //               textAlign: TextAlign.center,
  //               onChanged: (value) {
  //                 name = value;
  //               },
  //               decoration: InputDecoration(
  //                   prefixIcon: const Icon(Icons.email, color: Colors.yellow),
  //                   border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12)),
  //                   hintText: 'Enter Name',

  //                   label: const Text('Name',style: TextStyle(color: Colors.yellow),)),
  //             ),
  //             const SizedBox(
  //               height: 8.0,
  //             ),
  //             TextFormField(
  //               validator: validatePassword,
  //               obscureText: true,
  //               textAlign: TextAlign.center,
  //               onChanged: (value) {
  //                 password = value;
  //               },
  //               decoration: InputDecoration(
  //                   prefixIcon:
  //                       const Icon(Icons.password, color: Colors.orange),
  //                   border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12)),
  //                   hintText: 'Enter your password',
  //                   label: const Text('Password')),
  //             ),
  //             const SizedBox(
  //               height: 24.0,
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 setState(() {
  //                   showSpinner = true;
  //                 });
  //                 try {
  //                   if (_formKey.currentState?.validate() ?? false) {
  //                     final newUser = await APIs.auth
  //                         .createUserWithEmailAndPassword(
  //                             email: email!, password: password!);

  //                     if (newUser != null) {
  //                       newUser.user?.updateDisplayName(name!);
  //                       Navigator.push(context,
  //                           MaterialPageRoute(builder: (_) => HomeScreen()));
  //                     }
  //                     setState(() {
  //                       showSpinner = false;
  //                     });
  //                   }
  //                 } catch (e) {
  //                   print(e);
  //                 }
  //               },
  //               child: const Text(
  //                 'Register',
  //                 style: TextStyle(color: Colors.orangeAccent),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   ),
  // );

