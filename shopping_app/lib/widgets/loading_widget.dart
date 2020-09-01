/*Acts as a  fullscreen modal barrier that prohibits user interaction till a task is complete.*/

import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.5,
          child: const ModalBarrier(dismissible: false, color: Colors.black),
        ),
        Center(
          child: new CircularProgressIndicator(),
        ),
      ],
    );
  }

}
