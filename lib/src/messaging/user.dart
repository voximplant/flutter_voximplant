// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Interface that represents user information.
/// Voximplant users are created via the Voximplant control panel or HTTP API.
class VIUser {
  /// IM unique id that is used to identify users in events and specify in user-related methods.
  final int imId;

  /// User's display name which is specified during user creation via the Voximplant control panel or HTTP API.
  ///
  /// Display name is available to all users.
  final String displayName;

  /// Voximplant user identifier, for example 'username@appname.accname'.
  final String name;

  /// Whether the user is deleted or not.
  final bool isDeleted;

  /// List of UUIDs of the conversations that the user currently belongs to.
  ///
  /// Note that if the method is called not for the current user, the result is null.
  final List<String>? conversationList;

  /// List of UUIDs for the conversations that:
  ///
  /// - the user belonged to, but currently is not participating in
  /// - are not removed
  /// - Note that if the method is called not for the current user, the result is null.
  final List<String>? leaveConversationList;

  /// List of messenger notifications that the current user is subscribed to.
  ///
  /// Note that if the method is called not for the current user, the result is null
  final List<VIMessengerNotification>? notifications;

  /// Private custom data available only to the current user.
  final Map<String, dynamic>? privateCustomData;

  /// Specified user's public custom data available to all users.
  ///
  /// A custom data can be set via the [VIMessenger.editUser] method.
  final Map<String, dynamic> customData;

  VIUser._fromMap(Map<dynamic, dynamic> map)
      : imId = map['id'],
        displayName = map['displayName'],
        name = map['name'],
        isDeleted = map['isDeleted'],
        conversationList = (map['conversationList'] as List?)?.cast<String>(),
        leaveConversationList =
            (map['leaveConversationList'] as List?)?.cast<String>(),
        notifications = (map['notifications'] as List?)
            ?.cast<int>()
            .map((e) => VIMessengerNotification.values[e])
            .toList(),
        privateCustomData = map['privateCustomData']?.cast<String, dynamic>(),
        customData = map['customData']?.cast<String, dynamic>();
}

/// Enum that represents events available for push notification subscriptions.
///
/// Use the [VIMessenger.managePushNotifications] method to subscribe for push notifications.
enum VIMessengerNotification { onEditMessage, onSendMessage }
