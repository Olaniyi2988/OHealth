import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/widgets/progress_step.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class FormTemplate extends StatelessWidget {
  final VoidCallback onFinished;
  final VoidCallback onBack;
  final int stepIndex;
  final int numberOfSteps;
  final List<Widget> children;
  final bool disableBackButton;
  final bool disableForwardButton;
  final bool disableProgressStep;
  final bool removeBackButton;
  final bool nextIsSave;
  final String title;

  FormTemplate(
      {this.stepIndex,
      this.onFinished,
      this.numberOfSteps,
      this.children,
      this.disableBackButton = false,
      this.disableForwardButton = false,
      this.disableProgressStep = false,
      this.onBack,
      this.title,
      this.removeBackButton = false,
      this.nextIsSave = false});
  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    controller.addListener(() {
      Provider.of<AuthProvider>(context, listen: false).resetInactivityTimer();
    });
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            disableProgressStep == true
                ? Container()
                : SizedBox(
                    height: 50,
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        ProgressStep(
                          steps: numberOfSteps,
                          initialIndex: stepIndex,
                        )
                      ],
                    ),
                  ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                SectionHeader(
                  text: title,
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: ListView(
                  controller: controller,
                  shrinkWrap: true,
                  children: [
                    ...children,
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        removeBackButton == true
                            ? Container()
                            : Expanded(
                                child: SizedBox(
                                height: 60,
                                child: RaisedButton(
                                    onPressed: disableBackButton == true
                                        ? null
                                        : onBack,
                                    child: Text(
                                      'Back',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    color: Colors.blueAccent),
                              )),
                        removeBackButton == true
                            ? Container()
                            : SizedBox(
                                width: 20,
                              ),
                        Expanded(
                            child: SizedBox(
                          height: 60,
                          child: RaisedButton(
                              onPressed: disableForwardButton == true
                                  ? null
                                  : onFinished,
                              child: Text(
                                nextIsSave ? 'Save' : 'Next',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              color: Colors.blueAccent),
                        ))
                      ],
                    )
                  ],
                )),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
