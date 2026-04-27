import 'package:hive/hive.dart';

part 'compito.g.dart';

@HiveType(typeId: 3)
enum TipoCompito {
  @HiveField(0)
  compito,
  @HiveField(1)
  verifica,
  @HiveField(2)
  interrogazione,
}

@HiveType(typeId: 4)
class Compito extends HiveObject {
  @HiveField(0)
  String materia;

  @HiveField(1)
  String descrizione;

  @HiveField(2)
  DateTime dataConsegna;

  @HiveField(3)
  TipoCompito tipo;

  @HiveField(4)
  bool completato;

  /// True if this entry was imported from ClasseViva.
  /// Used to identify and remove stale imports on re-sync
  /// without affecting manually added entries.
  @HiveField(5)
  bool importato;

  Compito({
    required this.materia,
    required this.descrizione,
    required this.dataConsegna,
    this.tipo = TipoCompito.compito,
    this.completato = false,
    this.importato = false,
  });
}
