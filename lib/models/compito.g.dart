// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compito.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompitoAdapter extends TypeAdapter<Compito> {
  @override
  final int typeId = 4;

  @override
  Compito read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Compito(
      materia: fields[0] as String,
      descrizione: fields[1] as String,
      dataConsegna: fields[2] as DateTime,
      tipo: fields[3] as TipoCompito,
      completato: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Compito obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.materia)
      ..writeByte(1)
      ..write(obj.descrizione)
      ..writeByte(2)
      ..write(obj.dataConsegna)
      ..writeByte(3)
      ..write(obj.tipo)
      ..writeByte(4)
      ..write(obj.completato);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompitoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipoCompitoAdapter extends TypeAdapter<TipoCompito> {
  @override
  final int typeId = 3;

  @override
  TipoCompito read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoCompito.compito;
      case 1:
        return TipoCompito.verifica;
      case 2:
        return TipoCompito.interrogazione;
      default:
        return TipoCompito.compito;
    }
  }

  @override
  void write(BinaryWriter writer, TipoCompito obj) {
    switch (obj) {
      case TipoCompito.compito:
        writer.writeByte(0);
        break;
      case TipoCompito.verifica:
        writer.writeByte(1);
        break;
      case TipoCompito.interrogazione:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoCompitoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
