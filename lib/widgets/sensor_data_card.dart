import 'package:flutter/material.dart';

class SensorDataCard extends StatelessWidget {
  final String label;
  final double value;

  const SensorDataCard({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Text(
              value.toStringAsFixed(2),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
