import 'package:flutter/material.dart';


void main() {
  runApp(CustomerSliderApp());
}

class CustomerSliderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Center(
                child: Text("hey"),
              )
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
              ),
              child: Center(
                child: Text("cool app!"),
              ),
            )
          ],
        )
      ),
    );
  }
}
