import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomDateSelector extends StatefulWidget {
  final void Function(DateTime time) onDateChanged;
  final DateTime initialDate;
  final DateTime value;
  final bool useExternalValue;
  final bool readOnly;
  final int yearOffset;
  final String title;
  final int maxAge;
  final bool futureOnly;
  CustomDateSelector(
      {this.onDateChanged,
      this.yearOffset,
      this.initialDate,
      this.title = 'Date of birth',
      this.maxAge,
      this.readOnly = false,
      this.futureOnly = false,
      this.value,
      this.useExternalValue = false});
  @override
  State createState() => CustomDateSelectorState();
}

class CustomDateSelectorState extends State<CustomDateSelector> {
  DateTime selectedDate;
  @override
  void initState() {
    selectedDate = widget.initialDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 65,
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
          child: ListTile(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              Provider.of<AuthProvider>(context, listen: false)
                  .resetInactivityTimer();
              if (widget.readOnly == true) {
                return;
              }
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(Duration(
                          days: widget.yearOffset == null
                              ? 0
                              : widget.yearOffset * 365)),
                      firstDate: widget.futureOnly == true
                          ? DateTime.now()
                          : DateTime(DateTime.now().year - 150,
                              DateTime.now().month, DateTime.now().day),
                      lastDate: widget.futureOnly == true
                          ? DateTime(DateTime.now().year + 1000)
                          : DateTime.now())
                  .then((value) {
                if (value != null) {
                  setState(() {
                    selectedDate = value;
                    if (widget.onDateChanged != null) {
                      widget.onDateChanged(selectedDate);
                    }
                  });
                }
              });
            },
            leading: Icon(
              Icons.calendar_today,
              color: Colors.blueAccent,
            ),
            title: Text(
              widget.useExternalValue == true
                  ? widget.value == null
                      ? ""
                      : '${widget.value.day}/${widget.value.month}/${widget.value.year}'
                  : selectedDate == null
                      ? ''
                      : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(fontSize: 11),
            ),
            trailing: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        )
      ],
    );
  }
}
