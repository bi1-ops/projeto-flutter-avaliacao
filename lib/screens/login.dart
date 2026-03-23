import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_avaliacao/providers/app_data_provider.dart';
import 'package:projeto_avaliacao/screens/cadastro.dart';
import 'package:projeto_avaliacao/screens/esqueci_senha.dart';
import 'package:projeto_avaliacao/screens/home.dart';
import 'package:projeto_avaliacao/theme/app_palette.dart';
import 'package:projeto_avaliacao/utils/app_validators.dart';

class LoginScreen extends StatefulWidget {
  final String logoAssetPath;

  const LoginScreen({super.key, required this.logoAssetPath});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _esconderSenha = true;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await context.read<AppDataProvider>().login(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _mostrarAviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirCadastro() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CadastroScreen(logoAssetPath: widget.logoAssetPath),
      ),
    );
  }

  void _abrirEsqueciSenha() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EsqueciSenhaScreen(logoAssetPath: widget.logoAssetPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F6FB), Color(0xFFF4FAFC), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            widget.logoAssetPath,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gerencie seus horarios com simplicidade',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppPalette.text.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) => AppValidators.validateEmail(
                            value,
                            emptyMessage: 'Informe seu e-mail.',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _senhaController,
                          obscureText: _esconderSenha,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () => _esconderSenha = !_esconderSenha,
                                );
                              },
                              icon: Icon(
                                _esconderSenha
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            return AppValidators.validateRequired(
                              value,
                              'Informe sua senha.',
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton(
                          onPressed: _carregando ? null : _entrar,
                          child: Text(
                            _carregando ? 'Entrando...' : 'Entrar',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _abrirCadastro,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppPalette.secondary),
                            foregroundColor: AppPalette.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _abrirEsqueciSenha,
                          child: const Text(
                            'Esqueci a senha?',
                            style: TextStyle(
                              color: AppPalette.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
