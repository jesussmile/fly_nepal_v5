import 'package:flutter/material.dart';

class ButtonFlightPlanWindow extends StatelessWidget {
  String text;
  void Function() fn;

  ButtonFlightPlanWindow({
    Key? key,
    required this.text,
    required this.fn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.05,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double minWidth = constraints.minWidth;
          final double fontSize = minWidth * 0.11;
          return ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                const Color.fromARGB(255, 62, 84, 122),
              ),
            ),
            onPressed: fn,
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize),
              //overflow: TextOverflow.fade,
            ),
          );
        },
      ),
    );
  }
}
