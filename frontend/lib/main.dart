import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/assessment_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 CORREÇÃO DO ERRO DE LOCALE
  await initializeDateFormatting('pt_BR', null);

  // Notifications (web safe)
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PsicossocialApp(),
    ),
  );
}