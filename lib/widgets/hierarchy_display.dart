import 'package:flutter/material.dart';
import 'package:kp/models/heirachy_unit.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class HierarchyDisplay extends StatefulWidget {
  final void Function(String path, String name, int unitId) onChanged;
  final String initialPath;
  final String initialName;
  HierarchyDisplay({this.onChanged, this.initialPath, this.initialName});
  @override
  State createState() => HierarchyDisplayState();
}

class HierarchyDisplayState extends State<HierarchyDisplay> {
  String path;
  String unitName;
  int unitId;

  @override
  void initState() {
    path = widget.initialPath;
    unitName = widget.initialName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<HierarchyUnit> hierarchyUnits = context
        .select((MetadataProvider metaProvider) => metaProvider.hierarchyUnits);
    if (hierarchyUnits == null) {
      return LabeledTextField(
        readOnly: true,
        controller: TextEditingController(text: 'Loading List..'),
        text: "Facility Name",
        onTap: () {},
      );
    }
    return LabeledTextField(
      readOnly: true,
      hintText: "-- Select Facility --",
      controller: TextEditingController(text: unitName == null ? "" : unitName),
      text: "Facility Name",
      onTap: () {
        Provider.of<AuthProvider>(context, listen: false)
            .resetInactivityTimer();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      text: 'Facility List',
                    ),
                  ],
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: HierarchySelectionModal(
                    units: hierarchyUnits,
                    onChanged: (path, name, unitId) {
                      widget.onChanged(path, name, unitId);
                      setState(() {
                        unitName = name;
                      });
                    },
                  ),
                ),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'CLOSE',
                        style: TextStyle(color: Colors.blueAccent),
                      ))
                ],
              );
            });
      },
    );
  }
}

class HierarchySelectionModal extends StatefulWidget {
  final List<HierarchyUnit> units;
  final void Function(String path, String facilityName, int unitId) onChanged;
  HierarchySelectionModal({this.units, this.onChanged});
  @override
  State createState() => HierarchySelectionModalState();
}

class HierarchySelectionModalState extends State<HierarchySelectionModal> {
  String path;
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children = widget.units.map((e) {
      return HierarchyUnitDisplay(
        unit: e,
        level: 1,
        groupValue: path,
        onSelected: (val, unit) {
          setState(() {
            path = val;
            print(val);
            widget.onChanged(path, unit.name, unit.id);
            Navigator.pop(context);
          });
        },
      );
    }).toList();

    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [...children],
          ),
        )
      ],
    );
  }
}

class HierarchyUnitDisplay extends StatefulWidget {
  final HierarchyUnit unit;
  final int level;
  final String parentPath;
  final String groupValue;
  final void Function(String value, HierarchyUnit unit) onSelected;
  HierarchyUnitDisplay(
      {this.unit,
      this.level,
      this.onSelected,
      this.groupValue,
      this.parentPath});
  @override
  State createState() => HierarchyUnitDisplayState();
}

class HierarchyUnitDisplayState extends State<HierarchyUnitDisplay> {
  bool expanded = false;
  String selected;
  String path;

  @override
  void initState() {
    path = "${widget.parentPath}/${widget.unit.code}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (expanded) {
      children = widget.unit.children.map((e) {
        return HierarchyUnitDisplay(
          unit: e,
          level: widget.level + 1,
          parentPath: path,
          onSelected: widget.onSelected,
        );
      }).toList();
    }
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .resetInactivityTimer();
              // if (widget.level > 3 && widget.unit.children.length == 0) {
              //   print(path);
              //   widget.onSelected(path, widget.unit);
              //   return;
              // }
              if (widget.level == 5) {
                widget.onSelected(path, widget.unit);
                return;
              }
              if (widget.level == 1) {
                setState(() {
                  expanded = !expanded;
                });
                return;
              }
              if (widget.unit.code != null || widget.level > 2) {
                setState(() {
                  expanded = !expanded;
                });
              }
            },
            child: Row(
              children: [
                widget.level == 5
                    ? SizedBox(
                        width: 20,
                      )
                    : Icon(
                        expanded == true
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down_rounded,
                        color: widget.unit.code == null && widget.level == 2
                            ? Colors.grey
                            : Colors.black,
                      ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Text(
                  widget.unit.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.unit.code == null && widget.level == 2
                          ? Colors.grey
                          : widget.level == 5
                              ? Colors.blueAccent
                              : Colors.black),
                ))
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          expanded
              ? Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    children: [...children],
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
