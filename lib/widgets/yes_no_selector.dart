import 'package:flutter/material.dart';

class YesNoSelector extends StatefulWidget {
  @override
  State createState() => YesNoSelectorState();
}

class YesNoSelectorState extends State<YesNoSelector> {
  double size = 40;
  bool isBoy;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isBoy = true;
            });
          },
          child: BinaryButton(
            selected: isBoy,
            iconData: Icons.check_circle_outline_sharp,
            size: size,
            selectedColor: Colors.greenAccent,
          ),
        ),
        SizedBox(
          width: size,
        ),
        InkWell(
          onTap: () {
            setState(() {
              isBoy = false;
            });
          },
          child: BinaryButton(
            selected: isBoy == null ? null : !isBoy,
            iconData: Icons.remove_circle_outline_sharp,
            size: size,
            selectedColor: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}

class BinaryButton extends StatelessWidget {
  final double size;
  final IconData iconData;
  final bool selected;
  final Color selectedColor;

  BinaryButton({this.size, this.iconData, this.selected, this.selectedColor});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData,
            color: selected == null
                ? Colors.grey
                : selected == true
                    ? selectedColor
                    : Colors.grey,
            size: size),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
