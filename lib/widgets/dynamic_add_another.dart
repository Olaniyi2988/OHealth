import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/widgets/dynamic_form_group.dart';

class DynamicAddAnother extends StatefulWidget {
  final Map<String, dynamic> config;
  final GlobalKey<DynamicAddAnotherState> key;
  final Function(Map<String, dynamic> value) onValueChanged;
  DynamicAddAnother({this.config, this.key, this.onValueChanged})
      : super(key: key);
  @override
  DynamicAddAnotherState createState() => DynamicAddAnotherState();
}

class DynamicAddAnotherState extends State<DynamicAddAnother> {
  List<Widget> groups;
  Map<String, dynamic> value = {};
  @override
  void initState() {
    groups = [
      DynamicFormGroup(
        config: widget.config,
        key: GlobalKey(),
        groupName: "0",
        onValueChanged: (value) {
          this.value = {...this.value, ...value};
          Map<String, dynamic> temp = {};
          temp[widget.config['key']] = this.value.values.toList();
          widget.onValueChanged(temp);
        },
      )
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> c = groups.map((e) {
      return Column(
        children: [e, Divider()],
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(10),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey[200], width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...c,
          SizedBox(
            height: 15,
          ),
          RaisedButton(
            color: Colors.blueAccent,
            onPressed: () {
              setState(() {
                groups.add(DynamicFormGroup(
                  groupName: (groups.length + 1).toString(),
                  config: widget.config,
                  key: GlobalKey(),
                  onValueChanged: (value) {
                    this.value = {...this.value, ...value};
                    Map<String, dynamic> temp = {};
                    temp[widget.config['key']] = this.value.values.toList();
                    widget.onValueChanged(temp);
                  },
                ));
              });
            },
            child: Text(
              widget.config['addAnother'] == null
                  ? "Add more"
                  : widget.config['addAnother'],
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
