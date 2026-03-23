import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projeto_avaliacao/utils/app_validators.dart';

class UsuarioService {
  final SupabaseClient _client = Supabase.instance.client;

  String? _usuarioLogadoId;

  Future<Map<String, dynamic>?> buscarUsuarioPorId(String id) async {
    final response = await _client
        .from('usuarios')
        .select('id,nome_de_usuario,email,telefone,created_at')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  Future<void> deletarUsuario(String id) async {
    await _client.from('usuarios').delete().eq('id', id);
    if (_usuarioLogadoId == id) {
      _usuarioLogadoId = null;
    }
  }

  Future<void> cadastrarUsuario({
    required String nomeDeUsuario,
    required String email,
    String? telefone,
    required String senha,
    required String confirmacaoSenha,
  }) async {
    if (nomeDeUsuario.trim().isEmpty) {
      throw Exception('Nome de usuario e obrigatorio.');
    }
    if (email.trim().isEmpty) {
      throw Exception('E-mail e obrigatorio.');
    }
    if (!AppValidators.isValidEmail(email.trim())) {
      throw Exception('Informe um e-mail valido.');
    }
    if (senha.isEmpty) {
      throw Exception('Senha e obrigatoria.');
    }
    if (confirmacaoSenha.isEmpty) {
      throw Exception('Confirmacao de senha e obrigatoria.');
    }
    if (senha != confirmacaoSenha) {
      throw Exception('Senha e confirmacao de senha nao conferem.');
    }

    final emailExistente = await _client
        .from('usuarios')
        .select('id')
        .eq('email', email.trim())
        .maybeSingle();

    if (emailExistente != null) {
      throw Exception('Ja existe usuario com esse e-mail.');
    }

    final response = await _client
        .from('usuarios')
        .insert(
          {
            'nome_de_usuario': nomeDeUsuario.trim(),
            'email': email.trim(),
            'telefone': telefone?.trim(),
            'senha': senha,
          }..removeWhere((key, value) => value == null || value == ''),
        )
        .select('id')
        .single();

    _usuarioLogadoId = response['id'] as String?;
  }

  Future<void> login({
    required String nomeDeUsuario,
    required String senha,
  }) async {
    if (nomeDeUsuario.trim().isEmpty) {
      throw Exception('Nome de usuario e obrigatorio.');
    }
    if (senha.isEmpty) {
      throw Exception('Senha e obrigatoria.');
    }

    final usuario = await _client
        .from('usuarios')
        .select('id')
        .eq('nome_de_usuario', nomeDeUsuario.trim())
        .eq('senha', senha)
        .maybeSingle();

    if (usuario == null) {
      throw Exception('Credenciais invalidas.');
    }

    _usuarioLogadoId = usuario['id'] as String?;
  }

  Future<void> loginComEmail({
    required String email,
    required String senha,
  }) async {
    if (email.trim().isEmpty) {
      throw Exception('E-mail e obrigatorio.');
    }
    if (!AppValidators.isValidEmail(email.trim())) {
      throw Exception('Informe um e-mail valido.');
    }
    if (senha.isEmpty) {
      throw Exception('Senha e obrigatoria.');
    }

    final usuario = await _client
        .from('usuarios')
        .select('id')
        .eq('email', email.trim())
        .eq('senha', senha)
        .maybeSingle();

    if (usuario == null) {
      throw Exception('E-mail ou senha invalidos.');
    }

    _usuarioLogadoId = usuario['id'] as String?;
  }

  Future<void> logout() async {
    _usuarioLogadoId = null;
  }

  Future<void> atualizarSenha({
    required String novaSenha,
    required String confirmacaoSenha,
  }) async {
    final id = _usuarioLogadoId;
    if (id == null) {
      throw Exception('Usuario nao autenticado.');
    }
    if (novaSenha.isEmpty) {
      throw Exception('Nova senha e obrigatoria.');
    }
    if (confirmacaoSenha.isEmpty) {
      throw Exception('Confirmacao de senha e obrigatoria.');
    }
    if (novaSenha != confirmacaoSenha) {
      throw Exception('Nova senha e confirmacao de senha nao conferem.');
    }

    await _client.from('usuarios').update({'senha': novaSenha}).eq('id', id);
  }

  Future<void> redefinirSenhaPorEmail({
    required String email,
    required String novaSenha,
    required String confirmacaoSenha,
  }) async {
    if (email.trim().isEmpty) {
      throw Exception('E-mail e obrigatorio.');
    }
    if (!AppValidators.isValidEmail(email.trim())) {
      throw Exception('Informe um e-mail valido.');
    }
    if (novaSenha.isEmpty) {
      throw Exception('Nova senha e obrigatoria.');
    }
    if (confirmacaoSenha.isEmpty) {
      throw Exception('Confirmacao de senha e obrigatoria.');
    }
    if (novaSenha != confirmacaoSenha) {
      throw Exception('Nova senha e confirmacao de senha nao conferem.');
    }

    final usuario = await _client
        .from('usuarios')
        .select('id')
        .eq('email', email.trim())
        .maybeSingle();

    if (usuario == null) {
      throw Exception('Nao existe conta cadastrada com esse e-mail.');
    }

    await _client
        .from('usuarios')
        .update({'senha': novaSenha})
        .eq('email', email.trim());
  }

  String? usuarioLogadoId() {
    return _usuarioLogadoId;
  }
}
