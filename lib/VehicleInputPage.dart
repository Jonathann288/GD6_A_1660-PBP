// vehicle_input_page.dart
import 'package:flutter/material.dart';
import 'package:gd6_a_1660/database/sql_helper.dart';

class VehicleInputPage extends StatefulWidget {
  const VehicleInputPage({
    super.key,
    this.title,
    this.id,
    this.name,
    this.licensePlate,
  });

  final String? title;
  final String? name;
  final String? licensePlate;
  final int? id;

  @override
  State<VehicleInputPage> createState() => _VehicleInputPageState();
}

class _VehicleInputPageState extends State<VehicleInputPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerLicensePlate = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Populate fields if editing an existing vehicle
    if (widget.id != null) {
      controllerName.text = widget.name ?? '';
      controllerLicensePlate.text = widget.licensePlate ?? '';
    }
  }

  Future<void> saveVehicle() async {
    final name = controllerName.text;
    final licensePlate = controllerLicensePlate.text;

    // Check if we're editing or adding a new vehicle
    if (widget.id == null) {
      // Adding a new vehicle
      await SQLHelper.addVehicle(name, licensePlate);
    } else {
      // Editing an existing vehicle
      await SQLHelper.editVehicle(widget.id!, name, licensePlate);
    }

    Navigator.pop(context); // Close the page after saving
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.title ?? "Add Vehicle"),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controllerName,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Vehicle Name',
                labelStyle: TextStyle(color: Colors.blue),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              cursorColor: Colors.blue,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controllerLicensePlate,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'License Plate',
                labelStyle: TextStyle(color: Colors.blue),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              cursorColor: Colors.blue,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 700, // Set your desired width here
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: saveVehicle,
                child: const Text('Save Vehicle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
