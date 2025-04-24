// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Interface that may be used to manage a conversation.
class VIConversation {
  /// An universally unique identifier (UUID) of this conversation.
  final String uuid;

  /// Current conversation title.
  ///
  /// Note that changing this property value does not send changes to the cloud.
  /// Use [VIConversation.update] to send all changes at once
  String? title;

  /// Whether the conversation is direct.
  ///
  /// A direct conversation cannot be uber and/or public.
  ///
  /// There can be only 2 participants in a direct conversation which is unique and the only one for these participants.
  /// There cannot be more than 1 direct conversation for the same 2 users.
  ///
  /// If one of these users tries to create a new direct conversation with the same participant
  /// via [VIMessenger.createConversation] the method returns the UUID of the already existing direct conversation.
  final bool direct;

  /// Whether the conversation is uber.
  ///
  /// A uber conversation cannot be direct.
  ///
  /// Users in a uber conversation cannot retrieve messages that have been posted to the conversation after they quit.
  final bool uber;

  /// Whether the conversation is public.
  ///
  /// If true, anyone can join the conversation by UUID.
  ///
  /// A public conversation cannot be direct.
  ///
  /// Note that changing this property value does not send changes to the cloud.
  /// Use [VIConversation.update] to send all changes at once
  bool publicJoin;

  /// List of participants alongside with their permissions.
  final List<VIConversationParticipant> participants;

  /// UNIX timestamp (seconds) that specifies the time of the conversation creation.
  final int createdTime;

  /// Sequence of the last event in the conversation.
  final int lastSequence;

  /// UNIX timestamp (seconds) that specifies the time when one of [VIConversationEvent]
  /// or [VIMessageEvent] is the last triggered event in this conversation.
  final int lastUpdateTime;

  /// Custom data, up to 5kb.
  Map<String, dynamic> customData;

  final MethodChannel _methodChannel;

  /// Adds new participants to the conversation.
  ///
  /// It is possible only on the following conditions:
  ///
  /// - the participants are users of the main Voximplant developer account or its child accounts
  /// - the current user can manage other participants (ConversationParticipant.canManageParticipants() is true)
  /// - the conversation is not a direct one ([VIConversation.direct] is false)
  /// Duplicated users are ignored. Causes [VIException] if at least one user does not exist or already belongs to the conversation.
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about adding participants
  /// via the [VIMessenger.onEditConversation] callback.
  ///
  /// `participants` - List of [VIConversationParticipant] to be added to the conversation. Should not contain null(s), be null or empty list.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> addParticipants(
    List<VIConversationParticipant> participants,
  ) async {
    try {
      Map<String, dynamic>? data =
          await _methodChannel.invokeMapMethod('Messaging.addParticipants', {
        'conversation': uuid,
        'participants': participants.map((e) => e._toMap).toList(),
      });
      if (data == null) {
        _VILog._e('VIConversation: addParticipants: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:addParticipants: data was null',
        );
      }
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Edits participants permissions.
  /// It is possible only if the current user can manage other participants ([VIConversationParticipant.canManageParticipants] is true).
  ///
  /// Duplicated users are ignored. Causes [VIException] if at least one user does not exist or belong to the conversation.
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about editing participants
  /// via the [VIMessenger.onEditConversation] callback.
  ///
  /// `participants` - List of [VIConversationParticipant] to be edited in the conversation. Should not contain null(s), be null or empty list.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> editParticipants(
    List<VIConversationParticipant> participants,
  ) async {
    try {
      Map<String, dynamic>? data =
          await _methodChannel.invokeMapMethod('Messaging.editParticipants', {
        'conversation': uuid,
        'participants': participants.map((e) => e._toMap).toList(),
      });
      if (data == null) {
        _VILog._e('VIConversation: editParticipants: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:editParticipants: data was null',
        );
      }
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Removes participants from the conversation.
  ///
  /// It is possible only on two conditions:
  /// - the current user can manage other participants ([VIConversationParticipant.canManageParticipants] is true).
  /// - the conversation is not a direct one ([VIConversation.direct] is false)
  ///
  /// Duplicated users are ignored. Causes [VIException] if at least one user:
  /// - does not exist
  /// - is already removed
  ///
  /// Note that you can remove participants that are marked as deleted ([VIUser.isDeleted] is true).
  ///
  /// The removed users can later get this conversation's UUID via the [VIUser.leaveConversationList] property.
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about removing participants
  /// via the [VIMessenger.onEditConversation] callback.
  ///
  /// `participants` - List of [VIConversationParticipant] to be removed from the conversation. Should not contain null(s), be null or empty list.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> removeParticipants(
    List<VIConversationParticipant> participants,
  ) async {
    try {
      Map<String, dynamic>? data =
          await _methodChannel.invokeMapMethod('Messaging.removeParticipants', {
        'conversation': uuid,
        'participants': participants.map((e) => e._toMap).toList(),
      });
      if (data == null) {
        _VILog._e(
            'VIConversation: removeParticipants: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:removeParticipants: data was null',
        );
      }
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Sends the conversation changes to the cloud. The sent changes are: title, public join flag and custom data.
  ///
  /// Successful update happens if a participant is the owner ([VIConversationParticipant.isOwner] is true).
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> update() async {
    try {
      Map<String, dynamic>? data =
          await _methodChannel.invokeMapMethod('Messaging.updateConversation', {
        'conversation': uuid,
        'title': title,
        'publicJoin': publicJoin,
        'customData': customData,
      });
      if (data == null) {
        _VILog._e('VIConversation: update: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:update: data was null',
        );
      }
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Marks the event with the specified sequence as read.
  ///
  /// A method call with the specified sequence makes the [VIConversationParticipant.lastReadSequence] property return this sequence,
  /// i.e., such sequences can be get for each participant separately.
  ///
  /// If the sequence parameter specified less than 1,
  /// the method marks all the events as unread (for this participant)
  /// except the event with the sequence equals to '1'.
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about marking events as read
  /// via the [VIMessenger.onRead] callback.
  ///
  /// `sequence` - Sequence number of the event in the conversation to be marked as read. Should not be greater than currently possible.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationServiceEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationServiceEvent> markAsRead(int sequence) async {
    try {
      Map<String, dynamic>? data = await _methodChannel.invokeMapMethod(
          'Messaging.markAsRead', {'conversation': uuid, 'sequence': sequence});
      if (data == null) {
        _VILog._e('VIConversation: markAsRead: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:markAsRead: data was null',
        );
      }
      return VIConversationServiceEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Informs the cloud that the user is typing some text.
  ///
  /// The method calls within 10s interval from the last call cause [VIException].
  ///
  /// If the sequence parameter specified less than 1,
  /// the method marks all the events as unread (for this participant)
  /// except the event with the sequence equals to '1'.
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about typing
  /// via the [VIMessenger.onTyping] callback.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationServiceEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationServiceEvent> typing() async {
    try {
      Map<String, dynamic>? data = await _methodChannel
          .invokeMapMethod('Messaging.typing', {'conversation': uuid});
      if (data == null) {
        _VILog._e('VIConversation: typing: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:typing: data was null',
        );
      }
      return VIConversationServiceEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Sends a message to the conversation.
  ///
  /// Sending messages is available only for participants that
  /// have write permissions ([VIConversationParticipant.canWrite] is true).
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about sending messages to the conversation
  /// via the [VIMessenger.onSendMessage] callback.
  ///
  /// To be informed about sending messages while being offline,
  /// participants can subscribe to the [VIMessengerNotification.onSendMessage] messenger push notification.
  ///
  /// Optional `text` - Message text, maximum 5000 characters
  ///
  /// Optional `payload` - Message payload
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIMessageEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIMessageEvent> sendMessage({
    String? text,
    List<Map<String, Object>>? payload,
  }) async {
    try {
      Map<String, dynamic>? data = await _methodChannel.invokeMapMethod(
          'Messaging.sendMessage',
          {'conversation': uuid, 'text': text, 'payload': payload});
      if (data == null) {
        _VILog._e('VIConversation: sendMessage: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:sendMessage: data was null',
        );
      }
      return VIMessageEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Requests events in the specified sequence range to be sent from the cloud to this client.
  ///
  /// Only [VIConversationEvent] and [VIMessageEvent] events can be retransmitted;
  /// any other events cannot be retransmitted.
  ///
  /// The method is used to get history or missed events in case of network disconnect.
  /// Client should use this method to request all events based on the last event sequence received from the cloud
  /// and last event sequence saved locally (if any).
  ///
  /// The maximum number of retransmitted events per method call is 100.
  /// Requesting more than 100 events causes [VIException].
  ///
  /// If the current user quits a [VIConversation.uber] conversation,
  /// messages that are posted during the user's absence are not retransmitted later.
  ///
  /// `from` - First event in sequence range, inclusive
  ///
  /// `to` - Last event in sequence range, inclusive
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIRetransmitEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIRetransmitEvent> retransmitEvents(int from, int to) async {
    try {
      Map<String, dynamic>? data = await _methodChannel.invokeMapMethod(
          'Messaging.retransmitEvents',
          {'conversation': uuid, 'from': from, 'to': to});
      if (data == null) {
        _VILog._e('VIConversation: retransmitEvents: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:retransmitEvents: data was null',
        );
      }
      return VIRetransmitEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Requests a number of events starting with the specified sequence to be sent from the cloud to this client.
  ///
  /// Only [VIConversationEvent] and [VIMessageEvent] events can be retransmitted;
  /// any other events cannot be retransmitted.
  ///
  /// The method is used to get history or missed events in case of network disconnect.
  /// Client should use this method to request all events based on the last event sequence received from the cloud
  /// and last event sequence saved locally (if any).
  ///
  /// The maximum number of retransmitted events per method call is 100.
  /// Requesting more than 100 events causes [VIException].
  ///
  /// If the current user quits a [VIConversation.uber] conversation,
  /// messages that are posted during the user's absence are not retransmitted later.
  ///
  /// `from` - First event in sequence range, inclusive
  ///
  /// `count` - Number of events
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIRetransmitEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIRetransmitEvent> retransmitEventsFrom(int from, int count) async {
    try {
      Map<String, dynamic>? data = await _methodChannel.invokeMapMethod(
          'Messaging.retransmitEventsFrom',
          {'conversation': uuid, 'from': from, 'count': count});
      if (data == null) {
        _VILog._e('VIConversation: retransmitEvents: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:retransmitEvents: data was null',
        );
      }
      return VIRetransmitEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Requests a number of events up to the specified sequence to be sent from the cloud to this client.
  ///
  /// Only [VIConversationEvent] and [VIMessageEvent] events can be retransmitted;
  /// any other events cannot be retransmitted.
  ///
  /// The method is used to get history or missed events in case of network disconnect.
  /// Client should use this method to request all events based on the last event sequence received from the cloud
  /// and last event sequence saved locally (if any).
  ///
  /// The maximum number of retransmitted events per method call is 100.
  /// Requesting more than 100 events causes [VIException].
  ///
  /// If the current user quits a [VIConversation.uber] conversation,
  /// messages that are posted during the user's absence are not retransmitted later.
  ///
  /// `to` - Last event in sequence range, inclusive
  ///
  /// `count` - Number of events
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIRetransmitEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIRetransmitEvent> retransmitEventsTo(int to, int count) async {
    try {
      Map<String, dynamic>? data = await _methodChannel.invokeMapMethod(
          'Messaging.retransmitEventsTo',
          {'conversation': uuid, 'to': to, 'count': count});
      if (data == null) {
        _VILog._e('VIConversation: retransmitEvents: data was null, skipping');
        throw VIException(
          VIMessagingError.ERROR_INTERNAL,
          'VIConversation:retransmitEvents: data was null',
        );
      }
      return VIRetransmitEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  VIConversation._recreate(
    VIConversationConfig config,
    this.uuid,
    this.lastSequence,
    this.lastUpdateTime,
    this.createdTime,
  )   : title = config.title,
        direct = config.direct,
        uber = config.uber,
        publicJoin = config.publicJoin,
        participants = config.participants,
        customData = config.customData,
        _methodChannel = Voximplant._channel;

  VIConversation._fromMap(Map<dynamic, dynamic> map)
      : uuid = map['uuid'],
        title = map['title'],
        direct = map['direct'],
        uber = map['uber'],
        publicJoin = map['publicJoin'],
        participants = (map['participants'] as List?)
                ?.map((e) => VIConversationParticipant._fromMap(e))
                .toList() ??
            [],
        createdTime = map['createdTime'],
        lastSequence = map['lastSequence'],
        lastUpdateTime = map['lastUpdateTime'],
        customData = map['customData']?.cast<String, dynamic>() ?? {},
        _methodChannel = Voximplant._channel;
}

/// Configuration either to create a new conversation or restore a previously created conversation:
/// - [VIMessenger.createConversation]
/// - [VIMessenger.recreateConversation]
class VIConversationConfig {
  /// Whether a conversation is configured as direct or not.
  ///
  /// There can be only 2 participants in a direct conversation which is unique and the only one for these participants.
  /// There cannot be more than 1 direct conversation for the same 2 users.
  ///
  /// If one of these users tries to create a new direct conversation with the same participant
  /// via [VIMessenger.createConversation],
  /// the method returns the UUID of the already existing direct conversation.
  ///
  /// A direct conversation cannot be uber and/or public.
  bool direct;

  /// Whether a conversation is configured as public or not.
  ///
  /// If true, any user can join the conversation via [VIMessenger.joinConversation] by specifying its UUID.
  /// Use the [VIMessenger.getPublicConversations] method to retrieve all public conversations' UUIDs.
  ///
  /// A public conversation cannot be direct.
  bool publicJoin;

  /// Whether a conversation is configured as uber or not.
  ///
  /// Users in a uber conversation cannot retrieve messages that have been sent to the conversation after they quit.
  ///
  /// A uber conversation cannot be direct.
  bool uber;

  /// Gets the title
  String? title;

  /// Gets the custom data
  Map<String, Object> customData;

  /// Gets the list of conversation participants
  List<VIConversationParticipant> participants;

  VIConversationConfig({
    this.direct = false,
    this.publicJoin = false,
    this.uber = false,
    this.title,
    this.customData = const {},
    this.participants = const [],
  });

  Map<String, Object?> get _toMap => {
        'direct': direct,
        'publicJoin': publicJoin,
        'uber': uber,
        'title': title,
        'customData': customData,
        'participants': participants.map((e) => e._toMap).toList()
      };
}
