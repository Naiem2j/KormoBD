import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  const MapPicker({super.key, this.initialLatitude, this.initialLongitude});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _picked;
  static final _default = LatLng(23.8103, 90.4125); // Dhaka fallback

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _picked = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      _determinePosition()
          .then((pos) {
            if (mounted) {
              final latlng = LatLng(pos.latitude, pos.longitude);
              setState(() {
                _picked = latlng;
              });
              _moveCamera(latlng);
            }
          })
          .catchError((_) {
            // ignore
          });
    }
  }

  Future<void> _moveCamera(LatLng p) async {
    final c = await _controller.future;
    c.animateCamera(CameraUpdate.newLatLngZoom(p, 15));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final initial = _picked ?? _default;
    return Scaffold(
      appBar: AppBar(title: const Text('Pick location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initial, zoom: 12),
            myLocationEnabled: true,
            onMapCreated: (c) => _controller.complete(c),
            onTap: (p) {
              setState(() {
                _picked = p;
              });
            },
            markers: _picked == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: _picked!,
                    ),
                  },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _picked == null
                        ? null
                        : () {
                            Navigator.of(context).pop({
                              'latitude': _picked!.latitude,
                              'longitude': _picked!.longitude,
                            });
                          },
                    child: const Text('Confirm location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
