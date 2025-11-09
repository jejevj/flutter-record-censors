import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:async';
import '../widgets/sensor_data_card.dart';

class GyroscopeScreen extends StatefulWidget {
  @override
  _GyroscopeScreenState createState() => _GyroscopeScreenState();
}

class _GyroscopeScreenState extends State<GyroscopeScreen> {
  double _gx = 0, _gy = 0, _gz = 0;
  List<List<dynamic>> _data = []; // List to store gyroscope data
  bool _isRecording = false; // Track if recording is active
  TextEditingController _filenameController = TextEditingController();
  String _selectedLabel = 'diam'; // Default label
  List<String> _labels = [
    'diam',
    'berdiri',
    'jalan',
    'lari',
    'jatuh',
  ]; // List of labels
  List<String> _savedFiles = []; // List to store filenames for saved files

  // Function to start recording data
  void _startRecording() {
    setState(() {
      _isRecording = true;
      _data.clear(); // Clear previous data before starting a new recording
      _data.add([
        'label',
        'gyro_x',
        'gyro_y',
        'gyro_z',
      ]); // Add header with label
    });

    // Start listening to gyroscope events
    gyroscopeEvents.listen((GyroscopeEvent event) {
      if (_isRecording) {
        setState(() {
          _gx = event.x;
          _gy = event.y;
          _gz = event.z;
        });
        _data.add([
          _selectedLabel,
          _gx,
          _gy,
          _gz,
        ]); // Add data with label to the list
      }
    });

    // Automatically stop recording after 7 seconds
    Timer(Duration(seconds: 7), _stopRecording);
  }

  // Function to stop recording data and save it to a file
  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false; // Stop recording
    });

    // Show filename input dialog
    String? filename = await _showFilenameDialog();
    if (filename != null && filename.isNotEmpty) {
      // Save data to CSV if filename is provided
      await _saveDataToCSV(filename);
      // Update the list of saved files
      await _loadSavedFiles();
    } else {
      // If filename is empty, show a message
      _showErrorDialog('Filename cannot be empty.');
    }
  }

  // Function to show the dialog for filename input
  Future<String?> _showFilenameDialog() async {
    String filename = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Filename'),
          content: TextField(
            controller: _filenameController,
            decoration: InputDecoration(hintText: 'Enter filename'),
            onChanged: (value) {
              filename = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, filename);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to save the data to CSV
  Future<void> _saveDataToCSV(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename.csv';

    // Convert data to CSV format
    String csvData = const ListToCsvConverter().convert(_data);

    // Save the CSV file to the documents directory
    File file = File(path);
    await file.writeAsString(csvData);
    print('Data saved to: $path');

    // Show confirmation dialog
    _showSuccessDialog(path);
  }

  // Function to show success dialog
  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Data Saved'),
        content: Text('Gyroscope data saved as CSV file: $path'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to load saved files from the document directory
  Future<void> _loadSavedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory(directory.path);
    final List<FileSystemEntity> files = dir.listSync();

    // Filter for CSV files and update the list of saved files
    setState(() {
      _savedFiles = files
          .where((file) => file.path.endsWith('.csv'))
          .map((file) => file.uri.pathSegments.last)
          .toList();
    });
  }

  // Function to share the file
  Future<void> _shareFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';

    final file = XFile(path, name: filename);

    final shareResult = await Share.shareXFiles(
      [file],
      text: 'Gyroscope data CSV file',
      subject: 'Sensor CSV Data',
      // Optionally define sharePositionOrigin if needed
    );

    if (shareResult.status == ShareResultStatus.success) {
      print('Shared successfully!');
    } else {
      print('Share cancelled or failed: ${shareResult.status}');
    }
  }

  @override
  void initState() {
    super.initState();
    // Load saved files when the screen initializes
    _loadSavedFiles();
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gyroscope Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SensorDataCard(label: 'Gyro X', value: _gx),
            SensorDataCard(label: 'Gyro Y', value: _gy),
            SensorDataCard(label: 'Gyro Z', value: _gz),
            SizedBox(height: 20),
            // Dropdown to select label
            DropdownButton<String>(
              value: _selectedLabel,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLabel = newValue!;
                });
              },
              items: _labels.map<DropdownMenuItem<String>>((String label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording
                  ? null
                  : _startRecording, // Disable button if recording
              child: Text('Start Recording'),
            ),
            SizedBox(height: 40),
            Text('Saved Files:'),
            // Display saved files
            Expanded(
              child: ListView.builder(
                itemCount: _savedFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_savedFiles[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () => _shareFile(_savedFiles[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
