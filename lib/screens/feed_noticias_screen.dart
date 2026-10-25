import 'package:flutter/material.dart';
import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import 'detalhe_noticia_screen.dart';

class FeedNoticiasScreen extends StatefulWidget {
  const FeedNoticiasScreen({super.key});

  @override
  State<FeedNoticiasScreen> createState() => _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  final _service = NoticiaService();
  final _buscaController = TextEditingController();
  List<NoticiaModel> _noticias = [];
  String _filtro = '';
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarFeed();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarFeed() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _service.buscarNoticias();
      setState(() => _noticias = lista);
    } catch (e) {
      setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  // Desafio Avançado: alterna a URL entre válida e inválida e recarrega o feed
  void _alternarSimulacaoErro() {
    _service.alternarSimulacaoErro();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_service.simulandoErro
            ? 'Simulação de erro ATIVADA (URL inválida)'
            : 'Simulação de erro DESATIVADA (URL válida)'),
      ),
    );
    _carregarFeed();
  }

  // Desafio Básico: filtra a lista por título em tempo real
  List<NoticiaModel> get _noticiasFiltradas {
    if (_filtro.isEmpty) return _noticias;
    final termo = _filtro.toLowerCase();
    return _noticias.where((n) => n.titulo.toLowerCase().contains(termo)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Notícias'),
        actions: [
          IconButton(
            icon: Icon(_service.simulandoErro ? Icons.wifi_off : Icons.bug_report),
            tooltip: 'Simular erro de conexão',
            onPressed: _alternarSimulacaoErro,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregarFeed),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          setState(() => _filtro = '');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (valor) => setState(() => _filtro = valor),
            ),
          ),
          Expanded(child: _buildConteudo()),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    if (_erro != null) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(_erro!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _carregarFeed, child: const Text('Tentar Novamente')),
              ],
            ),
          ),
        ),
      );
    }

    final noticias = _noticiasFiltradas;

    if (noticias.isEmpty) {
      return Center(
        child: Text(_filtro.isEmpty ? 'Nenhuma notícia disponível.' : 'Nenhuma notícia encontrada para "$_filtro".'),
      );
    }

    return ListView.builder(
      itemCount: noticias.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final noticia = noticias[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(noticia.id.toString())),
            title: Text(noticia.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(noticia.resumo, maxLines: 2, overflow: TextOverflow.ellipsis),
            // Desafio Intermediário: navegação para a tela de detalhes
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetalheNoticiaScreen(noticia: noticia)),
              );
            },
          ),
        );
      },
    );
  }
}
