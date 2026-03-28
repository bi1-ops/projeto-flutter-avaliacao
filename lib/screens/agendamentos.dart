import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_avaliacao/models/agendamento.dart';
import 'package:projeto_avaliacao/models/servico.dart';
import 'package:projeto_avaliacao/providers/app_data_provider.dart';
import 'package:projeto_avaliacao/theme/app_palette.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  DateTime _dataSelecionada = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final itensDoDia = appData.agendamentosPorData(_dataSelecionada);

    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: CalendarDatePicker(
              initialDate: _dataSelecionada,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              onDateChanged: (novaData) {
                setState(() => _dataSelecionada = novaData);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Agendamentos de ${_formatarData(_dataSelecionada)}',
                  style: const TextStyle(
                    color: AppPalette.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: itensDoDia.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum agendamento nesta data.',
                      style: TextStyle(color: AppPalette.text),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: itensDoDia.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final agendamento = itensDoDia[index];
                      final nomeServico = _nomeServico(
                        appData.servicos,
                        agendamento.servicoId,
                      );

                      return Card(
                        child: ListTile(
                          title: Text(
                            '${agendamento.hora} - ${agendamento.nomeCliente}',
                          ),
                          subtitle: Text(
                            'Servico: $nomeServico\nStatus: ${agendamento.status}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _abrirFormularioAgendamento(
                                  context,
                                  agendamento,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () => _confirmarExclusaoAgendamento(
                                  context,
                                  agendamento,
                                ),
                                icon: const Icon(Icons.delete_outline),
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
        onPressed: () => _abrirFormularioAgendamento(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _abrirFormularioAgendamento(
    BuildContext context,
    Agendamento? agendamento,
  ) async {
    final appData = context.read<AppDataProvider>();
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(
      text: agendamento?.nomeCliente ?? '',
    );

    DateTime dataSelecionada = agendamento?.data ?? _dataSelecionada;
    TimeOfDay horaSelecionada = _parseTimeOfDay(agendamento?.hora ?? '09:00');
    String statusSelecionado = agendamento?.status ?? 'pendente';
    String? servicoIdSelecionado = agendamento?.servicoId;

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                agendamento == null ? 'Novo agendamento' : 'Editar agendamento',
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do cliente',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome do cliente.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        initialValue: servicoIdSelecionado,
                        decoration: const InputDecoration(labelText: 'Servico'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Sem servico'),
                          ),
                          ...appData.servicos.map(
                            (servico) => DropdownMenuItem<String?>(
                              value: servico.id,
                              child: Text(servico.nome),
                            ),
                          ),
                        ],
                        onChanged: (valor) {
                          setStateDialog(() => servicoIdSelecionado = valor);
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Data'),
                        subtitle: Text(_formatarData(dataSelecionada)),
                        onTap: () async {
                          final novaData = await showDatePicker(
                            context: context,
                            initialDate: dataSelecionada,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (novaData == null) return;
                          setStateDialog(() => dataSelecionada = novaData);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time_outlined),
                        title: const Text('Hora'),
                        subtitle: Text(_formatarHora(horaSelecionada)),
                        onTap: () async {
                          final novaHora = await showTimePicker(
                            context: context,
                            initialTime: horaSelecionada,
                          );
                          if (novaHora == null) return;
                          setStateDialog(() => horaSelecionada = novaHora);
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: statusSelecionado,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'pendente',
                            child: Text('Pendente'),
                          ),
                          DropdownMenuItem(
                            value: 'confirmado',
                            child: Text('Confirmado'),
                          ),
                          DropdownMenuItem(
                            value: 'concluido',
                            child: Text('Concluido'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelado',
                            child: Text('Cancelado'),
                          ),
                        ],
                        onChanged: (valor) {
                          if (valor == null) return;
                          setStateDialog(() => statusSelecionado = valor);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final hora = _formatarHora(horaSelecionada);
                    final nome = nomeController.text.trim();

                    try {
                      if (agendamento == null) {
                        await appData.criarAgendamento(
                          servicoId: servicoIdSelecionado,
                          nomeCliente: nome,
                          data: dataSelecionada,
                          hora: hora,
                          status: statusSelecionado,
                        );
                      } else {
                        await appData.atualizarAgendamento(
                          id: agendamento.id!,
                          servicoId: servicoIdSelecionado,
                          nomeCliente: nome,
                          data: dataSelecionada,
                          hora: hora,
                          status: statusSelecionado,
                        );
                      }

                      if (!context.mounted) return;
                      setState(() => _dataSelecionada = dataSelecionada);
                      Navigator.of(context).pop();

                      await showDialog<void>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text(agendamento == null
                                ? 'Agendamento criado'
                                : 'Agendamento atualizado'),
                            content: Text(agendamento == null
                                ? 'Agendamento criado com sucesso.'
                                : 'Agendamento atualizado com sucesso.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmarExclusaoAgendamento(
    BuildContext context,
    Agendamento agendamento,
  ) async {
    final provider = context.read<AppDataProvider>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir agendamento'),
          content: Text(
            'Deseja excluir agendamento de ${agendamento.nomeCliente}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;
    try {
      await provider.deletarAgendamento(agendamento.id!);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Agendamento excluído'),
            content: Text('Agendamento de ${agendamento.nomeCliente} excluído com sucesso.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
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

  String _nomeServico(List<Servico> servicos, String? servicoId) {
    if (servicoId == null) return 'Sem servico';
    final match = servicos.where((item) => item.id == servicoId);
    if (match.isEmpty) return 'Servico removido';
    return match.first.nome;
  }

  TimeOfDay _parseTimeOfDay(String hora) {
    final partes = hora.split(':');
    final h = int.tryParse(partes.first) ?? 9;
    final m = int.tryParse(partes.length > 1 ? partes[1] : '0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatarHora(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
