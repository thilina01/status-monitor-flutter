import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _refreshDurationController = TextEditingController();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    _urlController.text = apiService.apiUrl;
    _refreshDurationController.text = apiService.autoRefreshDuration.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API URL Setting
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'API URL',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                apiService.setApiUrl(value);
              },
            ),
            SizedBox(height: 16),
            // Auto Refresh Duration Setting
            TextField(
              controller: _refreshDurationController,
              decoration: InputDecoration(
                labelText: 'Auto Refresh Duration (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final duration = int.tryParse(value) ?? apiService.autoRefreshDuration;
                apiService.setAutoRefreshDuration(duration);
              },
            ),
            SizedBox(height: 16),
            // Enable/Disable Auto Refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable Auto Refresh',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: apiService.isAutoRefreshEnabled,
                  onChanged: (value) {
                    apiService.toggleAutoRefresh(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
