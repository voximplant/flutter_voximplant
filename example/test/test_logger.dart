/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'package:flutter_voximplant/flutter_voximplant.dart';

void logConversationEvent(VIConversationEvent event) {
  drawLinesAround(() {
    logEvent(event);
    logConversation(event.conversation);
    print('sequence: ${event.sequence}');
    print('timestamp: ${event.timestamp}');
  });
}

void logConversationListEvent(VIConversationListEvent event) {
  drawLinesAround(() {
    logEvent(event);
    print('conversationList: ${event.conversationList}');
  });
}

void logSubscriptionEvent(VISubscriptionEvent event) {
  drawLinesAround(() {
    logEvent(event);
    print('users: ${event.users}');
  });
}

void logRetransmitEvent(VIRetransmitEvent event) {
  drawLinesAround(() {
    logEvent(event);
    print('events: ${event.events.map((e) => e.type.toString()).toList()}');
    print('fromSequence: ${event.fromSequence}');
    print('toSequence: ${event.toSequence}');
  });
}

void logServiceEvent(VIConversationServiceEvent event) {
  drawLinesAround(() {
    logEvent(event);
    print('conversationUuid: ${event.conversationUuid}');
    print('sequence: ${event.sequence}');
  });
}

void logMessageEvent(VIMessageEvent event) {
  drawLinesAround(() {
    logEvent(event);
    print('timestamp: ${event.timestamp}');
    print('sequence: ${event.sequence}');
    logMessage(event.message);
  });
}

void logMessage(VIMessage message) {
  print('message:');
  print('uuid: ${message.uuid}');
  print('conversation: ${message.conversation}');
  print('sequence: ${message.sequence}');
  print('text: ${message.text}');
  print('paylod: ${message.payload}');
}

void logStatusEvent(VIStatusEvent event) {
  drawLinesAround(() {
    logEvent(event);
    print('isOnline: ${event.isOnline}');
  });
}

void logUserEvent(VIUserEvent event) {
  drawLinesAround(() {
    logEvent(event);
    logUser(event.user);
  });
}

void logEvent(VIMessengerEvent event) {
  print('initiator: ${event.imUserId}');
  print('action: ${event.action}');
  print('type: ${event.type}');
}

void logUser(VIUser user) {
  print('imID: ${user.imId}');
  print('customData: ${user.customData}');
  print('privateCustomData: ${user.privateCustomData}');
  print('conversationList: ${user.conversationList}');
  print('leaveConversationList: ${user.leaveConversationList}');
  print('notifications: ${user.notifications}');
  print('displayName: ${user.displayName}');
  print('deleted: ${user.isDeleted}');
  print('name: ${user.name}');
}

void logConversation(VIConversation conversation) {
  print('uuid: ${conversation.uuid}');
  print('title: ${conversation.title}');
  print('direct: ${conversation.direct}');
  print('uber: ${conversation.uber}');
  print('publicJoin ${conversation.publicJoin}');
  print('participants:');
  conversation.participants.forEach((participant) {
    logParticipant(participant);
  });
  print('createdTime: ${conversation.createdTime}');
  print('lastSequence ${conversation.lastSequence}');
  print('lastUpdateTime ${conversation.lastUpdateTime}');
  print('customData ${conversation.customData}');
}

void logParticipant(VIConversationParticipant participant) {
  print('id: ${participant.imUserId}');
  print('lastReadSequence: ${participant.lastReadSequence}');
  print('isOwner: ${participant.isOwner}');
  print('canWrite: ${participant.canWrite}');
  print('canEdit: ${participant.canEditMessages}');
  print('canEditAll: ${participant.canEditAllMessages}');
  print('canRemove: ${participant.canRemoveMessages}');
  print('canRemoveAll: ${participant.canRemoveAllMessages}');
  print('canManage: ${participant.canManageParticipants}');
}

void drawLinesAround(Function code) {
  print('===============================================');
  code();
  print('===============================================');
}
