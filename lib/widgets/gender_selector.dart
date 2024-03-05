// import 'package:flutter/material.dart';
// import 'package:kp/models/client.dart';
//
// class GenderSelector extends StatefulWidget {
//   final Gender initialGender;
//   final void Function(Gender gender) onChanged;
//
//   GenderSelector({this.initialGender = Gender.MALE, this.onChanged});
//   @override
//   State createState() => GenderSelectorState();
// }
//
// class GenderSelectorState extends State<GenderSelector> {
//   double radius = 50;
//   Gender gender;
//
//   @override
//   void initState() {
//     gender = widget.initialGender;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         InkWell(
//           onTap: () {
//             setState(() {
//               gender = Gender.MALE;
//               widget.onChanged(gender);
//             });
//           },
//           child: GenderButton(
//             selected: gender == Gender.MALE,
//             asset: 'images/boy.png',
//             radius: radius,
//             selectedColor: Colors.blueAccent,
//             text: 'Male',
//           ),
//         ),
//         SizedBox(
//           width: radius * 2,
//         ),
//         InkWell(
//           onTap: () {
//             setState(() {
//               gender = Gender.FEMALE;
//               widget.onChanged(gender);
//             });
//           },
//           child: GenderButton(
//             selected: gender == Gender.FEMALE,
//             asset: 'images/girl.png',
//             radius: radius,
//             selectedColor: Colors.pinkAccent,
//             text: 'Female',
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class GenderButton extends StatelessWidget {
//   final double radius;
//   final String asset;
//   final bool selected;
//   final String text;
//   final Color selectedColor;
//
//   GenderButton(
//       {this.radius, this.asset, this.selected, this.text, this.selectedColor});
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircleAvatar(
//           radius: radius,
//           backgroundColor: selected ? selectedColor : Colors.grey,
//           child: SizedBox(
//             width: radius * 1.4,
//             height: radius * 1.4,
//             child: FittedBox(
//               child: Image.asset(asset,
//                   color: selected ? null : Colors.grey,
//                   colorBlendMode: selected ? null : BlendMode.hue),
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         Text(
//           text,
//           style: TextStyle(color: selected ? selectedColor : Colors.grey),
//         )
//       ],
//     );
//   }
// }
