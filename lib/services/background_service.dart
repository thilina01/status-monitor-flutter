import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String backgroundTaskKey = "fetchServiceStatus";

/// The background callback function.
/// It fetches the API data, checks for down services, and shows a notification if needed.
/// To avoid repeated notifications, we store the names of already notified services in SharedPreferences.
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = prefs.getString('apiUrl') ?? "";
    if (apiUrl.isEmpty) {
      // No API URL set; nothing to do.
      return Future.value(true);
    }

    // Initialize local notifications
    FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(initSettings);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final List<dynamic> services =
        List<dynamic>.from(decodedData['services'] ?? []);

        // Retrieve already notified services list from SharedPreferences.
        List<String> notifiedServices =
            prefs.getStringList('notifiedServices') ?? [];

        for (var service in services) {
          String serviceName = service['name'];
          String status = service['status'];

          // If service is down and has not been notified yet, send notification.
          if ((status == 'down' || status == 'unhealthy') &&
              !notifiedServices.contains(serviceName)) {
            const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
              'service_down_channel',
              'Service Down Alerts',
              importance: Importance.high,
              priority: Priority.high,
            );
            const NotificationDetails notificationDetails =
            NotificationDetails(android: androidDetails);

            await notificationsPlugin.show(
              serviceName.hashCode, // using a hash code as a unique ID
              'Service Alert',
              '$serviceName is down!',
              notificationDetails,
            );
            notifiedServices.add(serviceName);
          } else if ((status == 'up' || status == 'healthy') &&
              notifiedServices.contains(serviceName)) {
            // Remove service from the notified list if it recovers.
            notifiedServices.remove(serviceName);
          }
        }

        // Save the updated notified services list.
        prefs.setStringList('notifiedServices', notifiedServices);
      }
    } catch (error) {
      // Handle errors if necessary (e.g., logging)
    }

    return Future.value(true);
  });
}
