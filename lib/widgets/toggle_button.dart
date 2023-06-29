import 'package:flutter/material.dart';

class JoystickButton extends StatelessWidget {
  final VoidCallback onTopPressed;
  final VoidCallback onLeftPressed;
  final VoidCallback onBottomPressed;
  final VoidCallback onRightPressed;

  const JoystickButton({super.key, 
    required this.onTopPressed,
    required this.onLeftPressed,
    required this.onBottomPressed,
    required this.onRightPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 300,
      child: Stack(
        children: [
          Positioned(
            top: 50,
            left: 200,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onTopPressed,
                  child: const Icon(Icons.arrow_drop_up),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: ElevatedButton(
              onPressed: onLeftPressed,
              child: const Icon(Icons.arrow_left),
            ),
          ),
          Positioned(
            top: 50,
            left: 80,
            child: ElevatedButton(
              onPressed: onRightPressed,
              child: const Icon(Icons.arrow_left),
            ),
          ),
          Positioned(
            top: 50,
            left: 60,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onBottomPressed,
                  child: const Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
