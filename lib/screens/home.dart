import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_avaliacao/config/app_config.dart';
import 'package:projeto_avaliacao/providers/app_data_provider.dart';
import 'package:projeto_avaliacao/screens/agendamentos.dart';
import 'package:projeto_avaliacao/screens/login.dart';
import 'package:projeto_avaliacao/screens/servicos.dart';
import 'package:projeto_avaliacao/theme/app_palette.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  static const List<Widget> _paginas = [ServicosScreen(), AgendamentosScreen()];

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final usuario = appData.usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            onPressed: () => _abrirResumo(context),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: () => _sair(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _paginas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (valor) => setState(() => _indice = valor),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.design_services_outlined),
            selectedIcon: Icon(Icons.design_services),
            label: 'Servicos',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Agenda',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppPalette.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(AppConfig.logoAssetPath, height: 38),
                  const SizedBox(height: 12),
                  Text(
                    usuario?.nomeDeUsuario ?? 'Usuario',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('Servicos'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _indice = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Agenda'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _indice = 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _abrirResumo(BuildContext context) {
    final appData = context.read<AppDataProvider>();
    final usuario = appData.usuario;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario?.nomeDeUsuario ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(usuario?.email ?? ''),
              const SizedBox(height: 14),
              Text('Servicos cadastrados: ${appData.servicos.length}'),
              const SizedBox(height: 6),
              Text('Agendamentos cadastrados: ${appData.agendamentos.length}'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sair(BuildContext context) async {
    await context.read<AppDataProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(logoAssetPath: AppConfig.logoAssetPath),
      ),
      (_) => false,
    );
  }
}
