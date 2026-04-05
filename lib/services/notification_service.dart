import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/compito.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
  }

  Future<void> richiediPermessi() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

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

  Future<void> schedulaNotificaCompito(Compito compito) async {
    final id = compito.hashCode.abs() % 100000;
    final now = tz.TZDateTime.now(tz.local);

    // Notifica il giorno prima alle 19:00
    final giornoPrima = compito.dataConsegna.subtract(const Duration(days: 1));
    final orarioGiornoPrima = tz.TZDateTime(
      tz.local,
      giornoPrima.year,
      giornoPrima.month,
      giornoPrima.day,
      19,
      0,
    );

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

    // Notifica il giorno stesso alle 8:00
    final orarioGiornoStesso = tz.TZDateTime(
      tz.local,
      compito.dataConsegna.year,
      compito.dataConsegna.month,
      compito.dataConsegna.day,
      8,
      0,
    );

    if (orarioGiornoStesso.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: id + 1,
        title: '📅 Oggi: ${_titoloPerTipo(compito.tipo)}',
        body: '${compito.materia}: ${compito.descrizione}',
        scheduledDate: orarioGiornoStesso,
        notificationDetails: _dettagliNotifica,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancellaNotificaCompito(Compito compito) async {
    final id = compito.hashCode.abs() % 100000;
    await _plugin.cancel(id: id);
    await _plugin.cancel(id: id + 1);
  }

  Future<void> cancellaNotifiche() async {
    await _plugin.cancelAll();
  }

  Future<void> schedulaTutteLeNotifiche(List<Compito> compiti) async {
    await cancellaNotifiche();
    for (final c in compiti) {
      if (!c.completato) {
        await schedulaNotificaCompito(c);
      }
    }
  }

  String _titoloPerTipo(TipoCompito tipo) {
    switch (tipo) {
      case TipoCompito.verifica:
        return '📝 Verifica domani!';
      case TipoCompito.interrogazione:
        return '🎤 Interrogazione domani!';
      case TipoCompito.compito:
        return '📚 Compito da consegnare domani!';
    }
  }
}
