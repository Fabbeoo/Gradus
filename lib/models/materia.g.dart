// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'materia.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VotoAdapter extends TypeAdapter<Voto> {
  @override
  final int typeId = 0;

  @override
  Voto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Voto(
      valore: fields[0] as double,
      data: fields[1] as DateTime,
      descrizione: fields[2] as String?,
      tipo: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Voto obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.valore)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.descrizione)
      ..writeByte(3)
      ..write(obj.tipo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MateriaAdapter extends TypeAdapter<Materia> {
  @override
  final int typeId = 1;

  @override
  Materia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Materia(
      nome: fields[0] as String,
      professore: fields[1] as String?,
      voti: (fields[2] as List?)?.cast<Voto>(),
    );
  }

  @override
  void write(BinaryWriter writer, Materia obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.professore)
      ..writeByte(2)
      ..write(obj.voti);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MateriaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
