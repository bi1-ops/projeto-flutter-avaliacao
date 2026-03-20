import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yjqevtshaugwujjjygxw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlqcWV2dHNoYXVnd3Vqamp5Z3h3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwMTIxMDUsImV4cCI6MjA4OTU4ODEwNX0.Zt5LOQ36Czz81Si9F2EJHo5ZKhTyS_wePCakWDzzsdM',
  );
  runApp(
    DevicePreview(
      enabled: true,
      builder: (conetext) => const MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello Mundo!'),
        ),
      ),
    );
  }
}
