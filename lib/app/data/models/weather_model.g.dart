// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherModelAdapter extends TypeAdapter<WeatherModel> {
  @override
  final int typeId = 3;

  @override
  WeatherModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherModel(
      cityKey: fields[0] as String?,
      epochTime: fields[1] as int?,
      temperature: fields[4] as TemperatureModel?,
      conditions: fields[2] as String?,
      iconNumber: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cityKey)
      ..writeByte(1)
      ..write(obj.epochTime)
      ..writeByte(2)
      ..write(obj.conditions)
      ..writeByte(3)
      ..write(obj.iconNumber)
      ..writeByte(4)
      ..write(obj.temperature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
