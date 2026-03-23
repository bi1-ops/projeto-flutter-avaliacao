import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_avaliacao/config/app_config.dart';
import 'package:projeto_avaliacao/providers/app_data_provider.dart';
import 'package:projeto_avaliacao/screens/login.dart';
import 'package:projeto_avaliacao/services/agendamento_service.dart';
import 'package:projeto_avaliacao/services/servico_service.dart';
import 'package:projeto_avaliacao/services/usuario_service.dart';
import 'package:projeto_avaliacao/theme/app_palette.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(DevicePreview(enabled: true, builder: (context) => const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final UsuarioService _usuarioService = UsuarioService();
  static final ServicoService _servicoService = ServicoService();
  static final AgendamentoService _agendamentoService = AgendamentoService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDataProvider(
        usuarioService: _usuarioService,
        servicoService: _servicoService,
        agendamentoService: _agendamentoService,
      )..carregarSessao(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(
                seedColor: AppPalette.primary,
                brightness: Brightness.light,
              ).copyWith(
                primary: AppPalette.primary,
                secondary: AppPalette.secondary,
                surface: AppPalette.surface,
              ),
          scaffoldBackgroundColor: AppPalette.background,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppPalette.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        home: const LoginScreen(logoAssetPath: AppConfig.logoAssetPath),
      ),
    );
  }
}
