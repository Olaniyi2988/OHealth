import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomTimeSelector extends StatefulWidget {
  final void Function(TimeOfDay time) onTimeChanged;
  final TimeOfDay initialTime;
  final bool readOnly;
  final int yearOffset;
  final String title;
  CustomTimeSelector(
      {this.onTimeChanged,
      this.yearOffset,
      this.initialTime,
      this.title = 'Time',
      this.readOnly = false});
  @override
  State createState() => CustomTimeSelectorState();
}

class CustomTimeSelectorState extends State<CustomTimeSelector> {
  TimeOfDay selectedTime;
  @override
  void initState() {
    selectedTime = widget.initialTime;
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
              showTimePicker(
                context: context,
                initialTime:
                    selectedTime == null ? TimeOfDay.now() : selectedTime,
              ).then((value) {
                if (value != null) {
                  setState(() {
                    selectedTime = value;
                    if (widget.onTimeChanged != null) {
                      widget.onTimeChanged(selectedTime);
                    }
                  });
                }
              });
            },
            leading: Icon(
              Icons.access_time_outlined,
              color: Colors.blueAccent,
            ),
            title: Text(
              selectedTime == null
                  ? ''
                  : '${selectedTime.hour}:${selectedTime.minute} ${selectedTime.period.toString().split('.').last}',
              style: TextStyle(fontSize: 11),
            ),
            trailing: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        )
      ],
    );
  }
}
