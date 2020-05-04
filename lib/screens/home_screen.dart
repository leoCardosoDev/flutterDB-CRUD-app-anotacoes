import 'package:anotacoescrudapp/helpers/AnotacaoHelper.dart';
import 'package:anotacoescrudapp/model/Anotacao.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  var _db = AnotacaoHelper();

  List<Anotacao> _anotacoesList = List<Anotacao>();

  _exibirModal( {Anotacao anotacao} ) {

    String txtSaveUpdate = "";

    if(anotacao == null){
      _tituloController.text = "";
      _descricaoController.text = "";
      txtSaveUpdate = "Adicionar";
    }else{
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      txtSaveUpdate = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$txtSaveUpdate Anotação'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Titulo", hintText: "Digite o título"),
                ),
                Expanded(
                  child: TextField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                        labelText: "Descrição",
                        hintText: "Digite a descrição: "),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  // salvar
                  _salvarAtualizarAnotacao(anotacaoUpdate: anotacao);
                  Navigator.pop(context);
                },
                child: Text(txtSaveUpdate),
              ),
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoes = await _db.recuperarAnotacoes();

    List<Anotacao> listTemp = List<Anotacao>();

    for (var item in anotacoes) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listTemp.add(anotacao);
    }

    setState(() {
      _anotacoesList = listTemp;
    });
    listTemp = null;

    //print(anotacoes.toString());
  }

  _salvarAtualizarAnotacao( {Anotacao anotacaoUpdate} ) async {

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    String data = DateTime.now().toString();

    if(anotacaoUpdate == null){
      Anotacao anotacao = Anotacao(titulo, descricao, data);
      int result = await _db.salvarAnotacao(anotacao);

    }else{
      anotacaoUpdate.titulo = titulo;
      anotacaoUpdate.descricao = descricao;
      anotacaoUpdate.data = data;

      int result = await _db.updateNote(anotacaoUpdate);
    }

    _tituloController.clear();
    _descricaoController.clear();
    _recuperarAnotacoes();

  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    var fomatador = DateFormat("dd/MM/y HH:mm:ss");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = fomatador.format(dataConvertida);
    return dataFormatada;
  }

  _removerNote(int id) async{
    await _db.removerNote(id);

    _recuperarAnotacoes();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotações"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoesList.length,
              itemBuilder: (context, index) {
                final anotacao = _anotacoesList[index];
                return Card(
                  child: ListTile(
                    title: Text(anotacao.titulo),
                    subtitle: Text(
                        "${_formatarData(anotacao.data)} - ${anotacao.descricao}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _exibirModal(anotacao: anotacao);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _removerNote(anotacao.id);
                          },
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _exibirModal();
        },
      ),
    );
  }
}
