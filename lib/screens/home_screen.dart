import 'package:flutter/material.dart';
import 'accelerometer_screen.dart';
import 'gyroscope_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccelerometerScreen(),
                  ),
                );
              },
              child: Text('Go to Accelerometer'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GyroscopeScreen()),
                );
              },
              child: Text('Go to Gyroscope'),
            ),
          ],
        ),
      ),
    );
  }
}
