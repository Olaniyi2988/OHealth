import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kp/api/metadata_api.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/widgets/dynamic_form.dart';
import 'package:kp/widgets/dynamic_search_select.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:provider/provider.dart';

class DynamicDropdown extends StatefulWidget {
  final Map<String, dynamic> config;
  final GlobalKey<DynamicDropdownState> key;
  final Function(Map<String, dynamic> value) onValueChanged;
  DynamicDropdown({this.config, this.key, this.onValueChanged})
      : super(key: key);
  @override
  State createState() => DynamicDropdownState();
}

class DynamicDropdownState extends State<DynamicDropdown> {
  var selected;
  bool fetchingMetaData = true;
  List<dynamic> metaData;

  void fetchMetadata(String name) async {
    if (mounted) {
      setState(() {
        fetchingMetaData = true;
      });
    } else {
      fetchingMetaData = true;
    }
    try {
      dynamic metaData = await MetadataApi.getMetaData(name);
      setState(() {
        this.metaData = metaData;
        fetchingMetaData = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingMetaData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List values = widget.config['data']['values'];
    String url = widget.config['data']['url'];

    //remove any duplicate valued list item
    if (values != null) {
      print(values.length);
      List valuesTemp = [];
      List valuesTemp2 = [];
      values.forEach((element) {
        print(element['value']);
        if (!valuesTemp.contains(element['value'])) {
          valuesTemp2.add(element);
          valuesTemp.add(element['value']);
        }
      });
      values = valuesTemp2;
    }

    if (url != null) {
      url = url.split("}").last;
    }

    DynamicFormDataInfo info = DynamicFormDataInfo.of(context);
    if (info != null && info.editData != null && selected == null) {
      if (url == null) {
        values.forEach((element) {
          if (info.editData[widget.config['key']].toString().toLowerCase() ==
              element['value'].toString().toLowerCase()) {
            selected = element['value'];
          }
        });
      } else {
        var meta = Provider.of<MetadataProvider>(context, listen: false)
            .getMetaFromString(url);
        meta.forEach((element) {
          if (info.editData[widget.config['key'].toString()].toString() ==
              element.id.toString()) {
            selected = element;
          }
        });
      }
    }

    return Consumer<MetadataProvider>(
      builder: (context, metaProvider, _) {
        if (url != null) {
          if (metaData == null) {
            metaData = metaProvider.getMetaFromString(url);
            Future.delayed(Duration(seconds: 2)).then((value) {
              fetchMetadata(url);
            });
          }
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
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
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(5)),
              child: url != null && metaData == null
                  ? LabeledTextField(
                      controller: TextEditingController(
                          text: selected == null ? "" : selected.name),
                      readOnly: true,
                      hintText: fetchingMetaData == true && metaData == null
                          ? "Loading.."
                          : "Loading failed. Tap to retry",
                      onTap: () async {
                        if (fetchingMetaData = false && metaData == null) {
                          fetchMetadata(url);
                        }
                      },
                    )
                  : url != null &&
                          url.toLowerCase().contains(
                              'listheirarchyunitsbyparentid'.toLowerCase())
                      ? LabeledTextField(
                          controller: TextEditingController(
                              text: selected == null ? "" : selected.name),
                          readOnly: true,
                          hintText: "-- Select Facility --",
                          onTap: () async {
                            final temp = await Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              List<String> queries =
                                  url.split('?').last.split('&');
                              int id;
                              for (int x = 0; x < queries.length; x++) {
                                if (queries[x].contains('parentid')) {
                                  id = int.parse(queries[x].split('=').last);
                                }
                              }
                              return DynamicSearchSelectView(
                                units: Provider.of<MetadataProvider>(context,
                                        listen: false)
                                    .getUnitsByParentId(id == null ? 1 : id),
                              );
                            }));
                            if (temp != null) {
                              setState(() {
                                selected = temp;
                                widget.onValueChanged(
                                    {widget.config['key']: selected.id});
                              });
                            }
                          },
                        )
                      : DropdownButton(
                          onTap: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .resetInactivityTimer();
                          },
                          isExpanded: true,
                          underline: Container(),
                          items: url != null
                              ? metaData == null
                                  ? null
                                  : metaData.map((e) {
                                      return DropdownMenuItem(
                                        child: Text(e.name),
                                        value: e,
                                      );
                                    }).toList()
                              : values == null
                                  ? null
                                  : values.map((e) {
                                      return DropdownMenuItem(
                                        child: Text(e['label'].toString()),
                                        value: e['value'],
                                      );
                                    }).toList(),
                          onChanged: (val) {
                            Provider.of<AuthProvider>(context, listen: false)
                                .resetInactivityTimer();
                            setState(() {
                              selected = val;
                              if (url != null) {
                                widget.onValueChanged(
                                    {widget.config['key']: selected.id});
                              } else {
                                widget.onValueChanged(
                                    {widget.config['key']: selected});
                              }
                            });
                          },
                          value: selected,
                        ),
            ),
            widget.config['description'] != null
                ? Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.config['description'],
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey)),
                        SizedBox(
                          height: 7,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }
}
