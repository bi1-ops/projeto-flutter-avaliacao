import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioService {
  final SupabaseClient _client = Supabase.instance.client;
  GoTrueClient get _auth => _client.auth;

  Future<Map<String, dynamic>?> buscarUsuarioPorId(String id) async {
    final response = await _client
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  Future<void> deletarUsuario(String id) async {
    await _client.from('usuarios').delete().eq('id', id);
  }

  Future<AuthResponse> cadastrarUsuario({
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
    if (senha.isEmpty) {
      throw Exception('Senha e obrigatoria.');
    }
    if (confirmacaoSenha.isEmpty) {
      throw Exception('Confirmacao de senha e obrigatoria.');
    }
    if (senha != confirmacaoSenha) {
      throw Exception('Senha e confirmacao de senha nao conferem.');
    }

    final authResponse = await _auth.signUp(email: email, password: senha);
    final userId = authResponse.user?.id;

    final dadosUsuario = <String, dynamic>{
      'id': userId,
      'nome_de_usuario': nomeDeUsuario,
      'email': email,
      'telefone': telefone,
    }..removeWhere((key, value) => value == null);

    await _client.from('usuarios').insert(dadosUsuario);

    return authResponse;
  }

  Future<AuthResponse> login({
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
        .select('email')
        .eq('nome_de_usuario', nomeDeUsuario)
        .maybeSingle();

    if (usuario == null || usuario['email'] == null) {
      throw Exception('Usuario nao encontrado.');
    }

    final email = usuario['email'] as String;
    return _auth.signInWithPassword(email: email, password: senha);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserResponse> atualizarSenha({
    required String novaSenha,
    required String confirmacaoSenha,
  }) async {
    if (novaSenha.isEmpty) {
      throw Exception('Nova senha e obrigatoria.');
    }
    if (confirmacaoSenha.isEmpty) {
      throw Exception('Confirmacao de senha e obrigatoria.');
    }
    if (novaSenha != confirmacaoSenha) {
      throw Exception('Nova senha e confirmacao de senha nao conferem.');
    }

    return _auth.updateUser(UserAttributes(password: novaSenha));
  }

  User? usuarioLogado() {
    return _auth.currentUser;
  }

  String? usuarioLogadoId() {
    return _auth.currentUser?.id;
  }
}
