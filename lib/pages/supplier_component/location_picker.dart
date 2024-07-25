import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPicker extends StatefulWidget {
  final String? selectedLocationMap;
  final void Function(String) setLocation;
  const LocationPicker(
      {super.key, this.selectedLocationMap, required this.setLocation});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String? _currentLocation;
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

    String location =
        await _getLocationAddress(position.latitude, position.longitude);
    setState(() {
      _currentLocation = location;
    });

    // Here you can save the location to Firebase Realtime Database
    widget.setLocation(location);
  }

  Future<String> _getLocationAddress(double latitude, double longitude) async {
    setLocaleIdentifier('en');

    final places = await placemarkFromCoordinates(latitude, longitude);

    log(places.length.toString());

    for (var place in places) {
      log(place.toString());
    }

    final localities = <String, int>{};
    final subLocalities = <String, int>{};

    for (var place in places) {
      final local = place.locality;
      final subLocal = place.subLocality;

      if (local != null) {
        localities[local] = (localities[local] ?? 0) + 1;
      }

      if (subLocal != null) {
        subLocalities[subLocal] = (subLocalities[subLocal] ?? 0) + 1;
      }
    }

    String local =
        localities.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    String subLocal =
        subLocalities.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return '$local, $subLocal';
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
