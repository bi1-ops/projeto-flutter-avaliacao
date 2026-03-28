import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_avaliacao/models/servico.dart';
import 'package:projeto_avaliacao/providers/app_data_provider.dart';
import 'package:projeto_avaliacao/theme/app_palette.dart';

class ServicosScreen extends StatelessWidget {
  const ServicosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final servicos = appData.servicos;

    return Scaffold(
      body: servicos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum servico cadastrado.',
                style: TextStyle(color: AppPalette.text),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: servicos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final servico = servicos[index];
                return Card(
                  child: ListTile(
                    title: Text(servico.nome),
                    subtitle: Text(_formatarPreco(servico.preco)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _abrirFormulario(context, servico),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => _confirmarExclusao(context, servico),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Novo servico'),
      ),
    );
  }

  Future<void> _abrirFormulario(BuildContext context, Servico? servico) async {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: servico?.nome ?? '');
    final precoController = TextEditingController(
      text: servico == null ? '' : servico.preco.toStringAsFixed(2),
    );

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(servico == null ? 'Novo servico' : 'Editar servico'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: precoController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Preco'),
                  validator: (value) {
                    final texto = (value ?? '').replaceAll(',', '.').trim();
                    if (texto.isEmpty) return 'Informe o preco.';
                    if (double.tryParse(texto) == null) {
                      return 'Informe um preco valido.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final nome = nomeController.text.trim();
                final preco = double.parse(
                  precoController.text.replaceAll(',', '.').trim(),
                );
                final provider = context.read<AppDataProvider>();

                try {
                  if (servico == null) {
                    await provider.criarServico(nome: nome, preco: preco);
                  } else {
                    await provider.atualizarServico(
                      id: servico.id!,
                      nome: nome,
                      preco: preco,
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst('Exception: ', ''),
                      ),
                    ),
                  );
                  return;
                }

                if (!context.mounted) return;
                Navigator.pop(context);

                await showDialog<void>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text(servico == null ? 'Serviço criado' : 'Serviço atualizado'),
                      content: Text(servico == null
                          ? 'Serviço criado com sucesso.'
                          : 'Serviço atualizado com sucesso.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarExclusao(BuildContext context, Servico servico) async {
    final provider = context.read<AppDataProvider>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Excluir servico'),
          content: Text('Deseja excluir "${servico.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await provider.deletarServico(servico.id!);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Serviço excluído'),
            content: Text('Serviço "${servico.nome}" excluído com sucesso.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _formatarPreco(double preco) {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
