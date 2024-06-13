import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application/api/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'auth/login_screen.dart';

//profile screen -- to show signed in user info
class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _image;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: GestureDetector(
        //hiding keyboard
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            //app bar
            appBar: AppBar(title: const Text('Profile Screen')),

            //floating button to log out
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.orange[400],
                  onPressed: () async {
                    Dialogs.showProgressBar(context);
                    await APIs.updateActiveStatus(false);

                    await APIs.auth.signOut().then((value) async => {
                          await GoogleSignIn().signOut().then((value) => {
                                //for hiding progress bar
                                Navigator.pop(context),

                                APIs.auth = FirebaseAuth.instance,

                                //for moving to home screen
                                Navigator.pop(context),
                                //replace home to login
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => LoginScreen()))
                              })
                        });
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout')),
            ),

            //body
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(width: mq.width, height: mq.height * .03),

                    //user profile picture
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_image!.path),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: MaterialButton(
                              elevation: 1,
                              onPressed: () {
                                _showBottomSheet();
                              },
                              shape: const CircleBorder(),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              color: Colors.white,
                            ))
                      ],
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .03),

                    // user email label
                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // name input field
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (value) => value != null && value!.isNotEmpty
                          ? null
                          : 'Required Feild',
                      decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Happy Singh',
                          label: const Text('Name')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    // about input field
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (value) => value != null && value!.isNotEmpty
                          ? null
                          : 'Required Feild',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outline,
                              color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Feeling Happy',
                          label: const Text('About')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // update profile button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * .5, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) =>
                              Dialogs.showSnackbar(
                                  context, 'Profile Updated Successfully'));
                          log('inside validator');
                        }
                      },
                      icon: const Icon(Icons.edit, size: 28),
                      label:
                          const Text('UPDATE', style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }

  //bottom shit for   picking a profile  picture of user

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .09),
            children: [
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path : ${image.path} ImagemimeType: ${image.mimeType}');
                          setState(() {
                            _image = image;
                          });
                          APIs.updateProfilePicture(File(_image!.path));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/add_image.png')),

                  //for adding some space
                  SizedBox(width: mq.height * .02),
                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path : ${image.path}');
                          setState(() {
                            _image = image;
                          });
                          APIs.updateProfilePicture(File(_image!.path));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        });
  }

  // bottom sheet for picking a profile picture for user
//   void _showBottomSheet() {
//     showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//         builder: (_) {
//           return ListView(
//             shrinkWrap: true,
//             padding:
//                 EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
//             children: [
//               //pick profile picture label
//               const Text('Pick Profile Picture',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

//               //for adding some space
//               SizedBox(height: mq.height * .02),

//               //buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   //pick from gallery button
//                   ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           shape: const CircleBorder(),
//                           fixedSize: Size(mq.width * .3, mq.height * .15)),
//                       onPressed: () async {
//                         final ImagePicker picker = ImagePicker();

//                         // Pick an image
//                         final XFile? image = await picker.pickImage(
//                             source: ImageSource.gallery, imageQuality: 80);
//                         if (image != null) {
//                           log('Image Path: ${image.path}');
//                           setState(() {
//                             _image = image.path;
//                           });

//                           APIs.updateProfilePicture(File(_image!));

//                           // for hiding bottom sheet
//                           if (mounted) Navigator.pop(context);
//                         }
//                       },
//                       child: Image.asset('images/add_image.png')),

//                   //take picture from camera button
//                   ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           shape: const CircleBorder(),
//                           fixedSize: Size(mq.width * .3, mq.height * .15)),
//                       onPressed: () async {
//                         final ImagePicker picker = ImagePicker();

//                         // Pick an image
//                         final XFile? image = await picker.pickImage(
//                             source: ImageSource.camera, imageQuality: 80);
//                         if (image != null) {
//                           log('Image Path: ${image.path}');
//                           setState(() {
//                             _image = image.path;
//                           });

//                           APIs.updateProfilePicture(File(_image!));

//                           // for hiding bottom sheet
//                           if (mounted) Navigator.pop(context);
//                         }
//                       },
//                       child: Image.asset('images/camera.png')),
//                 ],
//               )
//             ],
//           );
//         });
//   }
// }
}
