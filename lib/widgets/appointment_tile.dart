import 'package:flutter/material.dart';

class AppointmentTile extends StatelessWidget {
  final String name;
  final String date;
  final String reason;

  AppointmentTile({this.date, this.name, this.reason});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
              child: Container(
            color: Colors.grey[100],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(name),
              ),
            ),
          )),
          Expanded(
              child: Container(
            color: Colors.grey[100],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(date),
              ),
            ),
          )),
          Expanded(
              child: Container(
            color: Colors.grey[100],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(reason),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
