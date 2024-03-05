import 'package:flutter/material.dart';
import 'package:kp/models/client.dart';
import 'package:kp/models/country.dart';
import 'package:kp/models/local_government.dart';
import 'package:kp/models/state.dart';
import 'package:kp/util.dart';
import 'package:kp/widgets/forms/form_template.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:provider/provider.dart';
import 'package:kp/widgets/custom_form_dropdown.dart';

class ContactInfoForm extends StatefulWidget {
  final void Function(
      String phone,
      String altPhone,
      String address,
      KState state,
      LocalGovernment lga,
      Country country,
      String email) onFinished;
  final int stepIndex;
  final int numberOfSteps;
  final bool disableBackButton;
  final bool disableForwardButton;
  final VoidCallback onBack;
  final Client client;
  ContactInfoForm(
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
  State createState() => ContactInfoFormState();
}

class ContactInfoFormState extends State<ContactInfoForm> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController phoneController = TextEditingController();
  TextEditingController altPhoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  List<KState> states;
  List<LocalGovernment> lgas;

  KState selectedState;
  LocalGovernment selectedLGA;
  Country selectedCountry;

  @override
  void initState() {
    phoneController.text =
        widget.client.phone == null ? "" : widget.client.phone;
    altPhoneController.text =
        widget.client.altPhone == null ? "" : widget.client.altPhone;
    addressController.text = widget.client.residentialAddress == null
        ? ""
        : widget.client.residentialAddress;
    selectedState = widget.client.state;
    selectedLGA = widget.client.lga;
    emailController.text =
        widget.client.email == null ? "" : widget.client.email;

    if (widget.client.country != null) {
      selectedCountry = widget.client.country;
      if (widget.client.state != null) {
        selectedState = widget.client.state;
        states = widget.client.country.states;
        if (widget.client.lga != null) {
          selectedLGA = widget.client.lga;
          lgas = widget.client.state.lgas;
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Country> countries = context
        .select((MetadataProvider metaProvider) => metaProvider.countries);

    return FormTemplate(
      onFinished: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        if (formKey.currentState.validate()) {
          widget.onFinished(
              phoneController.text,
              altPhoneController.text,
              addressController.text,
              selectedState,
              selectedLGA,
              selectedCountry,
              emailController.text);
        }
      },
      nextIsSave: false,
      stepIndex: widget.stepIndex,
      numberOfSteps: widget.numberOfSteps,
      disableForwardButton: widget.disableForwardButton,
      disableBackButton: widget.disableBackButton,
      onBack: widget.onBack,
      title: "Contact Information",
      children: [
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: phoneController,
                    onChanged: (val) {
                      widget.client.phone = val;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        labelText: 'Phone Number'),
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: altPhoneController,
                    onChanged: (val) {
                      widget.client.altPhone = val;
                    },
                    validator: (val) {
                      if (val.length > 0) {
                        if (validatePhone(val) == false) {
                          return "Enter a valid Number";
                        }
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        labelText: 'Alt Number'),
                  ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: emailController,
                validator: (val) {
                  if (val.length > 0) {
                    if (validateEmail(val) == false) {
                      return "Enter a valid email";
                    }
                  }

                  return null;
                },
                onChanged: (val) {
                  widget.client.email = val;
                },
                decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    labelText: 'Email'),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                validator: (val) {
                  if (val.length == 0) {
                    return "Can't be empty";
                  }
                  return null;
                },
                onChanged: (val) {
                  widget.client.residentialAddress = val;
                },
                controller: addressController,
                decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    labelText: 'Residential Address'),
              ),
              SizedBox(
                height: 20,
              ),
              CustomFormDropDown<Country>(
                useExternalValue: true,
                value: selectedCountry,
                text: 'Country',
                initialValue: selectedCountry,
                items: countries == null
                    ? null
                    : countries.map((e) {
                        return DropdownMenuItem<Country>(
                            child: Text(e.name), value: e);
                      }).toList(),
                onChanged: (value) {
                  if (selectedCountry.toString() != value.toString()) {
                    setState(() {
                      selectedCountry = value;
                      selectedState = null;
                      states = selectedCountry.states;
                      widget.client.country = selectedCountry;
                    });
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomFormDropDown<KState>(
                      useExternalValue: true,
                      value: selectedState,
                      text: 'State',
                      initialValue: selectedState,
                      items: states == null ||
                              countries == null ||
                              selectedCountry == null
                          ? null
                          : states.map((e) {
                              return DropdownMenuItem<KState>(
                                  child: Text(e.name), value: e);
                            }).toList(),
                      onChanged: (value) {
                        if (selectedState.toString() != value.toString()) {
                          setState(() {
                            selectedState = value;
                            widget.client.state = selectedState;
                            selectedLGA = null;
                            lgas = selectedState.lgas;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: CustomFormDropDown<LocalGovernment>(
                      useExternalValue: true,
                      value: selectedLGA,
                      text: 'LGA',
                      initialValue: selectedLGA,
                      items: selectedState == null ||
                              states == null ||
                              lgas == null
                          ? null
                          : lgas.map((e) {
                              return DropdownMenuItem<LocalGovernment>(
                                  child: Text(e.name), value: e);
                            }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLGA = value;
                          widget.client.lga = selectedLGA;
                        });
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
