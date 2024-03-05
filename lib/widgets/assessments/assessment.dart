import 'package:flutter/material.dart';
import 'package:kp/widgets/assessments/question_tile.dart';
import 'package:kp/widgets/forms/form_template.dart';

class Assessment extends StatefulWidget {
  final VoidCallback onFinished;
  final List<String> questions;
  final VoidCallback onBack;
  final removeBackButton;
  final String title;
  Assessment(
      {this.onFinished,
      this.questions,
      this.title,
      this.onBack,
      this.removeBackButton = false});

  @override
  State createState() => AssessmentState();
}

class AssessmentState extends State<Assessment> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = widget.questions.map((e) {
      return Column(
        children: [
          QuestionTile(
            question: e,
          ),
          SizedBox(
            height: 20,
          )
        ],
      );
    }).toList();
    return FormTemplate(
      disableProgressStep: true,
      removeBackButton: widget.removeBackButton,
      onBack: widget.onBack,
      onFinished: widget.onFinished,
      title: widget.title,
      children: children,
    );
  }
}
