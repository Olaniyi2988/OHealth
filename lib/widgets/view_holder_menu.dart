import 'package:flutter/material.dart';

class ViewHolderMenu extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  ViewHolderMenu(
      {this.selected = false, this.icon, this.text = "", this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected == true ? Colors.black : Colors.grey,
            size: 25,
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            text,
            style: TextStyle(
                color: selected == true ? Colors.black : Colors.grey,
                fontSize: 15),
          )
        ],
      ),
    );
  }
}
