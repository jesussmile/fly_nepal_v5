import 'package:flutter/material.dart';

class WayPointMarkerTap extends StatelessWidget {
  final String str;

  const WayPointMarkerTap({Key? key, required this.str}) : super(key: key);

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(133, 24, 23, 23),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color.fromARGB(255, 7, 223, 247),
                  size: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(1, 1, 4, 1),
                  child: Text(
                    str,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      overflow: TextOverflow.fade,
                      fontSize: 10.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
