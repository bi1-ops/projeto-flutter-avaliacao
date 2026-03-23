import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_avaliacao/providers/app_data_provider.dart';
import 'package:projeto_avaliacao/theme/app_palette.dart';
import 'package:projeto_avaliacao/utils/app_validators.dart';

class EsqueciSenhaScreen extends StatefulWidget {
  final String logoAssetPath;

  const EsqueciSenhaScreen({super.key, required this.logoAssetPath});

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();
  bool _salvando = false;
  bool _esconderNovaSenha = true;
  bool _esconderConfirmacao = true;

  @override
  void dispose() {
    _emailController.dispose();
    _novaSenhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _redefinirSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await context.read<AppDataProvider>().recuperarSenha(
        email: _emailController.text.trim(),
        novaSenha: _novaSenhaController.text,
        confirmacaoSenha: _confirmacaoController.text,
      );
      if (!mounted) return;
      _mostrarAviso('Senha redefinida com sucesso.');
      Navigator.of(context).pop();
    } catch (e) {
      _mostrarAviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        widget.logoAssetPath,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Informe seu e-mail e a nova senha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppPalette.text),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _novaSenhaController,
                      obscureText: _esconderNovaSenha,
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () => _esconderNovaSenha = !_esconderNovaSenha,
                            );
                          },
                          icon: Icon(
                            _esconderNovaSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        return AppValidators.validateRequired(
                          value,
                          'Informe a nova senha.',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmacaoController,
                      obscureText: _esconderConfirmacao,
                      decoration: InputDecoration(
                        labelText: 'Confirmacao de senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _esconderConfirmacao = !_esconderConfirmacao;
                            });
                          },
                          icon: Icon(
                            _esconderConfirmacao
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final erroBase = AppValidators.validateRequired(
                          value,
                          'Confirme a nova senha.',
                        );
                        if (erroBase != null) return erroBase;
                        if (value != _novaSenhaController.text) {
                          return 'Senha e confirmacao nao conferem.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _salvando ? null : _redefinirSenha,
                      child: Text(
                        _salvando ? 'Salvando...' : 'Redefinir senha',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
