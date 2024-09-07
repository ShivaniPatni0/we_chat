import 'package:flutter/material.dart';

import 'or_divider.dart';
import 'social_icon.dart';

class SocalSignUp extends StatelessWidget {
  final Function? ontapGoogle;
  const SocalSignUp({Key? key,  this.ontapGoogle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SocalIcon(
              iconSrc: "assets/images/google.png",
              press: () => ontapGoogle,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
