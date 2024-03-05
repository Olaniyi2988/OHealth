import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomTextField extends StatelessWidget {
  final bool showIcon;
  final TextEditingController controller;
  final void Function(String) onChanged;
  CustomTextField({this.showIcon = true, this.controller, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey[300])),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: TextField(
            controller: controller,
            onChanged: (val) {
              Provider.of<AuthProvider>(context, listen: false)
                  .resetInactivityTimer();
              onChanged(val);
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none),
                filled: true,
                hintText: 'Search Client',
                fillColor: Colors.grey[100]),
          )),
          showIcon == true
              ? SizedBox(
                  width: 80,
                  child: Center(
                    child: Icon(Icons.search),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
