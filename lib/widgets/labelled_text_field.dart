import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LabeledTextField extends StatelessWidget {
  final double size;
  final String text;
  final bool obscureText;
  final bool readOnly;
  final int lines;
  final Widget prefixIcon;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String Function(String) validator;
  final void Function(String) onChanged;
  final void Function() onTap;
  LabeledTextField(
      {this.size,
      this.keyboardType,
      this.text,
      this.controller,
      this.obscureText = false,
      this.validator,
      this.readOnly = false,
      this.onTap,
      this.lines,
      this.onChanged,
      this.hintText,
      this.prefixIcon});
  final InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(width: 0, color: Colors.grey[100]));
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text == null
            ? Container()
            : Text(text, style: TextStyle(fontWeight: FontWeight.w500)),
        text == null
            ? Container()
            : SizedBox(
                height: 7,
              ),
        TextFormField(
          validator: validator,
          keyboardType: keyboardType,
          onTap: () {
            Provider.of<AuthProvider>(context, listen: false)
                .resetInactivityTimer();
            if (onTap != null) {
              onTap();
            }
          },
          maxLines: lines,
          obscureText: obscureText,
          readOnly: readOnly,
          controller: controller,
          onChanged: (val) {
            Provider.of<AuthProvider>(context, listen: false)
                .resetInactivityTimer();
            if (onChanged != null) {
              onChanged(val);
            }
          },
          style: TextStyle(fontSize: 15),
          decoration: InputDecoration(
              fillColor: Colors.grey[100],
              filled: true,
              border: border,
              hintText: hintText,
              focusedBorder: border,
              enabledBorder: border,
              prefixIcon: prefixIcon),
        )
      ],
    );
  }
}
