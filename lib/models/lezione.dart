import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'lezione.g.dart';

@HiveType(typeId: 2)
class Lezione extends HiveObject {
  @HiveField(0)
  String giorno;

  @HiveField(1)
  int ora;

  @HiveField(2)
  String materia;

  @HiveField(3)
  String? aula;

  @HiveField(4)
  int coloreValue;

  Lezione({
    required this.giorno,
    required this.ora,
    required this.materia,
    this.aula,
    Color colore = Colors.blue,
  }) : coloreValue = colore.value;

  Color get colore => Color(coloreValue);
  set colore(Color c) => coloreValue = c.value;
}
