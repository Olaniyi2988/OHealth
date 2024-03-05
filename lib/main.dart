import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kp/models/client.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:kp/providers/meta_provider.dart';
import 'package:kp/providers/page_provider.dart';
import 'package:kp/views/login.dart';
import 'package:kp/views/client_dashboard.dart';
import 'package:kp/views/setup_splash_screen.dart';
import 'package:kp/widgets/forms/finger_capture.dart';
import 'package:kp/widgets/page_holder.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PageProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => MetadataProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Key Population',
      theme: Theme.of(context).copyWith(
        primaryColor: Colors.blueAccent,
        primaryIconTheme: IconTheme.of(context).copyWith(
          color: Colors.blueAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        'test': (context) => Scaffold(
              body: FingerCaptureForm(
                client: Client(),
                stepIndex: 1,
                numberOfSteps: 1,
              ),
            ),
        'home': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                // return TempView();
                if (authProvider.isFetchingCredentials == true ||
                    authProvider.canCheckBiometrics == null) {
                  //TODO to be replaced with a spalsh screen
                  return Container(
                    color: Colors.white,
                  );
                }
                if (authProvider.authState == AuthState.LOGGED_OUT) {
                  return LoginPage();
                }

                authProvider.setContext(context);
                authProvider.resetInactivityTimer();

                return PageHolder();
                return Consumer<MetadataProvider>(
                  builder: (context, metaProvider, _) {
                    if (metaProvider.allMetadataAvailable() == false) {
                      return SetupSplashScreen();
                    }
                    return PageHolder();
                  },
                );
              },
            ),
        'patient_details': (context) => ClientDashboard()
      },
      initialRoute: 'home',
    );
  }
}
