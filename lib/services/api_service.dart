import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService with ChangeNotifier {
  String _apiUrl = ""; // http://localhost:8080/api/status
  bool _isLoading = false;
  String _errorMessage = "";
  List<dynamic> _services = [];
  Map<String, dynamic> _data = {};
  String _lastUpdateTime = "";

  // Auto-refresh settings
  int _autoRefreshDuration = 30; // Default to 30 seconds
  bool _isAutoRefreshEnabled = true;

  // Getters
  String get apiUrl => _apiUrl;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get services => _services;
  Map<String, dynamic> get data => _data;
  String get lastUpdateTime => _lastUpdateTime;
  int get autoRefreshDuration => _autoRefreshDuration;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;
  // Local Notifications
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ApiService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _initializeNotifications();
    await _loadSettings(); // Ensure settings are fully loaded before fetching data
  }

  /// 🔔 Initialize Local Notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  /// 🔔 Show Notification When a Service Goes Down
  Future<void> _showNotification(String serviceName) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'service_down_channel',
      'Service Down Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // Unique ID
      'Service Alert',
      '$serviceName is down!',
      notificationDetails,
    );
  }

  /// 📡 Load user preferences (API URL, auto-refresh settings)
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _apiUrl = prefs.getString('apiUrl') ?? _apiUrl;
    _autoRefreshDuration = prefs.getInt('autoRefreshDuration') ?? _autoRefreshDuration;
    _isAutoRefreshEnabled = prefs.getBool('isAutoRefreshEnabled') ?? _isAutoRefreshEnabled;
    notifyListeners();
  }

  /// 🔧 Allow users to update API URL
  void setApiUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiUrl', url);
    _apiUrl = url;
    notifyListeners();
  }

  /// 🔧 Allow users to update refresh duration
  void setAutoRefreshDuration(int duration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('autoRefreshDuration', duration);
    _autoRefreshDuration = duration;
    notifyListeners();
  }

  /// 🔧 Allow users to toggle auto-refresh
  void toggleAutoRefresh(bool isEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAutoRefreshEnabled', isEnabled);
    _isAutoRefreshEnabled = isEnabled;
    notifyListeners();
  }

  /// 📡 Fetch service status from API (Includes Notifications & UI Update)
  Future<void> fetchData({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_apiUrl + (forceRefresh ? '?force=true' : '')));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final List<dynamic> newServices = List<dynamic>.from(decodedData['services'] ?? []);
        final Map<String, dynamic> newData = Map<String, dynamic>.from(decodedData);

        // 🔔 Check if any service went "down"
        _checkForDownServices(_services, newServices);

        if (!_isSameStatus(newServices)) {
          _services = List<dynamic>.from(newServices);
          _data = newData;

          // 🔄 Sort Services (Down services first)
          _services.sort((a, b) {
            if ((a['status'] == 'down' || a['status'] == 'unhealthy') &&
                (b['status'] == 'up' || b['status'] == 'healthy')) {
              return -1;
            } else if ((a['status'] == 'up' || a['status'] == 'healthy') &&
                (b['status'] == 'down' || b['status'] == 'unhealthy')) {
              return 1;
            }
            return 0;
          });

          notifyListeners();
        }

        // 🕒 Update Last Fetched Time
        _lastUpdateTime = DateTime.now().toLocal().toString().split('.')[0];
      } else {
        _errorMessage = "Failed to fetch data";
      }
    } catch (error) {
      _errorMessage = "Error: $error";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔔 Check if any service transitioned from "up" to "down"
  void _checkForDownServices(List<dynamic> oldServices, List<dynamic> newServices) {
    for (int i = 0; i < newServices.length; i++) {
      if (i < oldServices.length &&
          oldServices[i]['status'] != 'down' &&
          newServices[i]['status'] == 'down') {
        _showNotification(newServices[i]['name']);
      }
    }
  }

  /// ✅ Avoid unnecessary UI updates by comparing old & new data
  bool _isSameStatus(List<dynamic> newServices) {
    if (_services.length != newServices.length) return false;
    for (int i = 0; i < _services.length; i++) {
      if (_services[i]['status'] != newServices[i]['status']) {
        return false;
      }
    }
    return true;
  }

  // **📡 Expose Data to UI**
  int get upHealthyCount => _data['up_healthy_count'] ?? 0;
  int get expectedServicesCount => _data['expected_services_count'] ?? 0;
  String get totalCPU => _data['totalCPUPerc'] ?? "N/A";
  String get totalMemoryUsage => _data['totalMemUsage'] ?? "N/A";
  String get totalMemoryPercentage => _data['totalMemPerc'] ?? "N/A";
  int get refreshDuration => _isAutoRefreshEnabled ? _autoRefreshDuration : 0;
}
