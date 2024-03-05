import 'package:flutter/material.dart';
import 'package:kp/api/consultation_api.dart';
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/allergy.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/labelled_text_field.dart';
import 'package:kp/widgets/section_header.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_builder/responsive_builder.dart';
import 'dart:async';
import 'dart:convert';

class AllergiesTab extends StatefulWidget {
  final Client client;
  final GlobalKey<AllergiesTabState> key;
  AllergiesTab({this.client, this.key}) : super(key: key);
  @override
  State createState() => AllergiesTabState();
}

List<Allergy> savedAllergies = [];

class AllergiesTabState extends State<AllergiesTab> {
  bool fetchingAllergies;
  List<Allergy> allergies;

  @override
  void initState() {
    super.initState();
    fetchingAllergies = true;
    if (savedAllergies.length > 0) {
      allergies = savedAllergies;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (savedAllergies.length == 0) {
        getAllergies();
      }
    });
  }

  Future<void> getAllergies({String lastGameId}) async {
    print('getting allergies');
    setState(() {
      fetchingAllergies = true;
    });
    try {
      http.Response response = await RequestMiddleWare.makeRequest(
          url: endPointBaseUrl +
              "/listclinicalallergies?client_unique_identifier=${widget.client.hospitalNum}",
          method: RequestMethod.GET);
      print(response.body);
      if (response.statusCode == 200) {
        List allergiesJsons = JsonDecoder().convert(response.body);
        List<Allergy> allergies = allergiesJsons.map((json) {
          return Allergy.fromJson(json);
        }).toList();
        this.allergies = allergies;
        savedAllergies = allergies;
      } else if (response.statusCode == 400) {
        this.allergies = [];
      }
      setState(() {
        fetchingAllergies = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        fetchingAllergies = false;
      });
    }
  }

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
                            text: 'Allergies',
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  allergies = null;
                                  savedAllergies = [];
                                  getAllergies();
                                },
                                child: Icon(Icons.refresh),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  collectAllergy(
                                      context: context,
                                      orientation: orientation,
                                      sizingInfo: info,
                                      client: widget.client);
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
                      allergies == null && fetchingAllergies == true
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : allergies == null && fetchingAllergies == false
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: RaisedButton(
                                      color: Colors.blueAccent,
                                      onPressed: () {
                                        getAllergies();
                                      },
                                      child: Text('Retry',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                )
                              : allergies.length == 0
                                  ? Center(
                                      child: Container(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              "Nothing to see here yet",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: ListView.builder(
                                      itemBuilder: (context, count) {
                                        return Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                child: SectionHeader(
                                                  text: "",
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(""),
                                                subtitle: Text(""),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: allergies.length,
                                      physics: BouncingScrollPhysics(),
                                    ))
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

void collectAllergy(
    {BuildContext context,
    Orientation orientation,
    SizingInformation sizingInfo,
    Client client}) {
  KpMetaData typeOfAllergy;
  KpMetaData allergens;
  // KpMetaData reactions;
  // KpMetaData conditions;
  KpMetaData severity;
  TextEditingController observationController = TextEditingController();
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: SectionHeader(
            text: 'Add Allergy',
          ),
          insetPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(10),
          content: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ListView(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Consumer<MetadataProvider>(
                    builder: (context, metaProvider, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...splitToChunks([
                            CustomFormDropDown<KpMetaData>(
                              text: 'Type of Allergy',
                              // iconData: Icons.family_restroom_outlined,
                              items: metaProvider
                                          .genericMetaData['allergies'] ==
                                      null
                                  ? null
                                  : metaProvider.genericMetaData['allergies']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                              onChanged: (value) {
                                typeOfAllergy = value;
                              },
                            ),
                            CustomFormDropDown<KpMetaData>(
                              text: 'Allergens',
                              // iconData: Icons.family_restroom_outlined,
                              items: metaProvider
                                          .genericMetaData['allergens'] ==
                                      null
                                  ? null
                                  : metaProvider.genericMetaData['allergens']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                              onChanged: (value) {
                                allergens = value;
                              },
                            ),
                            // CustomFormDropDown<KpMetaData>(
                            //   text: 'Reactions/Symptoms',
                            //   // iconData: Icons.family_restroom_outlined,
                            //   items: metaProvider
                            //               .genericMetaData['allergens'] ==
                            //           null
                            //       ? null
                            //       : metaProvider.genericMetaData['allergens']
                            //           .map((e) {
                            //           return DropdownMenuItem<KpMetaData>(
                            //               child: Text(e.name), value: e);
                            //         }).toList(),
                            //   onChanged: (value) {
                            //     reactions = value;
                            //   },
                            // ),
                            // CustomFormDropDown<KpMetaData>(
                            //   text: 'Conditions',
                            //   // iconData: Icons.family_restroom_outlined,
                            //   items: metaProvider
                            //               .genericMetaData['allergens'] ==
                            //           null
                            //       ? null
                            //       : metaProvider.genericMetaData['allergens']
                            //           .map((e) {
                            //           return DropdownMenuItem<KpMetaData>(
                            //               child: Text(e.name), value: e);
                            //         }).toList(),
                            //   onChanged: (value) {
                            //     conditions = value;
                            //   },
                            // ),
                            CustomFormDropDown<KpMetaData>(
                              text: 'Severity',
                              iconData: Icons.family_restroom_outlined,
                              initialValue: severity,
                              items: metaProvider.genericMetaData['severity'] ==
                                      null
                                  ? null
                                  : metaProvider.genericMetaData['severity']
                                      .map((e) {
                                      return DropdownMenuItem<KpMetaData>(
                                          child: Text(e.name), value: e);
                                    }).toList(),
                              onChanged: (value) {
                                severity = value;
                              },
                            ),
                            LabeledTextField(
                              text: 'Observation',
                              controller: observationController,
                            ),
                          ], sizingInfo.isMobile ? 2 : 3)
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          actions: [
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blueAccent,
            ),
            RaisedButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());

                if (typeOfAllergy == null ||
                    allergens == null ||
                    // reactions == null ||
                    // conditions == null ||
                    observationController.text == '' ||
                    severity == null) {
                  return showBasicMessageDialog("Enter empty fields", context);
                }

                showPersistentLoadingIndicator(context);
                ConsultationApi.postClinicalAllergies(client, {
                  'allergy_id': typeOfAllergy.id,
                  'client_unique_identifier': client.hospitalNum,
                  'allergen_id': allergens.id,
                  'observation': observationController.text,
                  'severity_id': severity.id,
                  'created_date': DateTime.now().toIso8601String(),
                  'created_by':
                      Provider.of<AuthProvider>(context, listen: false)
                          .serviceProvider
                          .userId,
                }).then((val) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // getDiagnosis();
                  // showBasicMessageDialog("Diagnosis saved", context);
                }).catchError((err) {
                  Navigator.pop(context);
                  showBasicMessageDialog(err.toString(), context);
                });
              },
              child: Text(
                'ADD',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blueAccent,
            ),
          ],
          // contentPadding: EdgeInsets.zero,
        );
      });
}
