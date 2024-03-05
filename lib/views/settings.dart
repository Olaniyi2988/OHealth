import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:kp/custom_plugins/veri_finger.dart';
import 'package:kp/db/settings.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  @override
  State createState() => SettingsState();
}

class SettingsState extends State<SettingsView> {
  Duration timeout;
  bool fingerprint;
  SharedPreferences prefs;

  @override
  void initState() {
    timeout = Duration(minutes: 5);
    fingerprint = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SettingsDB.getInstance().getTimeout().then((value) {
        if (value != null) {
          setState(() {
            timeout = value;
          });
        }
      });

      SettingsDB.getInstance().getFingerprint().then((value) {
        if (value != null) {
          setState(() {
            fingerprint = value;
          });
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (fingerprint == null || timeout == null) {
      return Center(
        child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return LayoutBuilder(builder: (context, constraint) {
      return Container(
        color: Colors.grey[100],
        height: constraint.maxHeight,
        width: constraint.maxWidth,
        child: Column(
          children: [
            Expanded(
                child: ListView(
              children: [
                Container(
                  height: 10,
                ),
                ListTile(
                  onTap: () async {
                    bool val = await confirmPassword('Enter password', context);
                    if (val == false) {
                      showBasicMessageDialog('Incorrect password', context);
                    }

                    if (val == true) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: CustomDurationPicker(
                                initialValue: timeout,
                                onChanged: (val) {
                                  SettingsDB.getInstance().saveTimeout(timeout);
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .resetInactivityTimer();
                                  setState(() {
                                    timeout = val;
                                  });
                                },
                              ),
                              actions: [
                                FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'OKAY',
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    ))
                              ],
                            );
                          });
                    }
                  },
                  tileColor: Colors.white,
                  leading: Icon(Icons.timer),
                  title: Text('Set Timeout Duration'),
                  subtitle: timeout == null
                      ? Text('....')
                      : Text('${timeout.inMinutes} minutes'),
                ),
                Container(
                  height: 10,
                ),
                ListTile(
                  onTap: () async {
                    VeriFingerSDK.openLicenseManager(context).catchError((err) {
                      showBasicMessageDialog(err.toString(), context);
                    });
                  },
                  tileColor: Colors.white,
                  leading: Icon(Icons.fingerprint),
                  title: Text('Activate/Deactivate Fingerprint License'),
                  subtitle: Text(''),
                ),
                ListTile(
                  tileColor: Colors.white,
                  trailing: Checkbox(
                    value: fingerprint,
                    onChanged: (val) async {
                      SettingsDB.getInstance().saveFingerprint(val);
                      setState(() {
                        fingerprint = val;
                      });
                    },
                  ),
                  title: Text('Make fingerprint compulsory'),
                  subtitle: Text(''),
                ),
              ],
            )),
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Developed by Centrifuge Group",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "v1.0.33",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}

class CustomDurationPicker extends StatefulWidget {
  final Function(Duration duration) onChanged;
  final Duration initialValue;
  CustomDurationPicker({this.onChanged, this.initialValue});
  @override
  State createState() => CustomDurationPickerState();
}

class CustomDurationPickerState extends State<CustomDurationPicker> {
  Duration duration;

  @override
  void initState() {
    duration = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DurationPicker(
      duration: duration,
      snapToMins: 1,
      onChange: (val) {
        if (val.inMinutes >= 1) {
          setState(() {
            duration = val;
          });
          if (widget.onChanged != null) {
            widget.onChanged(val);
          }
        }
      },
    );
  }
}
