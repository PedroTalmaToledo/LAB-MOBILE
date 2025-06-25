import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../models/pedido.dart';
import '../services/delivery_service.dart';
import '../services/tracking_service.dart';
import '../services/notification_service.dart';
import 'take_picture_screen.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<Pedido> _entregas = [];
  late CameraDescription _camera;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getLocation();
    _carregarPedidos();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _camera = cameras.first;
      setState(() => _cameraReady = true);
    } catch (e) {
      debugPrint('Erro ao inicializar a câmera: $e');
    }
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackbar('Permissão de localização negada.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnackbar('Permissão de localização negada permanentemente.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = pos);
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    }
  }

  Future<void> _carregarPedidos() async {
    try {
      final todos = await DeliveryService().listarPedidos();
      final ativos = todos
          .where((p) => p.status != 'ENTREGUE' && p.status != 'CANCELADO')
          .toList();

      setState(() {
        _entregas = ativos;
        _markers = ativos.map((p) {
          return Marker(
            markerId: MarkerId(p.id.toString()),
            position: LatLng(_currentPosition?.latitude ?? 0.0,
                _currentPosition?.longitude ?? 0.0),
            infoWindow:
                InfoWindow(title: p.cliente, snippet: p.tipoMercadoria),
          );
        }).toSet();
      });
    } catch (e) {
      debugPrint('Erro ao carregar pedidos: $e');
      _showSnackbar('Erro ao carregar pedidos.');
    }
  }

  Future<void> _aceitarEntrega(Pedido pedido) async {
    try {
      final pos = await Geolocator.getCurrentPosition();

      // Envia localização para o tracking
      await TrackingService().enviarLocalizacao(
        deliveryId: pedido.id.toString(),
        driverId: 'motorista_demo',
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      // Atualiza status para EM_PROCESSAMENTO
      await DeliveryService().atualizarStatus(pedido.id!, 'EM_PROCESSAMENTO');
      _showSnackbar('Entrega de ${pedido.cliente} aceita.');

      // Obter rota otimizada
      final pontos = await DeliveryService().obterRota(
        pedido.origem,
        pedido.destino,
        pedido.id!,
      );
      print("$pontos/TESTEEEEEEE");

      if (pontos.isNotEmpty) {
        // Criar polyline da rota
        final polyline = Polyline(
          polylineId: PolylineId("rota_${pedido.id}"),
          color: Colors.blue,
          width: 4,
          points: pontos,
        );

        // Marcadores de origem e destino
        final origemCoords = pontos.first;
        final destinoCoords = pontos.last;

        final origemMarker = Marker(
          markerId: MarkerId("origem_${pedido.id}"),
          position: origemCoords,
          infoWindow: InfoWindow(title: 'Origem'),
        );

        final destinoMarker = Marker(
          markerId: MarkerId("destino_${pedido.id}"),
          position: destinoCoords,
          infoWindow: InfoWindow(title: 'Destino'),
        );

        setState(() {
          _polylines = {polyline};
          _markers = {origemMarker, destinoMarker};
        });

        // Centraliza o mapa entre os dois pontos
        final bounds = LatLngBounds(
          southwest: LatLng(
            origemCoords.latitude < destinoCoords.latitude
                ? origemCoords.latitude
                : destinoCoords.latitude,
            origemCoords.longitude < destinoCoords.longitude
                ? origemCoords.longitude
                : destinoCoords.longitude,
          ),
          northeast: LatLng(
            origemCoords.latitude > destinoCoords.latitude
                ? origemCoords.latitude
                : destinoCoords.latitude,
            origemCoords.longitude > destinoCoords.longitude
                ? origemCoords.longitude
                : destinoCoords.longitude,
          ),
        );

        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80),
        );
      }

      await _carregarPedidos();
    } catch (e) {
      print(e);
      _showSnackbar('Erro ao aceitar entrega: $e');
    }
  }

  Future<void> _finalizarEntrega(Pedido pedido) async {
    if (!_cameraReady) {
      _showSnackbar('Câmera ainda não está pronta.');
      return;
    }

    final notificacoes =
        Provider.of<NotificationService>(context, listen: false);

    final foto = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => TakePictureScreen(camera: _camera)),
    );

    if (foto != null) {
      try {
        final pos = await Geolocator.getCurrentPosition();
        await TrackingService().enviarLocalizacao(
          deliveryId: pedido.id.toString(),
          driverId: 'motorista_demo',
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        await DeliveryService().atualizarStatus(pedido.id!, 'ENTREGUE');

        notificacoes.mostrar('Entrega para ${pedido.cliente} foi concluída.');
        _showSnackbar('Entrega finalizada com sucesso!');
        await _carregarPedidos();
      } catch (e) {
        _showSnackbar('Erro ao finalizar entrega: $e');
      }
    }
  }

  void _showSnackbar(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Motorista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/entregues'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    markers: _markers,
                    polylines: _polylines,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: _entregas.length,
                    itemBuilder: (context, index) {
                      final entrega = _entregas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(entrega.cliente),
                          subtitle: Text(
                              '${entrega.tipoMercadoria}\nStatus: ${entrega.status}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (entrega.status == 'ENVIADO')
                                TextButton(
                                  onPressed: () => _aceitarEntrega(entrega),
                                  child: const Text('Aceitar'),
                                ),
                              if (entrega.status == 'EM_PROCESSAMENTO')
                                TextButton(
                                  onPressed: () =>
                                      _finalizarEntrega(entrega),
                                  child: const Text('Finalizar'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
