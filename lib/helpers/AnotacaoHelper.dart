import 'package:anotacoescrudapp/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {

  static final String nameTable = "anotacao";

  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal() {}

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql =
        "CREATE TABLE $nameTable (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME) ";
    await db.execute(sql);
  }

  inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "db_minhas_anotacoes.db");

    var db =
        await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);

    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {

    var bancoDados = await db;

    int result = await bancoDados.insert(nameTable, anotacao.toMap());

    return result;
  }

  recuperarAnotacoes() async {

    var bancoDados = await db;

    String sql = "SELECT * FROM $nameTable ORDER BY data DESC";

    List anotacoes = await bancoDados.rawQuery(sql);

    return anotacoes;
  }

  Future<int> updateNote(Anotacao anotacao) async{

    var bancoDados = await db;

    return await bancoDados.update(
      nameTable,
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id]
    );

  }

  Future<int> removerNote(int id) async{
    var bd = await db;

    return await bd.delete(
      nameTable,
      where: "id = ?",
      whereArgs: [id]
    );
  }

}
