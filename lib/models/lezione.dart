import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'lezione.g.dart';

@HiveType(typeId: 2)
class Lezione extends HiveObject {
  // Day short name, e.g. 'Lun', 'Mar', 'Mer'
  @HiveField(0)
  String giorno;

  // Lesson slot number in the day (1..8)
  @HiveField(1)
  int ora;

  // Subject name for this lesson
  @HiveField(2)
  String materia;

  // Optional classroom or room name
  @HiveField(3)
  String? aula;

  // Color stored as ARGB integer because Hive cannot store Color directly
  @HiveField(4)
  int coloreValue;

  // Create a lesson. Color is stored as an integer for Hive.
  Lezione({
    required this.giorno,
    required this.ora,
    required this.materia,
    this.aula,
    Color colore = Colors.blue,
  }) : coloreValue = colore.value;

  // Convert stored integer back to a Flutter Color.
  Color get colore => Color(coloreValue);

  // Save a Flutter Color by storing its integer value.
  set colore(Color c) => coloreValue = c.value;
}
