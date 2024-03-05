import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  @override
  State createState() => NotifictaionsViewState();
}

class NotifictaionsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.grey[100],
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: ListView(
            children: [
              ListTile(
                title: Text("13 Feb 2021"),
              ),
              NotificationWidget(
                title: "Appointment Notification",
                content:
                    "You have an apoinment with HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Lab Notification",
                content:
                    "Lab report is ready for HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Appointment Notification",
                content:
                    "You have an apoinment with HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Lab Notification",
                content:
                    "Lab report is ready for HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              ListTile(
                title: Text("21 Feb 2021"),
              ),
              NotificationWidget(
                title: "Appointment Notification",
                content:
                    "You have an apoinment with HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Lab Notification",
                content:
                    "Lab report is ready for HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Appointment Notification",
                content:
                    "You have an apoinment with HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Lab Notification",
                content:
                    "Lab report is ready for HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              ListTile(
                title: Text("1 March 2021"),
              ),
              NotificationWidget(
                title: "Appointment Notification",
                content:
                    "You have an apoinment with HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Lab Notification",
                content:
                    "Lab report is ready for HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Appointment Notification",
                content:
                    "You have an apoinment with HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
              NotificationWidget(
                title: "Lab Notification",
                content:
                    "Lab report is ready for HAN/SMQW/XHAE/FSW/QPPE/862553 in 20 munites",
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationWidget extends StatelessWidget {
  final String title;
  final String content;
  NotificationWidget({this.content, this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          SizedBox(
            height: 10,
          ),
          Text(content),
          Divider()
        ],
      ),
    );
  }
}
