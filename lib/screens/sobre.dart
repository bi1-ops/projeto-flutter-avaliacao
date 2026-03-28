import 'package:flutter/material.dart';
import 'package:projeto_avaliacao/config/app_config.dart';
import 'package:projeto_avaliacao/theme/app_palette.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo do app
            Center(
              child: Image.asset(
                AppConfig.logoAssetPath,
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 24),

            // Nome do app
            Center(
              child: Text(
                AppConfig.appName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Versão
            Center(
              child: Text(
                'Versão 1.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Objetivo do aplicativo
            const Text(
              'Objetivo do Aplicativo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Este aplicativo permite aos usuários cadastrar, gerenciar e visualizar serviços, fazer agendamentos e gerenciar seus compromissos de forma prática e intuitiva.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Equipe de desenvolvimento
            const Text(
              'Equipe de Desenvolvimento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Leander Augusto Teixeira\n• Leonardo Felix Kinouchi',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Disciplina
            const Text(
              'Disciplina',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Desenvolvimento Mobile',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Instituição
            const Text(
              'Instituição',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Universidade de Ribeirão Preto',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Professor
            const Text(
              'Professor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rodrigo de Oliveira Plotze',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Rodapé
            Center(
              child: Text(
                '© ${DateTime.now().year} - ${AppConfig.appName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}