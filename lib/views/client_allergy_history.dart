import 'package:flutter/material.dart';
import 'package:kp/api/consultation_api.dart';
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

class ClientAllergyHistory extends StatefulWidget {
  final Client client;
  ClientAllergyHistory(this.client);
  @override
  State createState() => ClientAllergyHistoryState();
}

class ClientAllergyHistoryState extends State<ClientAllergyHistory> {
  List<Allergy> allergies;
  bool fetchingAllergies = false;
  List<String> requiredMetadata = ['allergies', 'allergens', 'severity'];

  @override
  void initState() {
    super.initState();
    fetchingAllergies = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllergies();
    });
  }

  Future<void> getAllergies() async {
    setState(() {
      fetchingAllergies = true;
      allergies = null;
    });
    try {
      List<Allergy> allergies =
          await ConsultationApi.listAllergies(widget.client.hospitalNum);
      setState(() {
        this.allergies = allergies;
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var response = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  insetPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  content: AddAllergyDialog(client: widget.client),
                );
              });
          if (response != null) {
            getAllergies();
          }
        },
      ),
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
                          widget.client.hospitalNum,
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
                child: Column(
                  children: [
                    Expanded(
                        child: Card(
                            child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            text: "Allergies",
                          ),
                          Expanded(
                              child: (allergies == null &&
                                          fetchingAllergies == true) ||
                                      checkAllMetaDataAvailable(
                                              requiredMetadata, context) ==
                                          false
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(Colors.blueAccent))
                                        ],
                                      ),
                                    )
                                  : allergies == null &&
                                          fetchingAllergies == false
                                      ? Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 0),
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                              (states) {
                                                return Colors.blueAccent;
                                              })),
                                              onPressed: () {
                                                getAllergies();
                                              },
                                              child: Text('Retry',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: allergies.length,
                                          itemBuilder: (context, count) {
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: ListTile(
                                                      title: Text("Allergy"),
                                                      subtitle: Text(
                                                          findMetaDataFromId(
                                                                  "allergies",
                                                                  allergies[
                                                                          count]
                                                                      .allergyId,
                                                                  context)
                                                              .name),
                                                    )),
                                                    Expanded(
                                                        child: ListTile(
                                                      title: Text("Allergens"),
                                                      subtitle: Text(
                                                          findMetaDataFromId(
                                                                  "allergens",
                                                                  allergies[
                                                                          count]
                                                                      .allergenId,
                                                                  context)
                                                              .name),
                                                    )),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: ListTile(
                                                      title:
                                                          Text("Observation"),
                                                      subtitle: Text(
                                                          allergies[count]
                                                              .observation),
                                                    )),
                                                    Expanded(
                                                        child: ListTile(
                                                      title: Text("Severity"),
                                                      subtitle: Text(
                                                          findMetaDataFromId(
                                                                  "severity",
                                                                  allergies[
                                                                          count]
                                                                      .severityId,
                                                                  context)
                                                              .name),
                                                    )),
                                                  ],
                                                ),
                                                Divider()
                                              ],
                                            );
                                          }))
                        ],
                      ),
                    )))
                  ],
                ),
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

class AddAllergyDialog extends StatefulWidget {
  final Client client;
  AddAllergyDialog({this.client});
  @override
  _AddAllergyDialogState createState() => _AddAllergyDialogState();
}

class _AddAllergyDialogState extends State<AddAllergyDialog> {
  KpMetaData typeOfAllergy;
  KpMetaData allergens;
  // KpMetaData reactions;
  // KpMetaData conditions;
  KpMetaData severity;
  TextEditingController observationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    MetadataProvider metaProvider = Provider.of(context, listen: true);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomFormDropDown<KpMetaData>(
                text: 'Type of Allergy',
                // iconData: Icons.family_restroom_outlined,
                items: metaProvider.genericMetaData['allergies'] == null
                    ? null
                    : metaProvider.genericMetaData['allergies'].map((e) {
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
                items: metaProvider.genericMetaData['allergens'] == null
                    ? null
                    : metaProvider.genericMetaData['allergens'].map((e) {
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
                items: metaProvider.genericMetaData['severity'] == null
                    ? null
                    : metaProvider.genericMetaData['severity'].map((e) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RaisedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blueAccent,
                  ),
                  SizedBox(
                    width: 15,
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
                        return showBasicMessageDialog(
                            "Enter empty fields", context);
                      }

                      showPersistentLoadingIndicator(context);
                      ConsultationApi.postClinicalAllergies(widget.client, {
                        'allergy_id': typeOfAllergy.id,
                        'client_unique_identifier': widget.client.hospitalNum,
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
                        Navigator.pop(context, true);
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
