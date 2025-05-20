import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DeliveryDatabase {
  static Database? _db;

  static const String _criarTabelaSQL = '''
    CREATE TABLE entregas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente TEXT,
      endereco TEXT,
      descricao TEXT,
      status TEXT,
      foto TEXT,
      data TEXT,
      localizacao TEXT,
      lat REAL,
      lng REAL
    )
  ''';

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'entregas.db');

    _db = await openDatabase(
      path,
      version: 3, // Atualize a versão sempre que quiser forçar a recriação
      onCreate: (db, version) async {
        await db.execute(_criarTabelaSQL);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS entregas');
        await db.execute(_criarTabelaSQL);
      },
    );

    return _db!;
  }

  static Future<void> salvarEntrega({
    int? id,
    required String cliente,
    required String endereco,
    required String descricao,
    required String status,
    required String foto,
    required String data,
    required String localizacao,
    required double lat,
    required double lng,
  }) async {
    final db = await getDatabase();

    final entrega = {
      'cliente': cliente,
      'endereco': endereco,
      'descricao': descricao,
      'status': status,
      'foto': foto,
      'data': data,
      'localizacao': localizacao,
      'lat': lat,
      'lng': lng,
    };

    if (id != null) {
      final existing = await db.query('entregas', where: 'id = ?', whereArgs: [id]);
      if (existing.isNotEmpty) {
        await db.update('entregas', entrega, where: 'id = ?', whereArgs: [id]);
        return;
      }
    }

    await db.insert('entregas', entrega);
  }

  static Future<List<Map<String, dynamic>>> listarEntregas() async {
    final db = await getDatabase();
    return db.query('entregas', orderBy: 'id DESC');
  }
}
