import 'package:flutter/cupertino.dart';

enum CustomColor {
  darkBlue,
  orange,
  darkOrange,
  green,
  red,
}

extension CustomColorExtension on CustomColor {
  Color get color {
    switch (this) {
      case CustomColor.darkBlue:
        return const Color.fromARGB(255, 62, 84, 122);
      case CustomColor.orange:
        return const Color.fromARGB(255, 243, 156, 18);
      case CustomColor.darkOrange:
        return const Color.fromARGB(255, 211, 84, 0);
      case CustomColor.green:
        return const Color.fromARGB(255, 39, 174, 96);
      case CustomColor.red:
        return const Color.fromARGB(255, 192, 57, 43);
    }
  }
}
