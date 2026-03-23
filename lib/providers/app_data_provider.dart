import 'package:flutter/material.dart';
import 'package:projeto_avaliacao/models/agendamento.dart';
import 'package:projeto_avaliacao/models/servico.dart';
import 'package:projeto_avaliacao/models/usuario.dart';
import 'package:projeto_avaliacao/services/agendamento_service.dart';
import 'package:projeto_avaliacao/services/servico_service.dart';
import 'package:projeto_avaliacao/services/usuario_service.dart';

class AppDataProvider extends ChangeNotifier {
  final UsuarioService _usuarioService;
  final ServicoService _servicoService;
  final AgendamentoService _agendamentoService;

  AppDataProvider({
    required UsuarioService usuarioService,
    required ServicoService servicoService,
    required AgendamentoService agendamentoService,
  }) : _usuarioService = usuarioService,
       _servicoService = servicoService,
       _agendamentoService = agendamentoService;

  Usuario? _usuario;
  List<Servico> _servicos = [];
  List<Agendamento> _agendamentos = [];
  bool _carregando = false;
  String? _erro;

  Usuario? get usuario => _usuario;
  List<Servico> get servicos => List.unmodifiable(_servicos);
  List<Agendamento> get agendamentos => List.unmodifiable(_agendamentos);
  bool get carregando => _carregando;
  String? get erro => _erro;
  String? get usuarioId => _usuarioService.usuarioLogadoId();
  bool get autenticado => usuarioId != null;

  List<Agendamento> agendamentosPorData(DateTime data) {
    return _agendamentos.where((agendamento) {
      return _mesmaData(agendamento.data, data);
    }).toList()..sort((a, b) => a.hora.compareTo(b.hora));
  }

  Future<void> carregarSessao() async {
    if (!autenticado) {
      limparDados();
      return;
    }
    await carregarDadosIniciais();
  }

  Future<void> login({required String email, required String senha}) async {
    await _executarComEstado(() async {
      await _usuarioService.loginComEmail(email: email, senha: senha);
      await _carregarDadosSemEstado();
    });
  }

  Future<void> cadastrar({
    required String nomeDeUsuario,
    required String email,
    required String telefone,
    required String senha,
    required String confirmacaoSenha,
  }) async {
    await _executarComEstado(() async {
      await _usuarioService.cadastrarUsuario(
        nomeDeUsuario: nomeDeUsuario,
        email: email,
        telefone: telefone,
        senha: senha,
        confirmacaoSenha: confirmacaoSenha,
      );
      await _usuarioService.loginComEmail(email: email, senha: senha);
      await _carregarDadosSemEstado();
    });
  }

  Future<void> recuperarSenha({
    required String email,
    required String novaSenha,
    required String confirmacaoSenha,
  }) async {
    await _executarComEstado(() async {
      await _usuarioService.redefinirSenhaPorEmail(
        email: email,
        novaSenha: novaSenha,
        confirmacaoSenha: confirmacaoSenha,
      );
    });
  }

  Future<void> logout() async {
    await _executarComEstado(() async {
      await _usuarioService.logout();
      limparDados(notify: false);
    });
    notifyListeners();
  }

  Future<void> carregarDadosIniciais() async {
    await _executarComEstado(() async {
      await _carregarDadosSemEstado();
    });
  }

  Future<void> criarServico({
    required String nome,
    required double preco,
  }) async {
    final id = usuarioId;
    if (id == null) throw Exception('Usuario nao autenticado.');

    await _executarComEstado(() async {
      await _servicoService.criarServico(
        usuarioId: id,
        nome: nome,
        preco: preco,
      );
      await _recarregarServicosSemEstado(id);
    });
  }

  Future<void> atualizarServico({
    required String id,
    required String nome,
    required double preco,
  }) async {
    await _executarComEstado(() async {
      await _servicoService.atualizarServico(id: id, nome: nome, preco: preco);
      final usuarioAtualId = usuarioId;
      if (usuarioAtualId == null) return;
      await _recarregarServicosSemEstado(usuarioAtualId);
    });
  }

  Future<void> deletarServico(String id) async {
    await _executarComEstado(() async {
      await _servicoService.deletarServico(id);
      _servicos.removeWhere((servico) => servico.id == id);
      _agendamentos = _agendamentos
          .map(
            (item) => item.servicoId == id
                ? Agendamento(
                    id: item.id,
                    usuarioId: item.usuarioId,
                    servicoId: null,
                    nomeCliente: item.nomeCliente,
                    data: item.data,
                    hora: item.hora,
                    status: item.status,
                  )
                : item,
          )
          .toList();
    });
  }

  Future<void> criarAgendamento({
    String? servicoId,
    required String nomeCliente,
    required DateTime data,
    required String hora,
    String status = 'pendente',
  }) async {
    final id = usuarioId;
    if (id == null) throw Exception('Usuario nao autenticado.');

    await _executarComEstado(() async {
      await _agendamentoService.criarAgendamento(
        usuarioId: id,
        servicoId: servicoId,
        nomeCliente: nomeCliente,
        data: data,
        hora: hora,
        status: status,
      );
      await _recarregarAgendamentosSemEstado(id);
    });
  }

  Future<void> atualizarAgendamento({
    required String id,
    String? servicoId,
    required String nomeCliente,
    required DateTime data,
    required String hora,
    required String status,
  }) async {
    await _executarComEstado(() async {
      await _agendamentoService.atualizarAgendamento(
        id: id,
        servicoId: servicoId,
        nomeCliente: nomeCliente,
        data: data,
        hora: hora,
        status: status,
      );
      final usuarioAtualId = usuarioId;
      if (usuarioAtualId == null) return;
      await _recarregarAgendamentosSemEstado(usuarioAtualId);
    });
  }

  Future<void> deletarAgendamento(String id) async {
    await _executarComEstado(() async {
      await _agendamentoService.deletarAgendamento(id);
      _agendamentos.removeWhere((item) => item.id == id);
    });
  }

  void limparDados({bool notify = true}) {
    _usuario = null;
    _servicos = [];
    _agendamentos = [];
    _erro = null;
    if (notify) notifyListeners();
  }

  Future<void> _carregarDadosSemEstado() async {
    final id = usuarioId;
    if (id == null) {
      limparDados(notify: false);
      return;
    }

    final resultados = await Future.wait<dynamic>([
      _usuarioService.buscarUsuarioPorId(id),
      _servicoService.listarServicos(id),
      _agendamentoService.listarAgendamentos(id),
    ]);

    final usuarioMap = resultados[0] as Map<String, dynamic>?;
    final servicosMap = resultados[1] as List<Map<String, dynamic>>;
    final agendamentosMap = resultados[2] as List<Map<String, dynamic>>;

    _usuario = usuarioMap == null ? null : Usuario.fromMap(usuarioMap);
    _servicos = servicosMap.map(Servico.fromMap).toList();
    _agendamentos = agendamentosMap.map(Agendamento.fromMap).toList();
  }

  Future<void> _executarComEstado(Future<void> Function() acao) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      await acao();
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> _recarregarServicosSemEstado(String usuarioId) async {
    final lista = await _servicoService.listarServicos(usuarioId);
    _servicos = lista.map(Servico.fromMap).toList();
  }

  Future<void> _recarregarAgendamentosSemEstado(String usuarioId) async {
    final lista = await _agendamentoService.listarAgendamentos(usuarioId);
    _agendamentos = lista.map(Agendamento.fromMap).toList();
  }

  bool _mesmaData(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
