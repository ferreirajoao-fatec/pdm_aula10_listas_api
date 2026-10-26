import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/noticia_model.dart';

class NoticiaService {
  // Feed de notícias em JSON hospedado no próprio repositório (pasta api/)
  static const String endpointValido =
      'https://raw.githubusercontent.com/ferreirajoao-fatec/pdm_aula10_listas_api/main/api/noticias.json';

  // Desafio Avançado: endereço inexistente usado para simular erro de conexão
  static const String endpointInvalido = 'https://endereco-invalido.noticias.invalid/noticias.json';

  String _endpoint = endpointValido;

  bool get simulandoErro => _endpoint == endpointInvalido;

  void alternarSimulacaoErro() {
    _endpoint = simulandoErro ? endpointValido : endpointInvalido;
  }

  Future<List<NoticiaModel>> buscarNoticias() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));

      if (response.statusCode == 200) {
        final List<dynamic> listaJson = jsonDecode(response.body);
        return listaJson.map((json) => NoticiaModel.fromJson(json)).toList();
      } else {
        throw Exception('Status HTTP de erro: ' + response.statusCode.toString());
      }
    } catch (e) {
      throw Exception('Falha ao conectar com a API: ' + e.toString());
    }
  }
}
