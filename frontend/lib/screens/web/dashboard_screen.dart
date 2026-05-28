import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/web/sidebar_menu.dart';
import '../../widgets/web/kpi_card.dart';
import '../../widgets/web/risk_chart.dart';
import '../../widgets/web/trend_chart.dart';
import '../../widgets/web/alert_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // evita erro de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  void _onMenuItemSelected(int index) {
    setState(() => _selectedIndex = index);

    final routes = [
      AppRoutes.webDashboard,
      AppRoutes.webTeam,
      AppRoutes.webReports,
      AppRoutes.webAlerts,
      AppRoutes.webHeatmap,
      AppRoutes.webSettings,
    ];

    if (index > 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashProvider = context.watch<DashboardProvider>();
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final user = authProvider.user;

    final kpis = dashProvider.kpis;
    final alerts = dashProvider.alerts;
    final resumo = dashProvider.resumo;

    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(
            selectedIndex: _selectedIndex,
            onItemSelected: _onMenuItemSelected,
          ),

          Expanded(
            child: Column(
              children: [
                // TOP BAR
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ??
                        Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Painel de Gestao',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),

                      IconButton(
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () => themeProvider.toggleTheme(),
                      ),

                      const SizedBox(width: 16),

                      CircleAvatar(
                        radius: 18,
                        child: Text(
                          (user?.nome.isNotEmpty ?? false)
                              ? user!.nome[0].toUpperCase()
                              : 'U',
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(user?.nome ?? ''),

                      PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'logout') {
                            authProvider.logout();
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'logout',
                            child: Text('Sair'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // CONTENT
                Expanded(
                  child: dashProvider.isLoading
                      ? const Center(
                          child: LoadingWidget(itemCount: 4),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              dashProvider.loadDashboard(),

                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // KPI SECTION
                                if (kpis.isEmpty)
                                  const Text("Sem KPIs disponíveis")
                                else
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: kpis.map((kpi) {
                                      return SizedBox(
                                        width: 250,
                                        child: KPICard(
                                          kpi: kpi,
                                          icon: Icons.analytics,
                                          color: Colors.blue,
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                const SizedBox(height: 24),

                                // CHARTS SAFE
                                if (resumo != null)
                                  RiskChart(
                                    distribution:
                                        resumo.distribuicaoRisco,
                                  )
                                else
                                  const Text("Sem dados de risco"),

                                const SizedBox(height: 24),

                                TrendChart(
                                  data: dashProvider.tendencias,
                                ),

                                const SizedBox(height: 24),

                                // ALERTS SAFE (🔥 principal correção)
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Alertas Recentes',
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        if (alerts.isEmpty)
                                          const Text(
                                              'Nenhum alerta recente')
                                        else
                                          ...alerts
                                              .take(3)
                                              .map(
                                                (alert) => AlertCard(
                                                  alert: alert,
                                                  onMarkRead: () {
                                                    dashProvider
                                                        .markAlertAsRead(
                                                            alert.id);
                                                  },
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}