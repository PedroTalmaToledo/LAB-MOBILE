import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/pedido.dart';
import '../services/delivery_service.dart';

class RastrearEntregaScreen extends StatefulWidget {
  final Pedido pedido;

  const RastrearEntregaScreen({super.key, required this.pedido});

  @override
  State<RastrearEntregaScreen> createState() => _RastrearEntregaScreenState();
}

class _RastrearEntregaScreenState extends State<RastrearEntregaScreen> {
  GoogleMapController? _mapController;
  List<LatLng> _rota = [];
  LatLng? _origemLatLng;
  LatLng? _destinoLatLng;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarRota();
  }

  Future<void> _carregarRota() async {
    try {
      final rota = await DeliveryService().obterRota(
        widget.pedido.origem,
        widget.pedido.destino,
      );

      if (rota.isEmpty) {
        setState(() {
          _erro = "Rota não encontrada. Aguarde o motorista iniciar a entrega.";
        });
      } else {
        setState(() {
          _rota = rota;
          _origemLatLng = rota.first;
          _destinoLatLng = rota.last;
        });
      }
    } catch (e) {
      setState(() {
        _erro = "Erro ao buscar rota: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rastrear Entrega')),
      body: _erro != null
          ? Center(child: Text(_erro!, textAlign: TextAlign.center))
          : _rota.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _origemLatLng!,
                    zoom: 13,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('rota'),
                      points: _rota,
                      color: Colors.blue,
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
