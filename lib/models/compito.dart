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
  // Subject name for the task
  @HiveField(0)
  String materia;

  // Short description of the task
  @HiveField(1)
  String descrizione;

  // Due date for the task
  @HiveField(2)
  DateTime dataConsegna;

  // Type of task: compito, verifica, or interrogazione
  @HiveField(3)
  TipoCompito tipo;

  // Whether the task is marked as completed
  @HiveField(4)
  bool completato;

  // Create a task with required fields and optional type/completed flag.
  Compito({
    required this.materia,
    required this.descrizione,
    required this.dataConsegna,
    this.tipo = TipoCompito.compito,
    this.completato = false,
  });
}
