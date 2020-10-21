/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Signature for callbacks reporting that an user was edited
/// as the result of [VIMessenger.editUser], [VIMessenger.managePushNotifications]
/// or analogous methods from other Voximplant SDKs and Messaging API.
///
/// Used in [VIMessenger].
///
/// Triggered only for the subscribers of the changed user.
/// Use [VIMessenger.subscribe] to subscribe for user's changes.
///
/// `userEvent` - VIUserEvent object with user data and service information
typedef void VIEditUser(VIUserEvent userEvent);

/// Signature for callbacks reporting that the current user has subscribed to
/// other users changes
///
/// Used in [VIMessenger].
///
/// Triggered on all logged in clients of the current user
///
/// `subscriptionEvent` - VISubscriptionEvent object with subscription data and service information
typedef void VISubscribe(VISubscriptionEvent subscriptionEvent);

/// Signature for callbacks reporting that the current user has unsubscribed from
/// other users changes.
///
/// Used in [VIMessenger].
///
/// Triggered on all logged in clients of the current user as a result of [VIMessenger.unsubscribe]
/// or [VIMessenger.unsubscribeFromAll] method calls.
///
/// `subscriptionEvent` - VISubscriptionEvent object with subscription data and service information
typedef void VIUnsubscribe(VISubscriptionEvent subscriptionEvent);

/// Signature for callbacks reporting that a conversation was created via [VIMessenger.createConversation]
/// or analogous methods from other Voximplant SDKs and Messaging API.
///
/// Used in [VIMessenger].
///
/// Triggered only for participants that belong to the conversation.
///
/// `conversationEvent` - VIConversationEvent object with conversation data and service information
typedef void VICreateConversation(VIConversationEvent conversationEvent);

/// Signature for callbacks reporting that a conversation was removed.
///
/// Used in [VIMessenger].
///
/// It provides a [VIConversationEvent] instance
///
/// `conversationEvent` - VIConversationEvent object with conversation data and service information
typedef void VIRemoveConversation(VIConversationEvent conversationEvent);

/// Signature for callbacks reporting that the conversation properties were modified as the result of:
/// - [VIMessenger.joinConversation]
/// - [VIMessenger.leaveConversation]
/// - [VIConversation.update]
/// - [VIConversation.addParticipants]
/// - [VIConversation.removeParticipants]
/// - [VIConversation.editParticipants]
/// - or analogous methods from other Voximplant SDKs and Messaging API
///
/// Used in [VIMessenger].
///
/// It provides a [VIConversationEvent] instance
///
/// `conversationEvent` - VIConversationEvent object with conversation data and service information
typedef void VIEditConversation(VIConversationEvent conversationEvent);

/// Signature for callbacks reporting that an user changed status via
/// [VIMessenger.setStatus] or analogous methods from other Voximplant SDKs
/// and Messaging API.
///
/// Used in [VIMessenger].
///
/// Triggered only for the subscribers of the changed user.
/// Use [VIMessenger.subscribe] to subscribe for a user's changes.
///
/// `statusEvent` - VIStatusEvent object with user status data and service information
typedef void VISetStatus(VIStatusEvent statusEvent);

/// Signature for callbacks reporting that a message was edited via [VIMessage.update]
/// or analogous methods from other Voximplant SDKs and Messaging API.
///
/// Used in [VIMessenger].
///
/// Triggered only for participants that belong to the conversation
/// with the changed message.
///
/// `messageEvent` - VIMessageEvent object with message data and service information
typedef void VIEditMessage(VIMessageEvent messageEvent);

/// Signature for callbacks reporting that a message was sent via [VIConversation.sendMessage]
/// or analogous methods from other Voximplant SDKs and Messaging API.
///
/// Used in [VIMessenger].
///
/// Triggered only for participants that belong to the conversation.
///
/// `messageEvent` - VIMessageEvent object with message data and service information
typedef void VISendMessage(VIMessageEvent messageEvent);

/// Signature for callbacks reporting that a message was removed via [VIMessage.remove]
/// or analogous methods from other Voximplant SDKs and Messaging API.
///
/// Used in [VIMessenger].
///
/// Triggered only for participants that belong to the conversation with the deleted message.
///
/// `messageEvent` - VIMessageEvent object with message data and service information
typedef void VIRemoveMessage(VIMessageEvent messageEvent);

/// Signature for callbacks reporting that a participant types a message in a conversation.
/// Information about typing is sent via [VIConversation.typing]
/// or analogous methods from other Voximplant SDKs and Messaging API.
///
/// Used in [VIMessenger].
///
/// Triggered only for participants that belong to the conversation where typing is performing.
///
/// `conversationServiceEvent` - VIConversationServiceEvent object with conversation UUID and service information
typedef void VITyping(VIConversationServiceEvent conversationServiceEvent);

/// Signature for callbacks reporting that the event within a conversatio was
/// marked as read as the result of [VIConversation.markAsRead]
/// or analogous methods from other Voximplant SDKs and Messaging API.
///
/// Used in [VIMessenger].
///
/// Invoked for all clients in the conversation
///
/// `conversationServiceEvent` - VIConversationServiceEvent object with conversation UUID and service information
typedef void VIIsRead(VIConversationServiceEvent conversationServiceEvent);

/// Interface that may be used to control messaging functions.
class VIMessenger {
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel =
      EventChannel('plugins.voximplant.com/messaging');

  /// Callback for getting notified when an user changes
  VIEditUser onEditUser;

  /// Callback for getting notified about new subscriptions.
  VISubscribe onSubscribe;

  /// Callback for getting notified about changes in current subscriptions.
  VIUnsubscribe onUnsubscribe;

  /// Callback for getting notified when a new conversation is created
  /// with the current user.
  VICreateConversation onCreateConversation;

  /// Callback for getting notified when a conversation
  /// the current user belongs to is removed
  VIRemoveConversation onRemoveConversation;

  /// Callback for getting notified when the properties of a conversation
  /// the current user belongs to were modified
  VIEditConversation onEditConversation;

  /// Callback for getting notified when an user status was changed
  VISetStatus onSetStatus;

  /// Callback for getting notified when a message was edited
  VIEditMessage onEditMessage;

  /// Callback for getting notified when a new message was sent to a conversation
  /// the current user belongs to
  VISendMessage onSendMessage;

  /// Callback for getting notified when a message was removed from a conversation
  /// the current user belongs to
  VIRemoveMessage onRemoveMessage;

  /// Callback for getting notified when some user is typing text in a conversation.
  VITyping onTyping;

  /// Callback for getting notified when a participant in a conversation mark the event as read
  VIIsRead onRead;

  /// Get the Voximplant user identifier for the current user, e.g., 'username@appname.accname'
  String get me => _MessengerShared._me;

  /// Recreate a message.
  ///
  /// Note that this method does not create a message, but restore a previously created message from a local storage (database).
  ///
  /// Returns [VIMessage] instance or null if uuid or conversationUuid were null.
  ///
  /// `uuid` - Universally unique identifier of message
  ///
  /// `conversationUuid` - UUID of the conversation this message belongs to
  ///
  /// Optional `text` - Text of this message
  ///
  /// Optional `payload` - List of payload objects associated with the message
  ///
  /// Optional `sequence` - Message sequence number
  VIMessage recreateMessage(String uuid, String conversationUuid,
      {String text, List<Map<String, Object>> payload, int sequence}) {
    if (uuid == null) {
      _VILog._w(
          'Attempt to recreate message with uuid == null, returning null');
      return null;
    }
    if (conversationUuid == null) {
      _VILog._w('Attempt to recreate message with conversationUuid == null, '
          'returning null');
      return null;
    }
    return VIMessage._recreate(uuid, conversationUuid, text, payload, sequence);
  }

  /// Recreate a conversation.
  ///
  /// Note that this method does not create a conversation, but restore a previously created conversation from a local storage (database).
  ///
  /// Returns [VIConversation] instance or null if uuid was null.
  ///
  /// `uuid` - Conversation UUID
  ///
  /// Optional `conversationConfig` - Conversation config
  ///
  /// Optional `lastSequence` - Sequence of the last event stored in a local storage (database)
  ///
  /// Optional `lastUpdateTime` - UNIX timestamp that specifies the time of the last event stored in a local storage (database)
  ///
  /// Optional `createdTime` - UNIX timestamp that specifies the time of the conversation creation
  VIConversation recreateConversation(String uuid,
      {VIConversationConfig conversationConfig,
      int lastSequence,
      int lastUpdateTime,
      int createdTime}) {
    if (uuid == null) {
      _VILog._w(
          'Attempt to recreate conversation with uuid == null, returning null');
      return null;
    }
    return VIConversation._recreate(
        conversationConfig, uuid, lastSequence, lastUpdateTime, createdTime);
  }

  /// Get information for the user specified by the Voximplant user name, e.g., 'username@appname.accname'.
  ///
  /// It's possible to get any user of the main Voximplant developer account or its child accounts.
  ///
  /// `username` - Voximplant user identifier
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIUserEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIUserEvent> getUserByName(String username) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.getUserByName', {'name': username});
      return VIUserEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Get information for the users specified by the list of the Voximplant user names. Maximum 50 users.
  ///
  /// It's possible to get any users of the main Voximplant developer account or its child accounts.
  ///
  /// `users` - List of Voximplant user identifiers, e.g., 'username@appname.accname'
  ///
  /// Throws [VIException], if operation failed, otherwise returns List of [VIUserEvent] instances.
  /// For all possible errors see [VIMessagingError]
  Future<List<VIUserEvent>> getUsersByName(List<String> users) async {
    try {
      List<dynamic> data = await _methodChannel
          .invokeListMethod('Messaging.getUsersByName', {'users': users});
      return data.map((e) => VIUserEvent._fromMap(e)).toList();
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Get information for the user specified by the IM user id.
  ///
  /// It's possible to get any user of the main Voximplant developer account or its child accounts.
  ///
  /// `userId` - IM User id
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIUserEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIUserEvent> getUserByIMId(int userId) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.getUserByIMId', {'id': userId});
      return VIUserEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Get information for the users specified by the list of the IM user ids. Maximum 50 users.
  ///
  /// It's possible to get any users of the main Voximplant developer account or its child accounts.
  ///
  /// `users` - List of IM user ids
  ///
  /// Throws [VIException], if operation failed, otherwise returns List of [VIUserEvent] instances.
  /// For all possible errors see [VIMessagingError]
  Future<List<VIUserEvent>> getUsersByIMId(List<int> users) async {
    try {
      List<dynamic> data = await _methodChannel
          .invokeListMethod('Messaging.getUsersByIMId', {'users': users});
      return data.map((e) => VIUserEvent._fromMap(e)).toList();
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Edit current user information.
  ///
  /// `customData` - New custom data. If null, previously set custom data will not be changed. If empty map, previously set custom data will be removed.
  ///
  /// `privateCustomData` - New private custom data. If null, previously set private custom data will not be changed. If empty map, previously set private custom data will be removed.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIUserEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIUserEvent> editUser(Map<String, Object> customData,
      Map<String, Object> privateCustomData) async {
    try {
      Map<String, dynamic> data = await _methodChannel.invokeMapMethod(
          'Messaging.editUser',
          {'customData': customData, 'privateCustomData': privateCustomData});
      return VIUserEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Manage messenger push notification subscriptions for the current user.
  ///
  /// `notifications` - List of [VIMessengerNotification]
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIUserEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIUserEvent> managePushNotifications(
      List<VIMessengerNotification> notifications) async {
    try {
      Map<String, dynamic> data = await _methodChannel.invokeMapMethod(
          'Messaging.managePushNotifications',
          {'notifications': notifications?.map((e) => e.index)?.toList()});
      return VIUserEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Set the current user status.
  ///
  /// Other users (that are subscribed to the user) and other clients (of the current user)
  /// can be informed about the status changing via the [VIMessenger.onSetStatus]
  ///
  /// `online` - True if user is available for messaging, false otherwise
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIStatusEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIStatusEvent> setStatus(bool online) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.setStatus', {'online': online});
      return VIStatusEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Get all current subscriptions, i.e., the list of users the current user is subscribed to.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VISubscriptionEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VISubscriptionEvent> getSubscriptions() async {
    try {
      Map<String, dynamic> data =
          await _methodChannel.invokeMapMethod('Messaging.getSubscriptions');
      return VISubscriptionEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Subscribe for other user(s) information and status changes.
  ///
  /// It's possible to subscribe for any user of the main Voximplant developer account or its child accounts.
  ///
  /// Other logged in clients (of the current user) can be informed about the subscription
  /// via the [VIMessenger.onSubscribe] callback.
  /// User(s) specified in the 'users' parameter aren't informed about the subscription.
  ///
  /// `users` - List of IM user ids
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VISubscriptionEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VISubscriptionEvent> subscribe(List<int> users) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.subscribe', {'users': users});
      return VISubscriptionEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Unsubscribe from other user(s) information and status changes.
  ///
  /// It's possible to subscribe for any user of the main Voximplant developer account or its child accounts.
  ///
  /// Other logged in clients (of the current user) can be informed about the unsubscription
  /// via the [VIMessenger.onSubscribe] callback.
  /// User(s) specified in the 'users' parameter aren't informed about the unsubscription.
  ///
  /// `users` - List of IM user ids
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VISubscriptionEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VISubscriptionEvent> unsubscribe(List<int> users) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.unsubscribe', {'users': users});
      return VISubscriptionEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Unsubscribe from all subscriptions.
  ///
  /// Other logged in clients (of the current user) can be informed about the unsubscription
  /// via the [VIMessenger.onSubscribe] callback.
  /// User(s) specified in the 'users' parameter aren't informed about the unsubscription.
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VISubscriptionEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VISubscriptionEvent> unsubscribeFromAll() async {
    try {
      Map<String, dynamic> data =
          await _methodChannel.invokeMapMethod('Messaging.unsubscribeFromAll');
      return VISubscriptionEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Create a new conversation with the extended configuration.
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about the conversation creation
  /// via the [VIMessenger.onCreateConversation] callback.
  ///
  /// `conversationConfig` - [VIConversationConfig] instance with extended conversation parameters
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> createConversation(
      VIConversationConfig config) async {
    try {
      Map<String, dynamic> data = await _methodChannel.invokeMapMethod(
          'Messaging.createConversation', {'config': config._toMap});
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Get a conversation by its UUID.
  ///
  /// It's possible if:
  /// - the user that calls the method is/was a participant of this conversation
  /// - the conversation is an available public conversation (see [VIMessenger.getPublicConversations])
  ///
  /// `uuid` - Conversation UUID
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> getConversation(String uuid) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.getConversation', {'uuid': uuid});
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Get the multiple conversations by the list of UUIDs. Maximum 30 conversations.
  ///
  /// It's possible if:
  /// - the user that calls the method is/was a participant of these conversations
  /// - the conversations are the available public conversations (see [VIMessenger.getPublicConversations])
  ///
  /// `uuids` - List of conversation UUIDs. Maximum 30 conversations.
  ///
  /// Throws [VIException], if operation failed, otherwise returns List of [VIConversationEvent] instances.
  /// For all possible errors see [VIMessagingError]
  Future<List<VIConversationEvent>> getConversations(List<String> uuids) async {
    try {
      List<dynamic> data = await _methodChannel
          .invokeListMethod('Messaging.getConversations', {'uuids': uuids});
      return data.map((e) => VIConversationEvent._fromMap(e)).toList();
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Get all public conversations ([VIConversation.publicJoin] is true).
  ///
  /// It's possible to get all public conversations (UUIDs) that were created by:
  ///
  /// - the current user
  /// - other users of the same child account
  /// - users of the main Voximplant developer account
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationListEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationListEvent> getPublicConversations() async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.getPublicConversations');
      return VIConversationListEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Join the current user to any conversation specified by the UUID.
  ///
  /// It's possible only on the following conditions:
  ///
  /// - a conversation is created by a user of the main Voximplant developer account or its child accounts
  /// - public join is enabled ([VIConversation.publicJoin] is true)
  /// - the conversation is not a direct one ([VIConversation.direct] is false)
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about joining to the conversation
  /// via the [VIMessenger.onEditConversation] callback.
  ///
  /// `uuid` - Conversation UUID
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> joinConversation(String uuid) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.joinConversation', {'uuid': uuid});
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Make the current user to leave a conversation specified by the UUID.
  ///
  /// It's possible only if the conversation is not a direct one ([VIConversation.direct] is false)
  /// After a successful method call the conversation's UUID will be added to [VIUser.leaveConversationList].
  ///
  /// Other parties of the conversation (online participants and logged in clients)
  /// can be informed about leaving the conversation
  /// via the [VIMessenger.onEditConversation] callback.
  ///
  /// `uuid` - Conversation UUID
  ///
  /// Throws [VIException], if operation failed, otherwise returns [VIConversationEvent] instance.
  /// For all possible errors see [VIMessagingError]
  Future<VIConversationEvent> leaveConversation(String uuid) async {
    try {
      Map<String, dynamic> data = await _methodChannel
          .invokeMapMethod('Messaging.leaveConversation', {'uuid': uuid});
      return VIConversationEvent._fromMap(data);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  VIMessenger._(this._methodChannel) {
    _eventChannel.receiveBroadcastStream().listen(_eventListener);
  }

  void _eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['name'] == 'onEditUser') {
      if (onEditUser != null) {
        onEditUser(VIUserEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onSubscribe') {
      if (onSubscribe != null) {
        onSubscribe(VISubscriptionEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onUnsubscribe') {
      if (onUnsubscribe != null) {
        onUnsubscribe(VISubscriptionEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onCreateConversation') {
      if (onCreateConversation != null) {
        onCreateConversation(VIConversationEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onRemoveConversation') {
      if (onRemoveConversation != null) {
        onRemoveConversation(VIConversationEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onEditConversation') {
      if (onEditConversation != null) {
        onEditConversation(VIConversationEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onSetStatus') {
      if (onSetStatus != null) {
        onSetStatus(VIStatusEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onEditMessage') {
      if (onEditMessage != null) {
        onEditMessage(VIMessageEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onSendMessage') {
      if (onSendMessage != null) {
        onSendMessage(VIMessageEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onRemoveMessage') {
      if (onRemoveMessage != null) {
        onRemoveMessage(VIMessageEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'onTyping') {
      if (onTyping != null) {
        onTyping(VIConversationServiceEvent._fromMap(map['event']));
      }
    } else if (map['name'] == 'isRead') {
      if (onRead != null) {
        onRead(VIConversationServiceEvent._fromMap(map['event']));
      }
    }
  }
}
