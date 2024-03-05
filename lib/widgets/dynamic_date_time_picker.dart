import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:provider/provider.dart';

class DynamicDateTimePicker extends StatefulWidget {
  final void Function(DateTime time) onDateChanged;
  final DateTime initialDate;
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic> value) onValueChanged;
  final GlobalKey<DynamicDateTimePickerState> key;
  DynamicDateTimePicker(
      {this.onDateChanged,
      this.initialDate,
      this.config,
      this.key,
      this.onValueChanged})
      : super(key: key);
  @override
  State createState() => DynamicDateTimePickerState();
}

class DynamicDateTimePickerState extends State<DynamicDateTimePicker> {
  DateTime selectedDate;
  @override
  void initState() {
    selectedDate = widget.initialDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DynamicFormDataInfo info = DynamicFormDataInfo.of(context);
    if (info != null && info.editData != null && selectedDate == null) {
      if (info.editData[widget.config['key']] != null) {
        selectedDate =
            convertStringToDateTime(info.editData[widget.config['key']]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.config['label'] != null
            ? Padding(
                padding: EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.config['label'],
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 7,
                    ),
                  ],
                ),
              )
            : Container(),
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
              Provider.of<AuthProvider>(context, listen: false)
                  .resetInactivityTimer();
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                      lastDate: DateTime.now())
                  .then((value) {
                setState(() {
                  selectedDate = value;
                  widget.onValueChanged(
                      {widget.config['key']: selectedDate.toIso8601String()});
                  if (widget.onDateChanged != null) {
                    widget.onDateChanged(selectedDate);
                  }
                });
              });
            },
            leading: Icon(
              Icons.calendar_today,
              color: Colors.blueAccent,
            ),
            title: Text(
              selectedDate == null
                  ? ''
                  : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(fontSize: 11),
            ),
            trailing: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
        widget.config['description'] != null
            ? Padding(
                padding: EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 7,
                    ),
                    Text(widget.config['description'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.grey)),
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}

// var eg = {
//   "label": "Date Initial ADR Counselling Completed",
//   "format": "dd-MMM-yyyy",
//   "tableView": false,
//   "enableMinDateInput": false,
//   "datePicker": {
//     "disableWeekends": false,
//     "disableWeekdays": false
//   },
//   "enableMaxDateInput": false,
//   "key": "dateTime",
//   "type": "datetime",
//   "input": true,
//   "widget": {
//     "type": "calendar",
//     "displayInTimezone": "viewer",
//     "locale": "en",
//     "useLocaleSettings": false,
//     "allowInput": true,
//     "mode": "single",
//     "enableTime": true,
//     "noCalendar": false,
//     "format": "dd-MMM-yyyy",
//     "hourIncrement": 1,
//     "minuteIncrement": 1,
//     "time_24hr": false,
//     "minDate": null,
//     "disableWeekends": false,
//     "disableWeekdays": false,
//     "maxDate": null
//   },
//   "hideOnChildrenHidden": false
// }
