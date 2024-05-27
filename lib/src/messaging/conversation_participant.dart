// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Class that represents a participant of the conversation.
///
/// In order to apply changes made by setters, you have to call one of the following methods:
///
/// - [VIMessenger.createConversation]
/// - [VIConversation.addParticipants]
/// - [VIConversation.editParticipants]
/// The default permissions for all participants are: write / edit / remove their own messages.
///
/// The creator of any conversation by default:
///
/// - is the owner (ConversationParticipant.isOwner() is true)
/// - can edit / remove other participant's messages
/// - can manage other participants
class VIConversationParticipant {
  /// The IM user id.
  final int imUserId;

  /// Sequence of the event that was last marked as read or 0 if the participant didn't mark events as read.
  final int lastReadSequence;

  /// A bool value that determines whether the conversation participant is an owner.
  /// There could be more than one owner in the conversation.
  /// If true, the participant can edit the conversation.
  /// If true and canManageParticipants is true, the participant can manage other owners.
  /// Note that a value change doesn't apply changes by itself; there are appropriate methods for applying:
  ///
  /// - [VIConversation.editParticipants] for an existing conversation
  /// - [VIMessenger.createConversation] for a new conversation
  bool isOwner;

  /// A bool value that determines whether the conversation participant can send messages to the conversation.
  /// Default is true
  ///
  /// Note that a value change doesn't apply changes by itself; there are appropriate methods for applying:
  ///
  /// - [VIConversation.editParticipants] for an existing conversation
  /// - [VIMessenger.createConversation] for a new conversation
  bool canWrite;

  /// A bool value that determines whether the conversation participant can edit its own messages.
  /// Default is true
  ///
  /// Note that a value change doesn't apply changes by itself; there are appropriate methods for applying:
  ///
  /// - [VIConversation.editParticipants] for an existing conversation
  /// - [VIMessenger.createConversation] for a new conversation
  bool canEditMessages;

  /// A bool value that determines whether the conversation participant can edit messages other than its own.
  ///
  /// Note that a value change doesn't apply changes by itself; there are appropriate methods for applying:
  ///
  /// - [VIConversation.editParticipants] for an existing conversation
  /// - [VIMessenger.createConversation] for a new conversation
  bool canEditAllMessages;

  /// A bool value that determines whether the conversation participant can remove its own messages.
  /// Default is true
  ///
  /// Note that a value change doesn't apply changes by itself; there are appropriate methods for applying:
  ///
  /// - [VIConversation.editParticipants] for an existing conversation
  /// - [VIMessenger.createConversation] for a new conversation
  bool canRemoveMessages;

  /// A bool value that determines whether the conversation participant can remove messages other than its own.
  ///
  /// Note that a value change doesn't apply changes by itself; there are appropriate methods for applying:
  ///
  /// - [VIConversation.editParticipants] for an existing conversation
  /// - [VIMessenger.createConversation] for a new conversation
  bool canRemoveAllMessages;

  /// A bool value that determines whether the conversation participant can manage other participants in the conversation:
  ///
  /// - add / remove / edit permissions
  /// - add / remove participants
  /// If true and isOwner is true, the participant can manage other owners.
  ///
  /// Note that a value change doesn't apply changes by itself; there are appropriate methods for applying:
  ///
  /// - [VIConversation.editParticipants] for an existing conversation
  /// - [VIMessenger.createConversation] for a new conversation
  bool canManageParticipants;

  /// Create a new participants.
  ///
  /// Use [VIConversationConfig.participants] or [VIConversation.addParticipants] to add participants to the conversation.
  ///
  /// `imUserId` - IM User id. Can be retrieved from [VIUser.imId]
  /// Optional `isOwner` - determines if the conversation participant is an owner
  /// Optional `canWrite` - determines if the conversation participant can send messages to the conversation
  /// Optional `canEditMessages` - determines if the conversation participant can edit its own messages
  /// Optional `canEditAllMessages` - determines if the conversation participant can edit messages other than its own
  /// Optional `canRemoveMessages` - determines if the conversation participant can remove its own messages
  /// Optional `canRemoveAllMessages` - determines if the conversation participant can remove messages other than its own
  /// Optional `canManageParticipants` - determines if the participant can manage other participants in the conversation
  VIConversationParticipant(
    this.imUserId, {
    this.isOwner = false,
    this.canWrite = true,
    this.canEditMessages = true,
    this.canEditAllMessages = false,
    this.canRemoveMessages = true,
    this.canRemoveAllMessages = false,
    this.canManageParticipants = false,
  }) : lastReadSequence = 0;

  VIConversationParticipant._fromMap(Map<dynamic, dynamic> map)
      : imUserId = map['id'],
        lastReadSequence = map['lastReadSequence'],
        isOwner = map['isOwner'],
        canWrite = map['canWrite'],
        canEditMessages = map['canEditMessages'],
        canEditAllMessages = map['canEditAllMessages'],
        canRemoveMessages = map['canRemoveMessages'],
        canRemoveAllMessages = map['canRemoveAllMessages'],
        canManageParticipants = map['canManageParticipants'];

  Map<String, Object> get _toMap => {
        'id': imUserId,
        'isOwner': isOwner,
        'canWrite': canWrite,
        'canEditMessages': canEditMessages,
        'canEditAllMessages': canEditAllMessages,
        'canRemoveMessages': canRemoveMessages,
        'canRemoveAllMessages': canRemoveAllMessages,
        'canManageParticipants': canManageParticipants
      };
}
