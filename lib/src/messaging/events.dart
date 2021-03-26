/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Interface that represents messenger events related to users, such as get or edit user.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIUserEvent extends VIMessengerEvent {
  /// VIUser instance with the user details.
  final VIUser user;

  VIUserEvent._fromMap(Map<dynamic, dynamic> map)
      : this.user = VIUser._fromMap(map['user']),
        super._fromMap(map);
}

/// Interface that represents the messenger events for the following methods call result:
///
/// - [VIConversation.retransmitEvents],
/// - [VIConversation.retransmitEventsFrom],
/// - [VIConversation.retransmitEventsTo]
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIRetransmitEvent extends VIMessengerEvent {
  /// The list of the event objects that were retransmitted.
  final List<VIMessengerEvent> events;

  /// The event sequence number from which the events were retransmitted.
  final int fromSequence;

  /// The event sequence number to which the events were retransmitted.
  final int toSequence;

  VIRetransmitEvent._fromMap(Map<dynamic, dynamic> map)
      : this.events = (map['events'] as List)
            .cast<Map<dynamic, dynamic>>()
            .map((e) => e['conversation'] == null
                ? VIMessageEvent._fromMap(e)
                : VIConversationEvent._fromMap(e))
            .toList()
            .cast<VIMessengerEvent>(),
        this.fromSequence = map['fromSequence'],
        this.toSequence = map['toSequence'],
        super._fromMap(map);
}

/// Interface that represents messenger events related to messages (send, update, remove).
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIMessageEvent extends VIMessengerEvent {
  /// VIMessage instance with the message information.
  final VIMessage message;

  /// The sequence number for this event.
  final int sequence;

  /// The UNIX timestamp (seconds) that specifies the time the message event was provoked.
  final int timestamp;

  VIMessageEvent._fromMap(Map<dynamic, dynamic> map)
      : this.message = VIMessage._fromMap(map['message']),
        this.sequence = map['sequence'],
        this.timestamp = map['timestamp'],
        super._fromMap(map);
}

/// Interface that represents messenger events related to conversations such as create, edit, remove, etc.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIConversationEvent extends VIMessengerEvent {
  /// VIConversation with the conversation details.
  final VIConversation conversation;

  /// The sequence number of this event.
  final int sequence;

  /// The UNIX timestamp (seconds) that specifies the time the conversation event was provoked.
  final int timestamp;

  VIConversationEvent._fromMap(Map<dynamic, dynamic> map)
      : this.conversation = VIConversation._fromMap(map['conversation']),
        this.sequence = map['sequence'],
        this.timestamp = map['timestamp'],
        super._fromMap(map);
}

/// Interface that represents the messenger events related to user status changes.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIStatusEvent extends VIMessengerEvent {
  /// The user status.
  final bool isOnline;

  VIStatusEvent._fromMap(Map<dynamic, dynamic> map)
      : this.isOnline = map['isOnline'],
        super._fromMap(map);
}

/// Interface that represents the messenger events related to subscriptions.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VISubscriptionEvent extends VIMessengerEvent {
  /// The list of the IM user identifiers of the current (un)subscription.
  final List<int> users;

  VISubscriptionEvent._fromMap(Map<dynamic, dynamic> map)
      : this.users = (map['users'] as List).cast<int>(),
        super._fromMap(map);
}

/// Interface that represents messenger events such as typing, isRead.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIConversationServiceEvent extends VIMessengerEvent {
  /// The conversation UUID associated with this event.
  final String conversationUuid;

  /// The sequence number of the event that was marked as read by the user initiated this event.
  /// Only available for [VIMessengerEventType.read].
  final int sequence;

  VIConversationServiceEvent._fromMap(Map<dynamic, dynamic> map)
      : this.conversationUuid = map['conversationUuid'],
        this.sequence = map['sequence'],
        super._fromMap(map);
}

/// Interface that represents messenger events related to conversation enumeration.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIConversationListEvent extends VIMessengerEvent {
  /// The list of conversations UUIDs.
  final List<String> conversationList;

  VIConversationListEvent._fromMap(Map<dynamic, dynamic> map)
      : this.conversationList =
            (map['conversationList'] as List).cast<String>(),
        super._fromMap(map);
}
