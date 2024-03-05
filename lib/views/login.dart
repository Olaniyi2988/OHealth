import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;

  void login(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false)
          .login(userNameController.text.trim(), passwordController.text.trim())
            ..catchError((err) {
              setState(() {
                isLoading = false;
              });
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(err.toString() + ". Try again"),
                      actions: [
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'OKAY',
                              style: TextStyle(color: Colors.blueAccent),
                            ))
                      ],
                    );
                  });
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: EdgeInsets.zero,
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ResponsiveBuilder(
                builder: (context, sizing) {
                  return Form(
                    key: formKey,
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        if (orientation == Orientation.landscape) {
                          return Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width * 0.5,
                                color: Colors.white,
                                child: Image.asset(
                                  'images/login.jpg',
                                  fit: BoxFit.cover,
                                  colorBlendMode: BlendMode.hue,
                                  color: Colors.blue[200],
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width * 0.5,
                                color: Colors.white,
                                child: Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      children: [
                                        Card(
                                          color: Colors.white,
                                          elevation: 4,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 30,
                                                  right: 30,
                                                  top: 30,
                                                  bottom: 30),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                      'images/logo2.png'),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  Text(
                                                    'Sign in',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blueAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 40),
                                                  ),
                                                  TextFormField(
                                                    controller:
                                                        userNameController,
                                                    validator: (value) {
                                                      if (value.length == 0) {
                                                        return "Can't be empty";
                                                      }
                                                      return null;
                                                    },
                                                    decoration: InputDecoration(
                                                        labelText: "Username"),
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  TextFormField(
                                                    controller:
                                                        passwordController,
                                                    validator: (value) {
                                                      if (value.length == 0) {
                                                        return "Can't be empty";
                                                      }
                                                      return null;
                                                    },
                                                    decoration: InputDecoration(
                                                        labelText: "Password"),
                                                    obscureText: true,
                                                  ),
                                                  Consumer<AuthProvider>(
                                                    builder: (context,
                                                        authProvider, _) {
                                                      if (authProvider
                                                                  .canCheckBiometrics ==
                                                              false ||
                                                          authProvider
                                                                  .serviceProvider ==
                                                              null ||
                                                          authProvider
                                                                  .authToken ==
                                                              null) {
                                                        return Container();
                                                      }
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Center(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                authProvider
                                                                    .loginWithFingerPrint();
                                                              },
                                                              child: Icon(
                                                                  Icons
                                                                      .fingerprint,
                                                                  size: 50),
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    height: 70,
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        login(context);
                                                      },
                                                      child: isLoading == true
                                                          ? Center(
                                                              child: SizedBox(
                                                                height: 25,
                                                                width: 25,
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                            )
                                                          : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  'Login',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  width: 15,
                                                                ),
                                                                Icon(
                                                                  Icons.login,
                                                                  size: 30,
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              ],
                                                            ),
                                                      color: Colors.greenAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                // height: MediaQuery.of(context).size.height * 0.4,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.white,
                                child: Image.asset(
                                  'images/login.jpg',
                                  fit: BoxFit.fitWidth,
                                  colorBlendMode: BlendMode.modulate,
                                  color: Colors.blue[200],
                                ),
                              ),
                            ),
                            Positioned(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      children: [
                                        Card(
                                          color: Colors.white,
                                          elevation: 1,
                                          child: SizedBox(
                                            // height: 500,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: 80,
                                                  bottom: 80,
                                                  left: 30,
                                                  right: 30),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Sign in',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.blueAccent,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 40),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value.length == 0) {
                                                        return "Can't be empty";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        userNameController,
                                                    decoration: InputDecoration(
                                                        labelText: "Username"),
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value.length == 0) {
                                                        return "Can't be empty";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        passwordController,
                                                    decoration: InputDecoration(
                                                        labelText: "Password"),
                                                    obscureText: true,
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Consumer<AuthProvider>(
                                          builder: (context, authProvider, _) {
                                            if (authProvider
                                                        .canCheckBiometrics ==
                                                    false ||
                                                authProvider.serviceProvider ==
                                                    null ||
                                                authProvider.authToken ==
                                                    null) {
                                              return Container();
                                            }
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Center(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      authProvider
                                                          .loginWithFingerPrint();
                                                    },
                                                    child: Icon(
                                                        Icons.fingerprint,
                                                        size: 50),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 30),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            height: 70,
                                            child: RaisedButton(
                                              onPressed: () {
                                                login(context);
                                              },
                                              child: isLoading == true
                                                  ? Center(
                                                      child: SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Login',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 15,
                                                        ),
                                                        Icon(
                                                          Icons.login,
                                                          size: 30,
                                                          color: Colors.white,
                                                        )
                                                      ],
                                                    ),
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Image.asset('images/logo2.png'),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              top: MediaQuery.of(context).size.height * 0.16,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              )),
        ),
      ],
    ));
  }
}
