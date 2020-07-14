/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Base interface that represents all messenger events provided
/// via [VIMessenger] callbacks or as a result of method calls.
abstract class VIMessengerEvent {

  /// The IM id for the user that initiated the event.
  final int imUserId;

  /// The action that triggered this event.
  final VIMessengerAction action;

  /// The messenger event type.
  final VIMessengerEventType type;

  VIMessengerEvent._fromMap(Map<dynamic, dynamic> map)
      : this.imUserId = map['id'],
        this.action = VIMessengerAction.values[map['action']],
        this.type = VIMessengerEventType.values[map['type']];
}

/// Enum that represents actions that trigger messenger events. Each action is the reason for every triggered event.
///
/// For example, when the [VIMessenger.onEditConversation] event is invoked,
/// users can inspect the exact reason of it via [VIMessengerEvent.action].
/// In case of editing a conversation, it will be one of the following:
///
/// - [VIMessengerAction.addParticipants]
/// - [VIMessengerAction.editParticipants]
/// - [VIMessengerAction.removeParticipants]
/// - [VIMessengerAction.editConversation]
/// - [VIMessengerAction.joinConversation]
/// - [VIMessengerAction.leaveConversation]
enum VIMessengerAction {
  unknown,
  addParticipants,
  createConversation,
  editConversation,
  editMessage,
  editParticipants,
  editUser,
  getConversation,
  getConversations,
  getSubscriptions,
  getPublicConversations,
  getUser,
  getUsers,
  read,
  joinConversation,
  leaveConversation,
  manageNotifications,
  removeConversation,
  removeMessage,
  removeParticipants,
  retransmitEvents,
  sendMessage,
  setStatus,
  subscribe,
  typing,
  unsubscribe,
}

/// Enum that represents types of messenger events.
enum VIMessengerEventType {
  unknown,
  read,
  createConversation,
  editConversation,
  editMessage,
  editUser,
  getConversation,
  getPublicConversations,
  getSubscriptions,
  getUser,
  removeConversation,
  removeMessage,
  retransmitEvents,
  sendMessage,
  setStatus,
  subscribe,
  typing,
  unsubscribe
}
