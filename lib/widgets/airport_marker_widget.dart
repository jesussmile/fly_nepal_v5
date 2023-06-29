import 'package:flutter/material.dart';

class AirportMarkerTap extends StatelessWidget {
  final String str;
  final String info;

  const AirportMarkerTap({super.key, required this.str, required this.info});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  Text(info), //'TRIBHUVAN INTL, 02 (10085 ft) 20 (10085 ft) '),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Column(
        children: [
          Icon(
            Icons.circle,
            color: const Color.fromARGB(255, 136, 246, 141).withOpacity(0.7),
            size: 10,
          ),
          Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(133, 44, 41, 41)),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                str,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  overflow: TextOverflow.fade,
                  fontSize: 10.0,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
