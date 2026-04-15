import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/compito.dart';

// Service that manages local notifications for homework and tests.
class NotificationService {
  // Singleton instance to use the same service everywhere.
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  // Plugin used to show and schedule local notifications.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Initialize timezone data and notification settings for Android and iOS.
  Future<void> init() async {
    // Load timezone database.
    tz_data.initializeTimeZones();
    // Set the local timezone to Europe/Rome.
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));

    // Android initialization settings using the app launcher icon.
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // iOS initialization settings requesting alert, badge, and sound permissions.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine platform settings into one initialization object.
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin with the combined settings.
    await _plugin.initialize(settings: initSettings);
  }

  // Ask iOS for notification permissions (alert, badge, sound).
  Future<void> richiediPermessi() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Notification details used for both Android and iOS notifications.
  NotificationDetails get _dettagliNotifica => const NotificationDetails(
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    android: AndroidNotificationDetails(
      'registro_channel',
      'Registro Scolastico',
      channelDescription: 'Notifiche compiti e verifiche',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  // Schedule notifications for a single homework item.
  Future<void> schedulaNotificaCompito(Compito compito) async {
    // Create a stable numeric id from the homework object.
    final id = compito.hashCode.abs() % 100000;
    // Current time in the local timezone.
    final now = tz.TZDateTime.now(tz.local);

    // Schedule a notification for the day before at 19:00.
    final giornoPrima = compito.dataConsegna.subtract(const Duration(days: 1));
    final orarioGiornoPrima = tz.TZDateTime(
      tz.local,
      giornoPrima.year,
      giornoPrima.month,
      giornoPrima.day,
      19,
      0,
    );

    // Only schedule if the target time is in the future.
    if (orarioGiornoPrima.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: id,
        title: _titoloPerTipo(compito.tipo),
        body:
            '${compito.materia}: ${compito.descrizione} — domani ${compito.dataConsegna.day}/${compito.dataConsegna.month}',
        scheduledDate: orarioGiornoPrima,
        notificationDetails: _dettagliNotifica,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // Schedule a notification for the same day at 08:00.
    final orarioGiornoStesso = tz.TZDateTime(
      tz.local,
      compito.dataConsegna.year,
      compito.dataConsegna.month,
      compito.dataConsegna.day,
      8,
      0,
    );

    // Only schedule if the target time is in the future.
    if (orarioGiornoStesso.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: id + 1,
        title: 'Oggi: ${_titoloPerTipo(compito.tipo)}',
        body: '${compito.materia}: ${compito.descrizione}',
        scheduledDate: orarioGiornoStesso,
        notificationDetails: _dettagliNotifica,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // Cancel both notifications related to a homework item using the ids.
  Future<void> cancellaNotificaCompito(Compito compito) async {
    final id = compito.hashCode.abs() % 100000;
    await _plugin.cancel(id: id);
    await _plugin.cancel(id: id + 1);
  }

  // Cancel all scheduled notifications.
  Future<void> cancellaNotifiche() async {
    await _plugin.cancelAll();
  }

  // Clear existing notifications and schedule new ones for all pending homework.
  Future<void> schedulaTutteLeNotifiche(List<Compito> compiti) async {
    await cancellaNotifiche();
    for (final c in compiti) {
      if (!c.completato) {
        await schedulaNotificaCompito(c);
      }
    }
  }

  // Return a short title based on the type of homework or test.
  String _titoloPerTipo(TipoCompito tipo) {
    switch (tipo) {
      case TipoCompito.verifica:
        return 'Verifica domani!';
      case TipoCompito.interrogazione:
        return 'Interrogazione domani!';
      case TipoCompito.compito:
        return 'Compito da consegnare domani!';
    }
  }
}
