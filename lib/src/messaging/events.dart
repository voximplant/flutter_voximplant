// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Interface that represents messenger events related to users, such as get or edit user.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIUserEvent extends VIMessengerEvent {
  /// VIUser instance with the user details.
  final VIUser user;

  VIUserEvent._fromMap(super.map)
      : user = VIUser._fromMap(map['user']),
        super._fromMap();
}

/// Interface that represents the messenger events for the following methods call result:
///
/// - [VIConversation.retransmitEvents],
/// - [VIConversation.retransmitEventsFrom],
/// - [VIConversation.retransmitEventsTo]
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIRetransmitEvent extends VIMessengerEvent {
  /// List of the event objects that have been retransmitted.
  final List<VIMessengerEvent> events;

  /// Event sequence number from which the events have been retransmitted.
  final int fromSequence;

  /// Event sequence number to which the events have been retransmitted.
  final int toSequence;

  VIRetransmitEvent._fromMap(super.map)
      : events = (map['events'] as List?)
                ?.cast<Map<dynamic, dynamic>>()
                .map((e) => e['conversation'] == null
                    ? VIMessageEvent._fromMap(e)
                    : VIConversationEvent._fromMap(e))
                .toList()
                .cast<VIMessengerEvent>() ??
            [],
        fromSequence = map['fromSequence'],
        toSequence = map['toSequence'],
        super._fromMap();
}

/// Interface that represents messenger events related to messages (send, update, remove).
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIMessageEvent extends VIMessengerEvent {
  /// VIMessage instance with the message information.
  final VIMessage message;

  /// Sequence number for this event.
  final int sequence;

  /// UNIX timestamp (seconds) that specifies the time the message event has been triggered.
  final int timestamp;

  VIMessageEvent._fromMap(super.map)
      : message = VIMessage._fromMap(map['message']),
        sequence = map['sequence'],
        timestamp = map['timestamp'],
        super._fromMap();
}

/// Interface that represents messenger events related to conversations such as create, edit, remove, etc.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIConversationEvent extends VIMessengerEvent {
  /// VIConversation with the conversation details.
  final VIConversation conversation;

  /// Sequence number of this event.
  final int sequence;

  /// UNIX timestamp (seconds) that specifies the time the conversation event has been triggered.
  final int timestamp;

  VIConversationEvent._fromMap(super.map)
      : conversation = VIConversation._fromMap(map['conversation']),
        sequence = map['sequence'],
        timestamp = map['timestamp'],
        super._fromMap();
}

/// Interface that represents the messenger events related to user status changes.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIStatusEvent extends VIMessengerEvent {
  /// The user status.
  final bool isOnline;

  VIStatusEvent._fromMap(super.map)
      : isOnline = map['isOnline'],
        super._fromMap();
}

/// Interface that represents the messenger events related to subscriptions.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VISubscriptionEvent extends VIMessengerEvent {
  /// The list of the IM user identifiers of the current (un)subscription.
  final List<int> users;

  VISubscriptionEvent._fromMap(super.map)
      : users = (map['users'] as List?)?.cast<int>() ?? [],
        super._fromMap();
}

/// Interface that represents messenger events such as typing, isRead.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIConversationServiceEvent extends VIMessengerEvent {
  /// The conversation UUID associated with this event.
  final String conversationUuid;

  /// The sequence number of the event that is marked as read by the user initiated this event.
  /// Only available for [VIMessengerEventType.read].
  final int sequence;

  VIConversationServiceEvent._fromMap(super.map)
      : conversationUuid = map['conversationUuid'],
        sequence = map['sequence'],
        super._fromMap();
}

/// Interface that represents messenger events related to conversation enumeration.
///
/// Extends [VIMessengerEvent] which provides service information (IM user id, action, event type).
class VIConversationListEvent extends VIMessengerEvent {
  /// The list of conversations UUIDs.
  final List<String> conversationList;

  VIConversationListEvent._fromMap(super.map)
      : conversationList =
            (map['conversationList'] as List?)?.cast<String>() ?? [],
        super._fromMap();
}
