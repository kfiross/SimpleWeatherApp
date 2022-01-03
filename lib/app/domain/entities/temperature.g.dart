// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TemperatureAdapter extends TypeAdapter<Temperature> {
  @override
  final int typeId = 4;

  @override
  Temperature read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Temperature(
      fields[0] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Temperature obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.celsius);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemperatureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
