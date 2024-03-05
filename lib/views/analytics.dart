import 'package:flutter/material.dart';
import 'package:kp/api/analytics.dart';
import 'package:kp/models/programs.dart';
import 'package:kp/widgets/metric.dart';
import 'package:kp/widgets/section_header.dart';

class AnalyticsView extends StatefulWidget {
  @override
  State createState() => AnalyticsState();
}

class AnalyticsState extends State<AnalyticsView> {
  List<Program> programs;
  bool fetchingAnalytics = false;

  @override
  void initState() {
    super.initState();
    fetchingAnalytics = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAnalytics();
    });
  }

  Future<void> getAnalytics() async {
    setState(() {
      fetchingAnalytics = true;
      programs = null;
    });
    try {
      List<Program> programs = await AnalyticsApi.getProgramsAnalytics();
      setState(() {
        this.programs = programs;
        fetchingAnalytics = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingAnalytics = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Analytics",
          style: TextStyle(color: Colors.blueAccent),
        ),
      ),
      body: programs == null && fetchingAnalytics == true
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blueAccent))
                ],
              ),
            )
          : programs == null && fetchingAnalytics == false
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        return Colors.blueAccent;
                      })),
                      onPressed: () {
                        getAnalytics();
                      },
                      child:
                          Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          text: "Programs",
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 6 / 3,
                            children: programs.map((program) {
                              return Metric(
                                iconColor: Colors.red,
                                value: program.enrolled.toString(),
                                title: program.code,
                                iconData: Icons.description,
                              );
                            }).toList())
                      ],
                    ),
                  ),
                ),
    );
  }
}
