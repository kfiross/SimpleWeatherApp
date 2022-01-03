// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherAdapter extends TypeAdapter<Weather> {
  @override
  final int typeId = 2;

  @override
  Weather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Weather(
      cityKey: fields[0] as String,
      conditions: fields[2] as String,
      iconNumber: fields[3] as int,
      temperature: fields[4] as Temperature,
      epochTime: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Weather obj) {
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
      other is WeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
