import 'package:hive/hive.dart';
import 'package:missingpersonapp/features/chat/models/chat_session.dart';
import 'package:missingpersonapp/features/chat/models/message.dart';

class HiveAdapters {
  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MessageAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChatSessionAdapter());
    }
  }
}

class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 0;

  @override
  MessageStatus read(BinaryReader reader) {
    try {
      final index = reader.readByte();
      return MessageStatus.values.elementAtOrNull(index) ?? MessageStatus.unknown;
    } catch (e) {
      return MessageStatus.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    writer.writeByte(obj.index);
  }
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    return Message(
      id: reader.read(),
      senderId: reader.read(),
      receiverId: reader.read(),
      content: reader.read(),
      timestamp: reader.read(),
      imageBase64: reader.read(),
      status: MessageStatus.values.elementAtOrNull(reader.readByte()) ?? MessageStatus.unknown,
      read: reader.read(),
      senderName: reader.read(),
      receiverName: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer.write(obj.id);
    writer.write(obj.senderId);
    writer.write(obj.receiverId);
    writer.write(obj.content);
    writer.write(obj.timestamp);
    writer.write(obj.imageBase64);
    writer.writeByte(obj.status.index);
    writer.write(obj.read);
    writer.write(obj.senderName);
    writer.write(obj.receiverName);
  }
}

class ChatSessionAdapter extends TypeAdapter<ChatSession> {
  @override
  final int typeId = 2;

  @override
  ChatSession read(BinaryReader reader) {
    return ChatSession(
      partnerId: reader.read(),
      partnerName: reader.read(),
      lastMessage: reader.read(),
      timestamp: reader.read(),
      isRead: reader.read(),
      unreadCount: reader.read(),
      imageBase64: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatSession obj) {
    writer.write(obj.partnerId);
    writer.write(obj.partnerName);
    writer.write(obj.lastMessage);
    writer.write(obj.timestamp);
    writer.write(obj.isRead);
    writer.write(obj.unreadCount);
    writer.write(obj.imageBase64);
  }
}
