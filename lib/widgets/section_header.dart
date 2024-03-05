import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  SectionHeader({this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.blueAccent, width: 3))),
      child: Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
