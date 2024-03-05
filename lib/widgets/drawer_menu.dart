import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/page_provider.dart' as page_provider;
import 'package:provider/provider.dart';

class DrawerMenu extends StatefulWidget {
  final bool selected;
  final String text;
  final double height;
  final double width;
  final IconData iconData;
  final String imageAsset;
  final page_provider.Page page;
  DrawerMenu(
      {this.selected,
      this.text,
      this.iconData,
      this.imageAsset,
      this.height,
      this.width,
      this.page});
  @override
  State createState() => DrawerMenuState();
}

class DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<AuthProvider>(context, listen: false)
            .resetInactivityTimer();
        Provider.of<page_provider.PageProvider>(context, listen: false)
            .setCurrentPage(widget.page);
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: widget.selected
            ? BoxDecoration(
                border: Border(
                    left: BorderSide(width: 8, color: Colors.blueAccent)),
                color: Colors.blueAccent.withAlpha(30))
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: widget.selected ? 22 : 30,
            ),
            widget.imageAsset != null
                ? SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset(widget.imageAsset),
                  )
                : Icon(
                    widget.iconData,
                    size: 30,
                  ),
            SizedBox(
              width: 15,
            ),
            Text(
              widget.text,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
