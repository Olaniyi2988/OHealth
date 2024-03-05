import 'package:flutter/material.dart';
import 'package:kp/util.dart';
import 'package:kp/views/registration.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/forms/form_template.dart';

class AssessmentSelectionForm extends StatefulWidget {
  final void Function(AssessmentType) onFinished;
  final int stepIndex;
  final int numberOfSteps;
  final bool disableBackButton;
  final bool disableForwardButton;
  final VoidCallback onBack;
  AssessmentSelectionForm(
      {this.stepIndex,
      this.onFinished,
      this.numberOfSteps,
      this.onBack,
      this.disableForwardButton,
      this.disableBackButton});

  @override
  State createState() => AssessmentSelectionFormState();
}

class AssessmentSelectionFormState extends State<AssessmentSelectionForm> {
  dynamic assessment;
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return FormTemplate(
      onBack: widget.onBack,
      onFinished: () {
        if (assessment == null) {
          return showBasicMessageDialog('Select assessment type', context);
        }
        AssessmentType assessmentType;

        if (assessment.toString() == 'ka') {
          assessmentType = AssessmentType.KNOWLEDGE_ASSESSMENT;
        } else if (assessment.toString() == 'hiv') {
          assessmentType = AssessmentType.HIV_ASSESSMENT;
        } else if (assessment.toString() == 'tb') {
          assessmentType = AssessmentType.TB_ASSESSMENT;
        } else if (assessment.toString() == 'sti') {
          assessmentType = AssessmentType.STI_SCREENING;
        }
        widget.onFinished(assessmentType);
      },
      stepIndex: widget.stepIndex,
      numberOfSteps: widget.numberOfSteps,
      disableBackButton: widget.disableBackButton,
      disableForwardButton: widget.disableForwardButton,
      title: 'Assessment',
      children: [
        CustomFormDropDown<String>(
          text: 'Select Assessment type',
          iconData: Icons.assessment_outlined,
          items: [
            DropdownMenuItem<String>(
              value: 'hiv',
              child: Text('HIV Assessment'),
            ),
            DropdownMenuItem<String>(
              value: 'tb',
              child: Text('TB assessment'),
            ),
            DropdownMenuItem<String>(
              value: 'ka',
              child: Text('Knowledge Assessment'),
            ),
            DropdownMenuItem<String>(
              value: 'sti',
              child: Text('Syndromatic STI Screening'),
            )
          ],
          onChanged: (value) {
            setState(() {
              assessment = value;
            });
          },
        ),
      ],
    );
  }
}
