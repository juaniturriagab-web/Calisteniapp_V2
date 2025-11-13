import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Activa la ubicación del dispositivo';
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Permiso de ubicación denegado';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Permiso de ubicación denegado permanentemente';
  }

  return await Geolocator.getCurrentPosition();
}
