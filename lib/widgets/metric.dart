import 'package:flutter/material.dart';

class Metric extends StatelessWidget {
  final Color iconColor;
  final String value;
  final String title;
  final IconData iconData;
  Metric({this.iconColor, this.value, this.title, this.iconData});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withAlpha(50),
            child: Icon(
              iconData,
              color: iconColor,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                    color: Colors.grey[300], fontWeight: FontWeight.w500),
              )
            ],
          )
        ],
      ),
    );
  }
}
