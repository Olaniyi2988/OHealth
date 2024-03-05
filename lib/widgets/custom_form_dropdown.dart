import 'package:flutter/material.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomFormDropDown<T> extends StatefulWidget {
  final String text;
  final IconData iconData;
  final bool readOnly;
  final List<DropdownMenuItem<T>> items;
  final void Function(dynamic) onChanged;
  final T initialValue;
  final T value;
  final bool useExternalValue;
  final bool expanded;
  CustomFormDropDown(
      {this.text,
      this.iconData,
      this.items,
      this.onChanged,
      this.initialValue,
      this.value,
      this.useExternalValue = false,
      this.readOnly = false,
      this.expanded = true});
  @override
  State createState() => CustomFormDropDownState<T>();
}

class CustomFormDropDownState<T> extends State<CustomFormDropDown> {
  T value;
  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.text == null
            ? Container()
            : Text(
                widget.text,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
        widget.text == null
            ? Container()
            : SizedBox(
                height: 10,
              ),
        Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
          child: ListTile(
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .resetInactivityTimer();
            },
            title: DropdownButton<T>(
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              underline: Container(),
              value: widget.useExternalValue == true
                  ? widget.value
                  : value == null
                      ? null
                      : widget.items == null
                          ? null
                          : widget.items
                              .where((element) {
                                return element.value.toString() ==
                                    value.toString();
                              })
                              .last
                              .value,
              style: TextStyle(fontSize: 11, color: Colors.black),
              isExpanded: widget.expanded,
              items: widget.items,
              onChanged: (value) {
                Provider.of<AuthProvider>(context, listen: false)
                    .resetInactivityTimer();
                if (widget.readOnly == true) {
                  return;
                }
                if (widget.useExternalValue == false) {
                  setState(() {
                    this.value = value;
                  });
                }
                if (widget.onChanged != null) {
                  widget.onChanged(value);
                }
              },
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
            ),
            leading: widget.iconData == null
                ? null
                : Icon(
                    widget.iconData,
                    size: 35,
                    color: Colors.blueAccent,
                  ),
          ),
        )
      ],
    );
  }
}
