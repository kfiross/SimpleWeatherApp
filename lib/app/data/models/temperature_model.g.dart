// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TemperatureModelAdapter extends TypeAdapter<TemperatureModel> {
  @override
  final int typeId = 5;

  @override
  TemperatureModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemperatureModel(
      fields[0] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TemperatureModel obj) {
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
      other is TemperatureModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
