import 'package:flutter/material.dart';
import 'package:kp/widgets/yes_no_selector.dart';

class QuestionTile extends StatefulWidget {
  final String question;

  QuestionTile({this.question});
  @override
  State createState() => QuestionTileState();
}

class QuestionTileState extends State<QuestionTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(widget.question),
          trailing: YesNoSelector(),
        ),
        Divider()
      ],
    );
  }
}
