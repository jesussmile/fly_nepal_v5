import 'package:flutter/material.dart';

class WayPointRouteMarkerTap extends StatelessWidget {
  final String str;

  const WayPointRouteMarkerTap({Key? key, required this.str}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(str),
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
          const Icon(
            Icons.star_border_sharp,
            color: Colors.blue,
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
