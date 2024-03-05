import 'package:flutter/material.dart';

class SetupSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Image.asset(
              'images/login.jpg',
              fit: BoxFit.cover,
            )),
            Container(
              height: 50,
              child: Center(
                child: Text(
                  'Getting things ready',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            ),
            LinearProgressIndicator(),
            Container(
              height: 50,
              child: Center(
                child: Text(
                  '',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
