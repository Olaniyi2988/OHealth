import 'package:flutter/material.dart';
import 'package:kp/models/programs.dart';
import 'package:kp/views/programs.dart';
import 'package:kp/widgets/section_header.dart';

class ProgramsMenu extends StatefulWidget {
  final List<Program> programs;
  final String clientUniqueIdentifier;
  ProgramsMenu({this.programs, this.clientUniqueIdentifier});
  @override
  State createState() => ProgramsMenuState();
}

class ProgramsMenuState extends State<ProgramsMenu> {
  @override
  void initState() {
    widget.programs.sort((a, b) {
      return a.programId.compareTo(b.programId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              height:
                  (MediaQuery.of(context).size.height - kToolbarHeight) * 0.35,
              color: Colors.blueAccent,
              child: SafeArea(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                        ),
                        Text(
                          widget.clientUniqueIdentifier,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
              ),
            ),
            Positioned(
              child: SizedBox(
                height:
                    (MediaQuery.of(context).size.height - kToolbarHeight) * 0.8,
                width: MediaQuery.of(context).size.width * 0.85,
                child: Card(
                    child: Padding(
                  padding: EdgeInsets.all(15),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            text: "Programs and Services",
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ListTile(
                            title: Text("View data"),
                            leading: Icon(Icons.remove_red_eye_outlined),
                            trailing: Icon(Icons.arrow_forward_ios_rounded),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProgramsView(
                                            programs: widget.programs,
                                            clientUniqueIdentifier:
                                                widget.clientUniqueIdentifier,
                                            viewMode: true,
                                          )));
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text("Add service data"),
                            leading: Icon(Icons.wysiwyg_outlined),
                            trailing: Icon(Icons.arrow_forward_ios_rounded),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProgramsView(
                                            programs: widget.programs,
                                            clientUniqueIdentifier:
                                                widget.clientUniqueIdentifier,
                                          )));
                            },
                          ),
                          Divider(),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      )
                    ],
                  ),
                )),
              ),
              top: (MediaQuery.of(context).size.height - kToolbarHeight) * 0.15,
              left: MediaQuery.of(context).size.width * 0.15 / 2,
            )
          ],
        ),
      ),
    );
  }
}
