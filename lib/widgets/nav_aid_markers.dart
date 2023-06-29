import 'package:flutter/material.dart';

class NavAidMarkerTap extends StatelessWidget {
  final String str;
  final String info;

  const NavAidMarkerTap({super.key, required this.str, required this.info});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  Text(str), //'TRIBHUVAN INTL, 02 (10085 ft) 20 (10085 ft) '),
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
      // child: SvgPicture.asset(
      //   "assets/circle-circle-outline-svgrepo-com.svg",
      //   color: Colors.blue,
      // ),

      child: Column(
        children: [
          const Icon(
            Icons.hexagon_outlined,
            color: Colors.blue,
            size: 18,
          ),
          Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(133, 44, 41, 41)),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                info,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  overflow: TextOverflow.fade,
                  fontSize: 7.0,
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
