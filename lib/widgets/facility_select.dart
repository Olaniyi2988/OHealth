import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/models/heirachy_unit.dart';
import 'package:kp/util.dart';

class SelectFacilityView extends StatefulWidget {
  final List<HierarchyUnit> units;
  SelectFacilityView({this.units});
  @override
  State createState() => SelectFacilityViewState();
}

List<String> savedLocations;

class SelectFacilityViewState extends State<SelectFacilityView> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<HierarchyUnit> units;
  List<HierarchyUnit> matchedUnits = [];
  bool showSearch = false;

  @override
  void initState() {
    units = widget.units;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                        autofocus: true,
                        readOnly: units == null,
                        onChanged: (text) {
                          if (units != null) {
                            if (text.length == 0) {
                              setState(() {
                                matchedUnits = [];
                                showSearch = false;
                              });
                            } else {
                              List<HierarchyUnit> matchedTemp = [];
                              units.forEach((l) {
                                if (l.name
                                    .toLowerCase()
                                    .contains(text.toLowerCase())) {
                                  matchedTemp.add(l);
                                }
                              });
                              matchedTemp
                                  .sort((a, b) => a.name.compareTo(b.name));
                              setState(() {
                                matchedUnits = matchedTemp;
                                showSearch = true;
                              });
                            }
                          }
                        },
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search Facility",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.transparent)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: units.length == 0 ||
                            (matchedUnits.length == 0 && showSearch == true)
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100, bottom: 500),
                              child: Text(
                                showSearch == true
                                    ? "No match found"
                                    : "No available Locations",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                        : showSearch
                            ? ListView.builder(
                                itemBuilder: (context, count) {
                                  return InkWell(
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      bool value =
                                          await showBasicConfirmationDialog(
                                              "You selected ${matchedUnits[count].name} as the Facility. Continue?",
                                              context);
                                      if (value == true) {
                                        Navigator.of(context)
                                            .pop(matchedUnits[count]);
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text(matchedUnits[count].name),
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  );
                                },
                                itemCount: matchedUnits.length,
                              )
                            : ListView.builder(
                                itemBuilder: (context, count) {
                                  return InkWell(
                                    onTap: () async {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      bool value =
                                          await showBasicConfirmationDialog(
                                              "You selected ${units[count].name} as the Facility. Continue?",
                                              context);
                                      if (value == true) {
                                        Navigator.of(context).pop(units[count]);
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text(units[count].name),
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  );
                                },
                                itemCount: units.length,
                              ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
