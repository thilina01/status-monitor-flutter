import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/theme_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  int refreshCountdown = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await Future.delayed(Duration(milliseconds: 500)); // Small delay to ensure settings are loaded
      refreshCountdown = apiService.autoRefreshDuration; // Set countdown based on settings
      apiService.fetchData();
    });

    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final apiService = Provider.of<ApiService>(context, listen: false);

      if (apiService.isAutoRefreshEnabled) {
        if (refreshCountdown > 0) {
          setState(() {
            refreshCountdown--;
          });
        } else {
          apiService.fetchData();
          setState(() {
            refreshCountdown = apiService.autoRefreshDuration; // Reset countdown
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Status Monitor'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Consumer<ApiService>(
            builder: (context, apiService, child) {
              return apiService.isLoading
                  ? LinearProgressIndicator(minHeight: 4.0)
                  : SizedBox.shrink();
            },
          ),
        ),
      ),
      body: Consumer<ApiService>(
        builder: (context, apiService, child) {
          if (apiService.errorMessage.isNotEmpty) {
            return Center(child: Text(apiService.errorMessage));
          }

          return Column(
            children: [
              // Top Section: System Overview
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'System Overview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),// Show only if enabled
                              Text(
                                'Up/Total: ${apiService.upHealthyCount} / ${apiService.expectedServicesCount}',
                                style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Last Update: ${apiService.lastUpdateTime}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                              ),
                            ),
                            if (apiService.isAutoRefreshEnabled) // Show only if enabled
                              Text(
                                'Auto Refresh in: $refreshCountdown s',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),

              // GridView for Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateGridColumns(context),
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 3.0,
                    ),
                    itemCount: apiService.services.length,
                    itemBuilder: (context, index) {
                      final service = apiService.services[index];
                      return _buildServiceCard(context, service);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<ApiService>(context, listen: false).fetchData(forceRefresh: true),
        child: Icon(Icons.refresh),
      ),
    );
  }

  int _calculateGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    return (orientation == Orientation.portrait) ? (screenWidth ~/ 320) : (screenWidth ~/ 300);
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData statusIcon = Icons.help;
    Color statusColor = colorScheme.secondary;

    if (service['status'] == 'up' || service['status'] == 'healthy') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else if (service['status'] == 'down' || service['status'] == 'unhealthy') {
      statusIcon = Icons.error;
      statusColor = Colors.red;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(
                  service['name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(children: [
                Text(
                  service['status'],
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(statusIcon, color: statusColor, size: 20),
              ]),
            ]),
            SizedBox(height: 4),
            Divider(),
            SizedBox(height: 4),
            // Metrics: CPU, Memory, Network (Preserved layout)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric(context, icon: Icons.memory, label: "CPU", value: service['CPUPerc']),
                _buildMetric(context, icon: Icons.storage, label: "Memory",
                    value: "${service['MemUsage'].split(' / ')[0]} (${service['MemPerc']})"),
                _buildMetric(context, icon: Icons.cloud_download, label: "Net IO", value: service['NetIO']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.secondary),
            SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withAlpha((0.5 * 255).toInt()))),
          ],
        ),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onSurface)),
      ],
    );
  }
}
