import 'package:flutter/material.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:provider/provider.dart';

int convertDateOfBirthToAge(DateTime dateTime) {
  if (dateTime == null) {
    return null;
  }
  DateTime currentDate = DateTime.now();
  Duration diff = currentDate.difference(dateTime);
  return (diff.inDays / 365).floor();
}

KpMetaData findMetaDataFromId(String metaName, int id, BuildContext context) {
  KpMetaData metaData;
  Provider.of<MetadataProvider>(context, listen: false)
      .getMetaFromString(metaName)
      .forEach((element) {
    if (element.id == id) {
      metaData = element;
    }
  });
  return metaData;
}

bool checkAllMetaDataAvailable(List<String> metaNames, BuildContext context) {
  bool allAvailable = true;
  metaNames.forEach((element) {
    if (Provider.of<MetadataProvider>(context, listen: true)
            .getMetaFromString(element) ==
        null) {
      allAvailable = false;
    }
  });
  return allAvailable;
}

String convertDateToString(DateTime dateTime) {
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}

void showBasicMessageDialog(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OKAY",
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ],
        );
      });
}

Future<String> showBasicPromptDialog(
    String message, BuildContext context) async {
  var t = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController text = TextEditingController();
        GlobalKey<FormState> key = GlobalKey();
        return AlertDialog(
          content: Form(
            key: key,
            child: TextFormField(
              decoration: InputDecoration(hintText: message),
              controller: text,
              validator: (val) {
                if (val.length == 0) {
                  return "Can't be empty";
                }

                return null;
              },
            ),
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  if (key.currentState.validate()) {
                    Navigator.pop(context, text.text.trim());
                  }
                },
                child: Text(
                  "OKAY",
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ],
        );
      });

  return t.toString();
}

Future<bool> showBasicConfirmationDialog(String message, BuildContext context,
    {String positiveLabel, String negativeLabel}) async {
  bool value = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(
                  positiveLabel != null ? positiveLabel : "YES",
                  style: TextStyle(color: Colors.blueAccent),
                )),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(
                  negativeLabel != null ? negativeLabel : "NO",
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ],
        );
      });
  return value;
}

bool validateEmail(String val) {
  String value = val.trim();
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return false;
  } else {
    return true;
  }
}

bool validatePhone(String ph) {
  String phone = ph.trim();
  if (phone[0] == '0' && phone.length == 11) {
    return true;
  }

  if (phone[0] == '+' &&
      phone[1] == '2' &&
      phone[2] == '3' &&
      phone[3] == '4' &&
      phone.length == 14) {
    return true;
  }

  return false;
}

Future<bool> confirmPassword(String message, BuildContext context) async {
  bool value = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController pass = TextEditingController();
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              SizedBox(
                height: 10,
              ),
              TextField(
                obscureText: true,
                controller: pass,
              )
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  bool val = Provider.of<AuthProvider>(context, listen: false)
                      .verifyPassword(pass.text);
                  Navigator.pop(context, val);
                },
                child: Text(
                  "VERIFY",
                  style: TextStyle(color: Colors.blueAccent),
                )),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ],
        );
      });
  return value;
}

void showPersistentLoadingIndicator(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          ),
        );
      },
      barrierDismissible: false);
}

List<Widget> splitToChunks(List<Widget> fields, int chunk) {
  var i = 0, j = fields.length;
  List temporary, rows = <Widget>[];
  for (; i < j; i += chunk) {
    try {
      temporary = fields.sublist(i, i + chunk).toList();
    } catch (e) {
      temporary = fields.sublist(i).toList();
    }
    List<Widget> row = [];
    temporary.forEach((element) {
      row.add(Expanded(
        child: Padding(
          child: element,
          padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
        ),
      ));
    });
    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [...row],
    ));
  }
  return rows;
}

DateTime convertStringToDateTime(String value) {
  int year;
  int date;
  int month;
  try {
    year = int.parse(value.split("T")[0].split('-')[0]);
    month = int.parse(value.split("T")[0].split('-')[1]);
    date = int.parse(value.split("T")[0].split('-')[2]);
  } catch (err) {
    year = int.parse(value.split(" ")[0].split('-')[0]);
    month = int.parse(value.split(" ")[0].split('-')[1]);
    date = int.parse(value.split(" ")[0].split('-')[2]);
  }
  return DateTime(year, month, date);
}
