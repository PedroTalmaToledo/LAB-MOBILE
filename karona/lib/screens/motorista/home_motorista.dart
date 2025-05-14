import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HomeMotorista extends StatefulWidget {
  const HomeMotorista({super.key});

  @override
  State<HomeMotorista> createState() => _HomeMotoristaState();
}

class _HomeMotoristaState extends State<HomeMotorista> {
  Database? _db;
  List<Map<String, dynamic>> _entregasDisponiveis = [];
  bool _carregando = true;

  CameraController? _cameraController;
  CameraDescription? _camera;

  Position? _localizacaoAtual;

  @override
  void initState() {
    super.initState();
    _initTudo();
  }

  Future<void> _initTudo() async {
    await _initDatabase();
    await _carregarEntregasDisponiveis();
    await _initCamera();
  }

  Future<void> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'entregas.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE entregas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT,
            latitude REAL,
            longitude REAL,
            foto TEXT,
            status TEXT DEFAULT 'disponivel' -- 'disponivel', 'aceita', 'concluida'
          )
        ''');
      },
    );
  }

  Future<void> _carregarEntregasDisponiveis() async {
    final entregas = await _db!.query('entregas', where: "status = ?", whereArgs: ['disponivel']);
    setState(() {
      _entregasDisponiveis = entregas;
      _carregando = false;
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _camera = cameras.first;
    _cameraController = CameraController(_camera!, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _aceitarEntrega(BuildContext context, int id) async {
    await _db!.update('entregas', {'status': 'aceita'}, where: 'id = ?', whereArgs: [id]);
    await _carregarEntregasDisponiveis();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrega aceita!')));
  }


  Future<void> _registrarEntrega(BuildContext context, int id) async {
    try {
      _localizacaoAtual = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final foto = await _cameraController!.takePicture();

      await _db!.update('entregas', {
        'status': 'concluida',
        'foto': foto.path,
        'latitude': _localizacaoAtual!.latitude,
        'longitude': _localizacaoAtual!.longitude,
      }, where: 'id = ?', whereArgs: [id]);

      await _carregarEntregasDisponiveis();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrega registrada com sucesso!')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar entrega: $e')));
    }
  }


  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando || _cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Motorista')),
      body: ListView(
        children: [
          ..._entregasDisponiveis.map((e) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(e['descricao'] ?? 'Sem descrição'),
                subtitle: Text('Status: ${e['status']}'),
                trailing: ElevatedButton(
                  onPressed: () => _aceitarEntrega(context, e['id']),
                  child: const Text('Aceitar'),
                ),
              ),
            );
          }),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Entregas aceitas e para registrar:'),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _db!.query('entregas', where: 'status = ?', whereArgs: ['aceita']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final aceitas = snapshot.data!;
              return Column(
                children: aceitas.map((e) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(e['descricao'] ?? 'Sem descrição'),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Registrar'),
                        onPressed: () => _registrarEntrega(context, e['id']),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
