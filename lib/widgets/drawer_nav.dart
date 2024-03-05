import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/page_provider.dart' as page_provider;
import 'package:kp/widgets/drawer_menu.dart';
import 'package:provider/provider.dart';

class DrawerNav extends StatelessWidget {
  final double width;
  final double height;
  DrawerNav({this.width, this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            child: SizedBox(
              height: 40,
              child: Image.asset('images/logo2.png', fit: BoxFit.contain),
            ),
          ),
          Divider(),
          Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage('images/avatar.jpg'),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Text('@${authProvider.serviceProvider.username}');
                    },
                  )
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
              child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Consumer<page_provider.PageProvider>(
                  builder: (context, pageProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DrawerMenu(
                        height: 80,
                        width: double.infinity,
                        selected: pageProvider.getCurrentPage() ==
                            page_provider.Page.DASHBOARD,
                        text: "Dashboard",
                        page: page_provider.Page.DASHBOARD,
                        iconData: Icons.dashboard),
                    DrawerMenu(
                      height: 80,
                      width: double.infinity,
                      selected: pageProvider.getCurrentPage() ==
                          page_provider.Page.PATIENTS,
                      text: "KP Portal",
                      page: page_provider.Page.PATIENTS,
                      iconData: Icons.account_box_outlined,
                    ),
                    // DrawerMenu(
                    //   height: 80,
                    //   width: double.infinity,
                    //   selected: pageProvider.getCurrentPage() ==
                    //       page_provider.Page.LAB,
                    //   text: "Lab reports",
                    //   page: page_provider.Page.LAB,
                    //   imageAsset: "images/flask.png",
                    // ),
                    DrawerMenu(
                      height: 80,
                      width: double.infinity,
                      selected: pageProvider.getCurrentPage() ==
                          page_provider.Page.REGISTRATION,
                      text: "KP Registration",
                      page: page_provider.Page.REGISTRATION,
                      iconData: Icons.app_registration,
                    ),
                    DrawerMenu(
                      height: 80,
                      width: double.infinity,
                      selected: pageProvider.getCurrentPage() ==
                          page_provider.Page.NOTIFICATIONS,
                      text: "Notifications",
                      page: page_provider.Page.NOTIFICATIONS,
                      iconData: Icons.notifications,
                    ),
                    DrawerMenu(
                      height: 80,
                      width: double.infinity,
                      selected: pageProvider.getCurrentPage() ==
                          page_provider.Page.SETTINGS,
                      text: "Settings",
                      page: page_provider.Page.SETTINGS,
                      iconData: Icons.settings,
                    )
                  ],
                );
              })
            ],
          )),
          Divider(),
          ListTile(
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            leading: Icon(Icons.power_settings_new),
            title: Text("Log out"),
          )
        ],
      ),
    );
  }
}
