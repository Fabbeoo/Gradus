import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'materia.g.dart';

@HiveType(typeId: 0)
class Voto extends HiveObject {
  @HiveField(0)
  double valore;

  @HiveField(1)
  DateTime data;

  @HiveField(2)
  String? descrizione;

  @HiveField(3)
  String tipo;

  Voto({
    required this.valore,
    required this.data,
    this.descrizione,
    this.tipo = 'scritto',
  });
}

@HiveType(typeId: 1)
class Materia extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String? professore;

  @HiveField(2)
  List<Voto> voti;

  Materia({required this.nome, this.professore, List<Voto>? voti})
    : voti = voti ?? [];

  List<Voto> get primoperiodo =>
      voti.where((v) => v.data.month >= 9 && v.data.month <= 12).toList();

  List<Voto> get secondoperiodo =>
      voti.where((v) => v.data.month >= 1 && v.data.month <= 6).toList();

  double _mediaLista(List<Voto> lista) {
    if (lista.isEmpty) return 0;
    return lista.map((v) => v.valore).reduce((a, b) => a + b) / lista.length;
  }

  double get media => _mediaLista(voti);
  double get mediaPrimoPeriodo => _mediaLista(primoperiodo);
  double get mediaSecondoPeriodo => _mediaLista(secondoperiodo);

  String get mediaFormattata {
    if (voti.isEmpty) return 'N/D';
    return media.toStringAsFixed(2);
  }

  String mediaFormatataPeriodo(List<Voto> lista) {
    if (lista.isEmpty) return 'N/D';
    return _mediaLista(lista).toStringAsFixed(2);
  }

  int get tendenza {
    if (voti.length < 2) return 0;
    final mediaPrec = _mediaLista(voti.sublist(0, voti.length - 1));
    final mediaAtt = media;
    if ((mediaAtt - mediaPrec).abs() < 0.01) return 0;
    return mediaAtt > mediaPrec ? 1 : -1;
  }

  int tendenzaPeriodo(List<Voto> lista) {
    if (lista.length < 2) return 0;
    final mediaPrec = _mediaLista(lista.sublist(0, lista.length - 1));
    final mediaAtt = _mediaLista(lista);
    if ((mediaAtt - mediaPrec).abs() < 0.01) return 0;
    return mediaAtt > mediaPrec ? 1 : -1;
  }

  double? votoNecessario(List<Voto> lista, {double target = 6.0}) {
    if (lista.isEmpty) return null;
    final media = _mediaLista(lista);
    if (media >= target) return null;
    final somma = lista.map((v) => v.valore).reduce((a, b) => a + b);
    return (target * (lista.length + 1)) - somma;
  }

  static int periodoCorrente() {
    final mese = DateTime.now().month;
    if (mese >= 9 && mese <= 12) return 0;
    return 1;
  }
}
