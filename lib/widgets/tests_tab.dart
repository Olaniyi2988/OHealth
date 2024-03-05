import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/views/client_lab_order.dart';
import 'package:kp/views/lab_order.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TestsTab extends StatefulWidget {
  final Client client;
  TestsTab({this.client});
  @override
  State createState() => TestsTabState();
}

class TestsTabState extends State<TestsTab> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return ResponsiveBuilder(
        builder: (context, info) {
          return Container(
            color: Colors.grey[100],
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SectionHeader(
                            text: 'Tests',
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LabOrder(
                                                client: widget.client,
                                              )));
                                },
                                child: Icon(Icons.add),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(child: ClientLabOrders(widget.client))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
