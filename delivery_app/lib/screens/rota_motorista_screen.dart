import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/pedido.dart';
import '../services/delivery_service.dart';

class RotaMotoristaScreen extends StatefulWidget {
  final Pedido pedido;

  const RotaMotoristaScreen({super.key, required this.pedido});

  @override
  State<RotaMotoristaScreen> createState() => _RotaMotoristaScreenState();
}

class _RotaMotoristaScreenState extends State<RotaMotoristaScreen> {
  GoogleMapController? _mapController;
  List<LatLng> _rota = [];
  LatLng? _origemLatLng;
  LatLng? _destinoLatLng;

  @override
  void initState() {
    super.initState();
    _carregarRota();
  }

  Future<void> _carregarRota() async {
    final rota = await DeliveryService().obterRota(
      widget.pedido.origem,
      widget.pedido.destino,
    );

    setState(() {
      _rota = rota;
      if (_rota.isNotEmpty) {
        _origemLatLng = _rota.first;
        _destinoLatLng = _rota.last;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rota da Entrega')),
      body: _rota.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _origemLatLng!,
                zoom: 13,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('rota_motorista'),
                  points: _rota,
                  color: Colors.green,
                  width: 5,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('origem'),
                  position: _origemLatLng!,
                  infoWindow: const InfoWindow(title: 'Origem'),
                ),
                Marker(
                  markerId: const MarkerId('destino'),
                  position: _destinoLatLng!,
                  infoWindow: const InfoWindow(title: 'Destino'),
                ),
              },
              onMapCreated: (controller) => _mapController = controller,
            ),
    );
  }
}
