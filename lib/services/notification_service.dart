import '../models/compito.dart';

/// Notification service stub — flutter_local_notifications is not compatible
/// with iOS 26 beta. Notifications are disabled until the plugin is updated.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> init() async {}
  Future<void> richiediPermessi() async {}
  Future<void> schedulaNotificaCompito(Compito compito) async {}
  Future<void> cancellaNotificaCompito(Compito compito) async {}
  Future<void> cancellaNotifiche() async {}
  Future<void> schedulaTutteLeNotifiche(List<Compito> compiti) async {}
}
