// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      senderId: fields[1] as String,
      receiverId: fields[2] as String,
      content: fields[3] as String,
      timestamp: fields[4] as DateTime,
      imageBase64: fields[5] as String?,
      status: fields[6] as MessageStatus,
      read: fields[7] as bool,
      senderName: fields[8] as String?,
      receiverName: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.receiverId)
      ..writeByte(8)
      ..write(obj.senderName)
      ..writeByte(9)
      ..write(obj.receiverName)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.imageBase64)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.read);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 0;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.sent;
      case 1:
        return MessageStatus.delivered;
      case 2:
        return MessageStatus.read;
      case 3:
        return MessageStatus.sending;
      case 4:
        return MessageStatus.error;
      case 5:
        return MessageStatus.unknown;
      default:
        return MessageStatus.sent;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    switch (obj) {
      case MessageStatus.sent:
        writer.writeByte(0);
        break;
      case MessageStatus.delivered:
        writer.writeByte(1);
        break;
      case MessageStatus.read:
        writer.writeByte(2);
        break;
      case MessageStatus.sending:
        writer.writeByte(3);
        break;
      case MessageStatus.error:
        writer.writeByte(4);
        break;
      case MessageStatus.unknown:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
