import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/pedido.dart';
import '../services/tracking_service.dart';

class RastrearEntregaScreen extends StatefulWidget {
  final Pedido pedido;

  const RastrearEntregaScreen({super.key, required this.pedido});

  @override
  State<RastrearEntregaScreen> createState() => _RastrearEntregaScreenState();
}

class _RastrearEntregaScreenState extends State<RastrearEntregaScreen> {
  GoogleMapController? _mapController;
  LatLng? _ultimaPosicao;
  Marker? _markerMotorista;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _buscarUltimaLocalizacao();
    _iniciarAtualizacaoPeriodica();
  }

  void _iniciarAtualizacaoPeriodica() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _buscarUltimaLocalizacao();
      }
    });
  }

  Future<void> _buscarUltimaLocalizacao() async {
    try {
      final dados = await TrackingService().buscarUltimaLocalizacao(widget.pedido.id.toString());

      if (dados != null &&
          dados.containsKey('location') &&
          dados['location'].containsKey('coordinates')) {
        final coords = dados['location']['coordinates'];
        final double lng = double.tryParse(coords[0].toString()) ?? 0.0;
        final double lat = double.tryParse(coords[1].toString()) ?? 0.0;

        if (lat != 0.0 && lng != 0.0) {
          final novaPosicao = LatLng(lat, lng);

          setState(() {
            _ultimaPosicao = novaPosicao;
            _markerMotorista = Marker(
              markerId: const MarkerId('motorista'),
              position: novaPosicao,
              infoWindow: const InfoWindow(title: 'Motorista em rota'),
            );
          });

          _mapController?.animateCamera(
            CameraUpdate.newLatLng(novaPosicao),
          );
        }
      }
    } catch (e) {
      print("❌ Erro ao buscar localização: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rastreamento da Entrega"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar agora',
            onPressed: _buscarUltimaLocalizacao,
          )
        ],
      ),
      body: _ultimaPosicao == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _ultimaPosicao!,
                zoom: 16,
              ),
              markers: _markerMotorista != null ? {_markerMotorista!} : {},
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: false,
            ),
    );
  }
}
