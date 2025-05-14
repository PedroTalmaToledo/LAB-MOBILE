import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeCliente extends StatefulWidget {
  const HomeCliente({super.key});

  @override
  State<HomeCliente> createState() => _HomeClienteState();
}

class _HomeClienteState extends State<HomeCliente> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? _currentPosition;

  final LatLng _entregaPosition = LatLng(-23.550520, -46.633308); // Exemplo: SP centro

  @override
  void initState() {
    super.initState();
    _detectarLocalizacao();
  }

  Future<void> _detectarLocalizacao() async {
    Position pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    setState(() {
      _currentPosition = pos;
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(pos.latitude, pos.longitude),
      14,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14,
      ),
      markers: {
        Marker(markerId: MarkerId('user'), position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), infoWindow: InfoWindow(title: 'Você')),
        Marker(markerId: MarkerId('entrega'), position: _entregaPosition, infoWindow: InfoWindow(title: 'Entrega')),
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
