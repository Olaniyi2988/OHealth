import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/views/arv_history.dart';
import 'package:kp/views/client_pharmacy_orders.dart';
import 'package:kp/views/patients.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';

class PharmacyOptions extends StatefulWidget {
  @override
  State createState() => PharmacyOptionsState();
}

class PharmacyOptionsState extends State<PharmacyOptions> {
  String selected = "arv_dispensing";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                height: (MediaQuery.of(context).size.height - kToolbarHeight) *
                    0.35,
                color: Colors.blueAccent,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Container()
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                child: SizedBox(
                  height:
                      (MediaQuery.of(context).size.height - kToolbarHeight) *
                          0.8,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Card(
                      child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Expanded(
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
                                  text: "Pharmacy module options",
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                CustomFormDropDown<String>(
                                  text: "",
                                  initialValue: selected,
                                  items: [
                                    DropdownMenuItem<String>(
                                      child: Text("General pharmacy"),
                                      value: "order_form",
                                    ),
                                    DropdownMenuItem<String>(
                                      child: Text("ARV drug dispensing"),
                                      value: "arv_dispensing",
                                    ),
                                    // DropdownMenuItem<String>(
                                    //   child: Text(
                                    //       "Adverse  drug reaction screening"),
                                    //   value: "adr_screening",
                                    // ),
                                    // DropdownMenuItem<String>(
                                    //   child: Text(
                                    //       "Client tracking and termination"),
                                    //   value: "tracking",
                                    // ),
                                    // DropdownMenuItem<String>(
                                    //   child: Text(
                                    //       "Medication and adherence assessment"),
                                    //   value: "assessment",
                                    // ),
                                    // DropdownMenuItem<String>(
                                    //   child: Text(
                                    //       "Tuberculosis prevention therapy"),
                                    //   value: "tb_therapy",
                                    // )
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      selected = val;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            )
                          ],
                        )),
                        Row(
                          children: [
                            Expanded(
                                child: SizedBox(
                              height: 60,
                              child: RaisedButton(
                                  onPressed: () {
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .resetInactivityTimer();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  color: Colors.blueAccent),
                            )),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: SizedBox(
                              height: 60,
                              child: RaisedButton(
                                  onPressed: () async {
                                    if (selected == null) return;
                                    Client client = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                                  appBar: AppBar(
                                                    elevation: 0,
                                                    iconTheme: IconThemeData(
                                                        color:
                                                            Colors.blueAccent),
                                                    title: Text(
                                                      'Select Client',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .blueAccent),
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  body: Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: OnlinePatients(
                                                      isSelect: true,
                                                    ),
                                                  ),
                                                )));
                                    if (client == null) return;
                                    if (selected == "order_form") {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ClientPharmacyHistory(
                                                    client: client,
                                                  )));
                                    } else if (selected == "arv_dispensing") {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ArvHistory(
                                                    client: client,
                                                  )));
                                    }
                                  },
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  color: Colors.blueAccent),
                            ))
                          ],
                        )
                      ],
                    ),
                  )),
                ),
                top: (MediaQuery.of(context).size.height - kToolbarHeight) *
                    0.15,
                left: MediaQuery.of(context).size.width * 0.15 / 2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
