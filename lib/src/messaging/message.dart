/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Interface that represents message within a conversation.
class VIMessage {
  /// The universally unique identifier (UUID) of the message.
  final String uuid;

  /// The UUID of the conversation this message belongs to.
  ///
  /// The message can belong to the one conversation only.
  final String conversation;

  /// The message sequence number in the conversation.
  final int sequence;

  /// The text of this message.
  final String text;

  /// The list of payload objects associated with the message.
  final List<Map<String, dynamic>> payload;

  final MethodChannel _methodChannel;

  /// Send text and payload changes to the cloud.
  ///
  /// The participant that calls this method should have:
  ///
  /// - the [VIConversationParticipant.canEditMessages] permission to update its own messages
  /// - the [VIConversationParticipant.canEditAllMessages] permission to update other participants' messages
  ///
  /// To be informed about the message updating while being offline,
  /// participants can subscribe to the [VIMessengerNotification.onEditMessage] messenger push notification.
  ///
  /// Optional `text` - New text of this message, maximum 5000 characters. If null, message text will not be updated.
  ///
  /// Optional `payload` - New payload of this message. If null, message payload will not be updated.
  Future<VIMessageEvent> update({
    String? text,
    List<Map<String, Object>>? payload,
  }) async {
    try {
      Map<String, dynamic>? data = await _methodChannel.invokeMapMethod(
        'Messaging.updateMessage',
        {
          'conversation': conversation,
          'message': uuid,
          'text': text ?? this.text,
          'payload': payload ?? this.payload
        },
      );
      if (data == null) {
        _VILog._e('VIMessage: update: data was null, skipping');
        throw VIMessagingError.ERROR_INTERNAL;
      }
      return VIMessageEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Remove the message from the conversation.
  ///
  /// The participant that calls this method should have:
  ///
  /// - the [VIConversationParticipant.canRemoveMessages] permission to remove its own messages
  /// - the [VIConversationParticipant.canRemoveAllMessages] permission to remove other participants' messages
  Future<VIMessageEvent> remove() async {
    try {
      Map<String, dynamic>? data = await _methodChannel.invokeMapMethod(
        'Messaging.removeMessage',
        {'conversation': conversation, 'message': uuid},
      );
      if (data == null) {
        _VILog._e('VIMessage: remove: data was null, skipping');
        throw VIMessagingError.ERROR_INTERNAL;
      }
      return VIMessageEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  VIMessage._recreate(
    this.uuid,
    this.conversation,
    this.text,
    this.payload,
    this.sequence,
  ) : this._methodChannel = Voximplant._channel;

  VIMessage._fromMap(Map<dynamic, dynamic> map)
      : this.uuid = map['uuid'],
        this.conversation = map['conversation'],
        this.sequence = map['sequence'],
        this.text = map['text'],
        this.payload = (map['payload'] as List<dynamic>)
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
        this._methodChannel = Voximplant._channel;
}
