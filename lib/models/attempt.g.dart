// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttemptAdapter extends TypeAdapter<Attempt> {
  @override
  final int typeId = 3;

  @override
  Attempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Attempt(
      attemptId: fields[0] as String,
      date: fields[1] as DateTime,
      messages: (fields[2] as List).cast<LocalMessage>(),
    );
  }

  @override
  void write(BinaryWriter writer, Attempt obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.attemptId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
