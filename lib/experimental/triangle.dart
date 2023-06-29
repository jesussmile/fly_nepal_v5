import 'dart:math';

import 'package:flutter/material.dart';

class TriangleClipper extends CustomClipper<Path> {
  final double rotationAngle;

  TriangleClipper({this.rotationAngle = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (rotationAngle == 0) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else if (rotationAngle == 0.5 * pi) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else if (rotationAngle == 1.5 * pi) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (rotationAngle == pi) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, size.height);
    }

    path.close();

    final matrix = Matrix4.identity();
    final center = Offset(size.width / 2, size.height / 2);

    matrix.translate(center.dx, center.dy);
    matrix.rotateZ(rotationAngle);
    matrix.translate(-center.dx, -center.dy);

    path.transform(matrix.storage);

    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) =>
      rotationAngle != oldClipper.rotationAngle;
}
