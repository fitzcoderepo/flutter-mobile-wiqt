// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiqc_notifications.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WiqcNotificationAdapter extends TypeAdapter<WiqcNotification> {
  @override
  final int typeId = 1;

  @override
  WiqcNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WiqcNotification(
      title: fields[0] as String,
      body: fields[1] as String,
      payload: (fields[2] as Map).cast<String, dynamic>(),
      isRead: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, WiqcNotification obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.body)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiqcNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
