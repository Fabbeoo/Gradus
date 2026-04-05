// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lezione.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LezioneAdapter extends TypeAdapter<Lezione> {
  @override
  final int typeId = 2;

  @override
  Lezione read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lezione(
      giorno: fields[0] as String,
      ora: fields[1] as int,
      materia: fields[2] as String,
      aula: fields[3] as String?,
    )..coloreValue = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, Lezione obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.giorno)
      ..writeByte(1)
      ..write(obj.ora)
      ..writeByte(2)
      ..write(obj.materia)
      ..writeByte(3)
      ..write(obj.aula)
      ..writeByte(4)
      ..write(obj.coloreValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LezioneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
