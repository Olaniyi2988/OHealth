import 'package:flutter/material.dart';

class ProgressStep extends StatefulWidget {
  final double radius;
  final int steps;
  final int initialIndex;
  ProgressStep(
      {this.radius = 20, this.initialIndex = 1, @required this.steps}) {
    assert(steps != null, "Steps cannot be null");
    assert(steps > 0, "Steps must be greater than zero");
    assert(initialIndex > 0, "Step index cannot be a negative value");
    assert(initialIndex <= steps,
        "Step index cannot be greater than the number of steps");
  }
  @override
  State createState() => ProgressStepState();
}

class ProgressStepState extends State<ProgressStep> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = [];
    for (int x = 1; x <= widget.steps; x++) {
      chips.add(Step(
        index: x,
        isCurrentStep: x <= currentIndex,
        radius: widget.radius,
      ));
    }
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [...chips],
      ),
    );
  }
}

class Step extends StatelessWidget {
  final int index;
  final bool isCurrentStep;
  final double radius;
  final Color selectedColor;
  final Color unselectedColor;
  Step(
      {this.index,
      this.isCurrentStep,
      this.radius,
      this.selectedColor = Colors.blueAccent,
      this.unselectedColor});
  @override
  Widget build(BuildContext context) {
    Color unselected = unselectedColor;
    if (unselected == null) {
      unselected = Colors.grey[200];
    }
    Widget chip = Container(
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius / 1.7),
          border: Border.all(color: isCurrentStep ? selectedColor : unselected),
          color: isCurrentStep ? selectedColor : unselected),
      child: FittedBox(
        child: Padding(
          padding: EdgeInsets.all(radius / 1.9),
          child: Text(
            index.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    if (index == 1) {
      return chip;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: radius,
          child: Divider(
            thickness: radius / 5,
            color: isCurrentStep ? selectedColor : unselected,
          ),
        ),
        chip,
      ],
    );
  }
}
