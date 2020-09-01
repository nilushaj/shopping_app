import 'package:flutter/material.dart';
class LogoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    
    Path path = Path();

    path.lineTo(0,0.5*size.height);
    path.cubicTo(
        0.6 * size.width,
        0.9*size.height,
        0.7 * size.width,
        0.5*size.height,
        size.width,
        0.6*size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}