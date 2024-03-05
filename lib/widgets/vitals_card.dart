import 'package:flutter/material.dart';
import 'package:kp/models/vitals.dart';
import 'package:kp/util.dart';

class VitalsCard extends StatelessWidget {
  final Vitals vitals;
  VitalsCard({this.vitals});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 15,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  convertDateToString(vitals.dateOfVital),
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
                child: ListTile(
              leading: Icon(
                Icons.favorite_border,
                color: Colors.black,
                size: 20,
              ),
              title: Text('Blood Pressure'),
              subtitle: Text(
                  '${vitals.systolicPressure}/${vitals.diastolicPressure}'),
            )),
            Expanded(
                child: ListTile(
              leading: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  'images/pulse.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              title: Text('Pulse'),
              subtitle: Text('${vitals.pulse}'),
            )),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: ListTile(
              leading: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  'images/thermo.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              title: Text('Temperature'),
              subtitle: Text('${vitals.temperature}'),
            )),
            Expanded(
                child: ListTile(
              leading: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  'images/scale.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              title: Text('Weight'),
              subtitle: Text('${vitals.weight}'),
            )),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: ListTile(
              leading: SizedBox(
                width: 20,
                height: 20,
                child: Icon(
                  Icons.height,
                  color: Colors.black,
                ),
              ),
              title: Text('Height'),
              subtitle: Text('${vitals.height}'),
            )),
            Expanded(child: Container()),
          ],
        ),
        Divider()
      ],
    );
  }
}
