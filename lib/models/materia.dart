import 'package:hive/hive.dart';

part 'materia.g.dart';

@HiveType(typeId: 0)
class Voto extends HiveObject {
  // Numeric grade value, e.g. 6.00 or 7.50
  @HiveField(0)
  double valore;

  // Date when the grade was recorded
  @HiveField(1)
  DateTime data;

  // Optional note about the grade
  @HiveField(2)
  String? descrizione;

  // Grade type: 'scritto', 'orale', or 'pratico'
  @HiveField(3)
  String tipo;

  // Create a grade with value, date, optional note, and type.
  Voto({
    required this.valore,
    required this.data,
    this.descrizione,
    this.tipo = 'scritto',
  });
}

@HiveType(typeId: 1)
class Materia extends HiveObject {
  // Subject name
  @HiveField(0)
  String nome;

  // Optional teacher name
  @HiveField(1)
  String? professore;

  // List of grades for this subject
  @HiveField(2)
  List<Voto> voti;

  // Create a subject with a name, optional teacher, and optional grades list.
  Materia({required this.nome, this.professore, List<Voto>? voti})
    : voti = voti ?? [];

  // Grades from September to December (first semester)
  List<Voto> get primoperiodo =>
      voti.where((v) => v.data.month >= 9 && v.data.month <= 12).toList();

  // Grades from January to June (second semester)
  List<Voto> get secondoperiodo =>
      voti.where((v) => v.data.month >= 1 && v.data.month <= 6).toList();

  // Compute the average of a list of grades, return 0 if empty
  double _mediaLista(List<Voto> lista) {
    if (lista.isEmpty) return 0;
    return lista.map((v) => v.valore).reduce((a, b) => a + b) / lista.length;
  }

  // Overall average for this subject
  double get media => _mediaLista(voti);
  // Average for first semester
  double get mediaPrimoPeriodo => _mediaLista(primoperiodo);
  // Average for second semester
  double get mediaSecondoPeriodo => _mediaLista(secondoperiodo);

  // Formatted overall average or 'N/D' when no grades
  String get mediaFormattata {
    if (voti.isEmpty) return 'N/D';
    return media.toStringAsFixed(2);
  }

  // Formatted average for a given list or 'N/D' when empty
  String mediaFormatataPeriodo(List<Voto> lista) {
    if (lista.isEmpty) return 'N/D';
    return _mediaLista(lista).toStringAsFixed(2);
  }

  // Trend comparing current average with the average before the last grade.
  // Returns 1 for rising, -1 for falling, 0 for stable or not enough data.
  int get tendenza {
    if (voti.length < 2) return 0;
    final mediaPrec = _mediaLista(voti.sublist(0, voti.length - 1));
    final mediaAtt = media;
    if ((mediaAtt - mediaPrec).abs() < 0.01) return 0;
    return mediaAtt > mediaPrec ? 1 : -1;
  }

  // Trend for a specific list of grades (e.g. a semester).
  int tendenzaPeriodo(List<Voto> lista) {
    if (lista.length < 2) return 0;
    final mediaPrec = _mediaLista(lista.sublist(0, lista.length - 1));
    final mediaAtt = _mediaLista(lista);
    if ((mediaAtt - mediaPrec).abs() < 0.01) return 0;
    return mediaAtt > mediaPrec ? 1 : -1;
  }

  // Calculate the grade needed in the next test to reach [target].
  // Returns null if already at or above target.
  // If a single grade cannot reach the target, the returned value may be > 10.
  double? votoNecessario(List<Voto> lista, {double target = 6.0}) {
    if (lista.isEmpty) return null;
    final media = _mediaLista(lista);
    if (media >= target) return null;
    final somma = lista.map((v) => v.valore).reduce((a, b) => a + b);
    return (target * (lista.length + 1)) - somma;
  }

  // Return the current semester index: 0 = first (Sep–Dec), 1 = second (Jan–Jun)
  static int periodoCorrente() {
    final mese = DateTime.now().month;
    if (mese >= 9 && mese <= 12) return 0;
    return 1;
  }
}
