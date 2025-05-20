import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import '../database/delivery_database.dart';
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
  List<Map<String, dynamic>> _entregas = [];
  late CameraDescription _camera;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getLocation();
    _carregarEntregasDoBanco();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _camera = cameras.first;
    setState(() => _cameraReady = true);
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = pos);
  }

  Future<void> _carregarEntregasDoBanco() async {
    final entregas = await DeliveryDatabase.listarEntregas();
    final ids = <String>{};
    final filtradas = <Map<String, dynamic>>[];

    for (var e in entregas) {
      final key = '${e['cliente']}_${e['descricao']}';
      if (!ids.contains(key)) {
        ids.add(key);
        filtradas.add(e);
      }
    }

    setState(() {
      _entregas = filtradas.where((e) => e['status'] != 'Entregue').toList();
      _markers = _entregas.map((e) {
        return Marker(
          markerId: MarkerId(e['id'].toString()),
          position: LatLng(e['lat'] ?? _currentPosition?.latitude ?? 0.0,
              e['lng'] ?? _currentPosition?.longitude ?? 0.0),
          infoWindow: InfoWindow(
              title: e['cliente'] as String,
              snippet: e['descricao'] as String),
        );
      }).toSet();
    });
  }

  Future<void> _aceitarEntrega(Map<String, dynamic> entrega) async {
    final atualizado = Map<String, dynamic>.from(entrega);
    atualizado['status'] = 'Saiu para entrega';
    await DeliveryDatabase.salvarEntrega(
      cliente: atualizado['cliente'],
      endereco: atualizado['endereco'],
      descricao: atualizado['descricao'],
      status: atualizado['status'],
      foto: atualizado['foto'],
      data: atualizado['data'],
      localizacao: atualizado['localizacao'],
      lat: atualizado['lat'],
      lng: atualizado['lng'],
    );
    await _carregarEntregasDoBanco();
  }

  Future<void> _finalizarEntrega(Map<String, dynamic> entrega) async {
    if (!_cameraReady) return;

    final foto = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => TakePictureScreen(camera: _camera)),
    );

    if (foto != null) {
      final pos = await Geolocator.getCurrentPosition();
      final atualizado = Map<String, dynamic>.from(entrega);
      atualizado['status'] = 'Entregue';
      atualizado['foto'] = foto.path;
      atualizado['localizacao'] = '${pos.latitude}, ${pos.longitude}';
      atualizado['data'] = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      await DeliveryDatabase.salvarEntrega(
        cliente: atualizado['cliente'],
        endereco: atualizado['endereco'],
        descricao: atualizado['descricao'],
        status: atualizado['status'],
        foto: atualizado['foto'],
        data: atualizado['data'],
        localizacao: atualizado['localizacao'],
        lat: atualizado['lat'],
        lng: atualizado['lng'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega finalizada com sucesso!')),
      );

      await _carregarEntregasDoBanco();
    }
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
            onPressed: () => Navigator.pop(context),
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
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: _entregas.length,
                    itemBuilder: (context, index) {
                      final entrega = _entregas[index];
                      final status = entrega['status'] as String;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(entrega['cliente']),
                          subtitle: Text(
                              '${entrega['descricao']}\nStatus: $status'),
                          isThreeLine: true,
                          trailing: status == 'Pendente'
                              ? TextButton(
                                  onPressed: () => _aceitarEntrega(entrega),
                                  child: const Text('Aceitar'),
                                )
                              : TextButton(
                                  onPressed: () => _finalizarEntrega(entrega),
                                  child: const Text('Finalizar'),
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
