/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Interface that represents user information.
/// Voximplant users are created via the Voximplant control panel or HTTP API.
class VIUser {
  /// The IM unique id that is used to identify users in events and specify in user-related methods.
  final int imId;

  /// The user's display name which is specified during user creation via the Voximplant control panel or HTTP API.
  ///
  /// The display name is available to all users.
  final String displayName;

  /// The Voximplant user identifier, for example 'username@appname.accname'.
  final String name;

  /// Determines whether the user is deleted or not.
  final bool isDeleted;

  /// The list of UUIDs of the conversations that the user currently belongs to.
  ///
  /// Note that if the method is called not for the current user, the result will be null.
  final List<String>? conversationList;

  /// The list of UUIDs for the conversations that:
  ///
  /// - the user belonged to, but currently is not participating in
  /// - are not removed
  /// - Note that if the method is called not for the current user, the result will be null.
  final List<String>? leaveConversationList;

  /// The list of messenger notifications that the current user is subscribed to.
  ///
  /// Note that if the method is called not for the current user, the result will be null
  final List<VIMessengerNotification>? notifications;

  /// Private custom data available only to the current user.
  final Map<String, dynamic>? privateCustomData;

  /// The specified user's public custom data available to all users.
  ///
  /// A custom data can be set via the [VIMessenger.editUser] method.
  final Map<String, dynamic> customData;

  VIUser._fromMap(Map<dynamic, dynamic> map)
      : this.imId = map['id'],
        this.displayName = map['displayName'],
        this.name = map['name'],
        this.isDeleted = map['isDeleted'],
        this.conversationList =
            (map['conversationList'] as List).cast<String>(),
        this.leaveConversationList =
            (map['leaveConversationList'] as List).cast<String>(),
        this.notifications = (map['notifications'] as List)
            .cast<int>()
            .map((e) => VIMessengerNotification.values[e])
            .toList(),
        this.privateCustomData =
            map['privateCustomData']?.cast<String, dynamic>(),
        this.customData = map['customData'].cast<String, dynamic>();
}

/// Enum that represents events available for push notification subscriptions.
///
/// Use the [VIMessenger.managePushNotifications] method to subscribe for push notifications.
enum VIMessengerNotification { onEditMessage, onSendMessage }
