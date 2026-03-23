import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_avaliacao/providers/app_data_provider.dart';
import 'package:projeto_avaliacao/screens/home.dart';
import 'package:projeto_avaliacao/utils/app_validators.dart';

class CadastroScreen extends StatefulWidget {
  final String logoAssetPath;

  const CadastroScreen({super.key, required this.logoAssetPath});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();
  bool _esconderSenha = true;
  bool _esconderConfirmacao = true;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await context.read<AppDataProvider>().cadastrar(
        nomeDeUsuario: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        senha: _senhaController.text,
        confirmacaoSenha: _confirmacaoController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      _mostrarAviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de usuario')),
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
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nomeController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome do usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        return AppValidators.validateRequired(
                          value,
                          'Informe o nome do usuario.',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Numero de telefone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        return AppValidators.validateRequired(
                          value,
                          'Informe o telefone.',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _esconderSenha,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _esconderSenha = !_esconderSenha);
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
                          'Informe a senha.',
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
                          'Confirme a senha.',
                        );
                        if (erroBase != null) return erroBase;
                        if (value != _senhaController.text) {
                          return 'Senha e confirmacao nao conferem.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _salvando ? null : _cadastrar,
                      child: Text(
                        _salvando ? 'Cadastrando...' : 'Cadastrar',
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
