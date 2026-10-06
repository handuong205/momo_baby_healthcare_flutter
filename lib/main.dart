import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:momo_baby_healthcare_flutter/shared/widgets/app_shell.dart';

import 'services/api_service.dart';
import 'core/theme/app_theme.dart'; 
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  await dotenv.load(
    fileName: '.env',
  );

  ApiService.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MomBaby',
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}