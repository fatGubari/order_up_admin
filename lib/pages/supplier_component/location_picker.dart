import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:order_up/models/location.dart';

class LocationPicker extends StatefulWidget {
  final Location? selectedLocationMap;
  final void Function(double, double) setLocation;
  const LocationPicker(
      {super.key, this.selectedLocationMap, required this.setLocation});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  Location? _currentLocation;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                onTap: _pickLocation,
                decoration: InputDecoration(
                  hintText: _currentLocation?.toString() ?? 'Location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supplier location';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              onPressed: _pickLocation,
              icon: const Icon(Icons.location_on),
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ],
    );
  }

  void _pickLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled.');
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    // Fetch the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation =
          Location(latitude: position.latitude, longitude: position.longitude);
    });

    // Here you can save the location to Firebase Realtime Database
    widget.setLocation(position.latitude, position.longitude);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
