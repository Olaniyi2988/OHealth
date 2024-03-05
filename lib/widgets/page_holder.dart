import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/page_provider.dart' as page_provider;
import 'package:kp/util.dart';
import 'package:kp/views/dashboard.dart';
import 'package:kp/views/notifications.dart';
import 'package:kp/views/patients.dart';
import 'package:kp/views/registration.dart';
import 'package:kp/views/settings.dart';
import 'package:kp/widgets/drawer_nav.dart';
import 'package:provider/provider.dart';

class PageHolder extends StatefulWidget {
  @override
  State createState() => PageHolderState();
}

class PageHolderState extends State<PageHolder> {
  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    return WillPopScope(
        child: OrientationBuilder(builder: (context, orientation) {
      return Consumer<page_provider.PageProvider>(
        builder: (context, pageProvider, _) {
          double height = orientation == Orientation.portrait
              ? MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top
              : MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top;
          return Scaffold(
            key: scaffoldKey,
            appBar: orientation == Orientation.landscape
                ? AppBar(
                    toolbarHeight: 0,
                  )
                : AppBar(
                    backgroundColor: Colors.white,
                    title: Text(
                      pageProvider.getCurrentPage() ==
                              page_provider.Page.DASHBOARD
                          ? 'Dashboard'
                          : pageProvider.getCurrentPage() ==
                                  page_provider.Page.PATIENTS
                              ? 'KP Portal'
                              : pageProvider.getCurrentPage() ==
                                      page_provider.Page.LAB
                                  ? 'Lab Report'
                                  : pageProvider.getCurrentPage() ==
                                          page_provider.Page.REGISTRATION
                                      ? 'KP Registration'
                                      : pageProvider.getCurrentPage() ==
                                              page_provider.Page.NOTIFICATIONS
                                          ? 'Notifications'
                                          : pageProvider.getCurrentPage() ==
                                                  page_provider.Page.SETTINGS
                                              ? 'Settings'
                                              : pageProvider.getCurrentPage() ==
                                                      page_provider
                                                          .Page.ANALYTICS
                                                  ? 'Analytics'
                                                  : 'Text',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
            drawer: orientation == Orientation.landscape
                ? null
                : Drawer(
                    child: SafeArea(
                      child: DrawerNav(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: height),
                    ),
                  ),
            body: GestureDetector(
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false)
                    .resetInactivityTimer();
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: LayoutBuilder(
                builder: (context, constraint) {
                  return Consumer<page_provider.PageProvider>(
                    builder: (context, pageProvider, _) {
                      return SafeArea(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Container(
                              color: Colors.white,
                              child: SizedBox(
                                height: height,
                                width: constraint.maxWidth,
                                child: orientation == Orientation.landscape
                                    ? Row(
                                        children: [
                                          Material(
                                            elevation: 3,
                                            child: DrawerNav(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                height: height),
                                          ),
                                          Expanded(
                                              child: pageProvider
                                                          .getCurrentPage() ==
                                                      page_provider
                                                          .Page.DASHBOARD
                                                  ? Dashboard()
                                                  : pageProvider
                                                              .getCurrentPage() ==
                                                          page_provider
                                                              .Page.REGISTRATION
                                                      ? RegistrationView()
                                                      : pageProvider
                                                                  .getCurrentPage() ==
                                                              page_provider
                                                                  .Page.PATIENTS
                                                          ? PatientsView()
                                                          : pageProvider
                                                                      .getCurrentPage() ==
                                                                  page_provider
                                                                      .Page
                                                                      .NOTIFICATIONS
                                                              ? NotificationsView()
                                                              : pageProvider
                                                                          .getCurrentPage() ==
                                                                      page_provider
                                                                          .Page
                                                                          .SETTINGS
                                                                  ? SettingsView()
                                                                  : Container(
                                                                      color: Colors
                                                                              .grey[
                                                                          200]))
                                        ],
                                      )
                                    : pageProvider.getCurrentPage() ==
                                            page_provider.Page.DASHBOARD
                                        ? Dashboard()
                                        : pageProvider.getCurrentPage() ==
                                                page_provider.Page.REGISTRATION
                                            ? RegistrationView()
                                            : pageProvider.getCurrentPage() ==
                                                    page_provider.Page.PATIENTS
                                                ? PatientsView()
                                                : pageProvider
                                                            .getCurrentPage() ==
                                                        page_provider
                                                            .Page.NOTIFICATIONS
                                                    ? NotificationsView()
                                                    : pageProvider
                                                                .getCurrentPage() ==
                                                            page_provider
                                                                .Page.SETTINGS
                                                        ? SettingsView()
                                                        : Container(
                                                            color: Colors
                                                                .grey[200]),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    }), onWillPop: () async {
      if (Provider.of<page_provider.PageProvider>(context, listen: false)
              .canPop() ==
          false) {
        bool val =
            await showBasicConfirmationDialog("Exit Application?", context);
        return val;
      } else {
        Provider.of<page_provider.PageProvider>(context, listen: false)
            .goBack();
        return false;
      }
    });
  }
}
