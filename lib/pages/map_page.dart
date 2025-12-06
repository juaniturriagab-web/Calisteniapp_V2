import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/location_service.dart';
import 'park_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  bool _isMapDark = true;
  String? _darkMapStyle;
  String? _lightMapStyle;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadParks();
    _loadMapStyles();
  }

  Future<void> _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_styles/light.json');
    // Set initial style after loading
    setState(() {});
  }

  Future<void> _loadLocation() async {
    try {
      final position = await getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _loadParks() async {
    final parks = await FirebaseFirestore.instance.collection('parks').get();
    final markers = parks.docs.map((doc) {
      final data = doc.data();
      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(data['lat'], data['lng']),
        infoWindow: InfoWindow(
          title: data['name'],
          snippet: '⭐ ${data['rating']}',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ParkDetailPage(parkId: doc.id),
              ),
            );
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }).toSet();

    setState(() => _markers = markers);
  }

  void _goToCurrentLocation() {
    if (mapController != null && _currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // Default button disabled
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  markers: _markers,
                  style: _isMapDark ? _darkMapStyle : _lightMapStyle,
                ),
                Positioned(
                  top: 40,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      setState(() {
                        _isMapDark = !_isMapDark;
                      });
                    },
                    child: Icon(_isMapDark ? Icons.light_mode : Icons.dark_mode),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 10,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }
}
