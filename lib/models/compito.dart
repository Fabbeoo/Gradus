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
  @HiveField(3)
  comunicazione,
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

  @HiveField(5)
  bool importato;

  /// Teacher name — populated when imported from ClasseViva.
  @HiveField(6)
  String autore;

  Compito({
    required this.materia,
    required this.descrizione,
    required this.dataConsegna,
    this.tipo = TipoCompito.compito,
    this.completato = false,
    this.importato = false,
    this.autore = '',
  });
}
