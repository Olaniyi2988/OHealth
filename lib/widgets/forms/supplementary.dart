import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/metadata.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';
import 'package:kp/widgets/forms/form_template.dart';
import 'package:kp/widgets/hierarchy_display.dart';
import 'package:provider/provider.dart';

class OtherInfoForm extends StatefulWidget {
  final VoidCallback onBack;
  final int stepIndex;
  final int numberOfSteps;
  final bool disableBackButton;
  final bool disableForwardButton;
  final Client client;
  final void Function(
      KpMetaData disability,
      KpMetaData targetGroup,
      KpMetaData careEntrypoint,
      KpMetaData priorArt,
      KpMetaData referredFrom,
      String facilityPath,
      int facilityId) onFinished;
  OtherInfoForm(
      {this.stepIndex,
      this.onFinished,
      this.numberOfSteps,
      this.onBack,
      this.disableBackButton,
      this.disableForwardButton,
      this.client}) {
    assert(client != null);
  }
  @override
  State createState() => OtherInfoFormState();
}

class OtherInfoFormState extends State<OtherInfoForm> {
  KpMetaData disability;
  KpMetaData targetGroup;
  KpMetaData careEntryPoint;
  KpMetaData priorArt;
  KpMetaData referredFrom;
  String facilityPath;
  int facilityId;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    disability = widget.client.disability;
    targetGroup = widget.client.targetGroup;
    careEntryPoint = widget.client.careEntryPoint;
    priorArt = widget.client.priorArt;
    referredFrom = widget.client.referredFrom;
    facilityPath = widget.client.facilityPath;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MetadataProvider metaProvider =
        Provider.of<MetadataProvider>(context, listen: true);
    return FormTemplate(
      stepIndex: widget.stepIndex,
      onFinished: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        if (formKey.currentState.validate()) {
          if ((disability == null &&
                  metaProvider.genericMetaData['disabilities'] != null) ||
              (targetGroup == null &&
                  metaProvider.genericMetaData['tragetgroups'] != null) ||
              (careEntryPoint == null &&
                  metaProvider.genericMetaData['careentrypoint'] != null) ||
              (priorArt == null &&
                  metaProvider.genericMetaData['priorart'] != null) ||
              (referredFrom == null && referredFrom != null) ||
              facilityPath == null) {
            return showBasicMessageDialog(
                'Fill out the missing details', context);
          }
          if (widget.onFinished != null) {
            widget.onFinished(disability, targetGroup, careEntryPoint, priorArt,
                referredFrom, facilityPath, facilityId);
          }
        }
      },
      nextIsSave: false,
      numberOfSteps: widget.numberOfSteps,
      disableBackButton: widget.disableBackButton,
      disableForwardButton: widget.disableForwardButton,
      onBack: widget.onBack,
      title: 'Hospital Information',
      children: [
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10,
              ),
              HierarchyDisplay(
                initialPath: facilityPath,
                initialName: widget.client.facilityName,
                onChanged: (path, name, unitId) {
                  facilityPath = path;
                  facilityId = unitId;
                  widget.client.facilityPath = facilityPath;
                  widget.client.facilityName = name;
                  widget.client.facilityId = unitId;
                  print(unitId);
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Disability',
                iconData: Icons.wheelchair_pickup,
                initialValue: disability,
                items: metaProvider.genericMetaData['disabilities'] == null
                    ? null
                    : metaProvider.genericMetaData['disabilities'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  disability = value;
                  widget.client.disability = disability;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                text: 'Target Group',
                iconData: Icons.group,
                initialValue: targetGroup,
                items: metaProvider.genericMetaData['targetgroups'] == null
                    ? null
                    : metaProvider.genericMetaData['targetgroups'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  targetGroup = value;
                  widget.client.targetGroup = targetGroup;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                initialValue: careEntryPoint,
                text: 'Care Entry Point',
                iconData: Icons.local_hospital_outlined,
                items: metaProvider.genericMetaData['careentrypoint'] == null
                    ? null
                    : metaProvider.genericMetaData['careentrypoint'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  careEntryPoint = value;
                  widget.client.careEntryPoint = careEntryPoint;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                initialValue: priorArt,
                text: 'Prior Art',
                iconData: Icons.wysiwyg,
                items: metaProvider.genericMetaData['priorart'] == null
                    ? null
                    : metaProvider.genericMetaData['priorart'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  priorArt = value;
                  print(priorArt.toJson());
                  widget.client.priorArt = priorArt;
                },
              ),
              SizedBox(
                height: 25,
              ),
              CustomFormDropDown<KpMetaData>(
                initialValue: referredFrom,
                text: 'Referred From',
                iconData: Icons.add_link,
                items: metaProvider.genericMetaData['referredfrom'] == null
                    ? null
                    : metaProvider.genericMetaData['referredfrom'].map((e) {
                        return DropdownMenuItem<KpMetaData>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  referredFrom = value;
                  widget.client.referredFrom = referredFrom;
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
