/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';

import 'test_logger.dart';
import 'test_user.dart';

// Create 3 TestUser's and place them at the list:
const List<TestUser> _testUsers = [];
//const List<TestUser> _testUsers = [testUser1, testUser2, testUser3];

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  Voximplant instance;
  VIClient client;
  VIMessenger messenger;

  setUp(() async {
    instance = Voximplant();
    client = instance.getClient();
    await client.connect();
    await client.login(
        '${_testUsers[0].name}.voximplant.com', _testUsers[0].pass);
    messenger = instance.messenger;
    print('setUp completed');
  });

  tearDown(() async {
    await client.disconnect();
    client = null;
    messenger = null;
    instance = null;
    print('tearDown completed');
  });

  group('createConversation', () {
    test('createConversation (default config, with another user)', () async {
      //canWrite, canEditMessages, canRemoveMessages - true by default
      VIConversationParticipant participant = VIConversationParticipant(
          _testUsers[1].id,
          canEditAllMessages: true,
          canManageParticipants: true);
      VIConversationConfig conversationConfig =
          VIConversationConfig(participants: [participant]);
      VIConversationEvent event =
          await messenger.createConversation(conversationConfig);
      logConversationEvent(event);
      expect(event.type, VIMessengerEventType.createConversation);
      expect(event.action, VIMessengerAction.createConversation);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.sequence, 1);
      expect(event.timestamp, isNotNull);
      VIConversation conversation = event.conversation;
      expect(conversation.uuid, isNotNull);
      expect(conversation.createdTime, isNotNull);
      expect(conversation.customData, isNotNull);
      expect(conversation.lastUpdateTime, isNotNull);
      expect(conversation.participants, isNotNull);
      expect(conversation.direct, isFalse);
      expect(conversation.publicJoin, isFalse);
      expect(conversation.uber, isFalse);
      // 'New conversation' - default conversation title
      expect(conversation.title, 'New conversation');
      expect(conversation.lastSequence, 1);
      expect(conversation.participants.length, 2);
      conversation.participants.forEach((participant) {
        expect(participant.canWrite, isTrue);
        expect(participant.canManageParticipants, isTrue);
        expect(participant.canEditMessages, isTrue);
        expect(participant.canEditAllMessages, isTrue);
        expect(participant.canRemoveMessages, isTrue);
        // creator has all permissions by default
        if (participant.imUserId == _testUsers[0].id) {
          expect(participant.canRemoveAllMessages, isTrue);
          expect(participant.isOwner, isTrue);
        } else {
          expect(participant.canRemoveAllMessages, isFalse);
          expect(participant.isOwner, isFalse);
        }
      });
    });

    test('createConversation (public and uber)', () async {
      //canWrite, canEditMessages, canRemoveMessages - true by default
      VIConversationParticipant participant = VIConversationParticipant(
          _testUsers[1].id,
          canRemoveAllMessages: true,
          canManageParticipants: true);
      VIConversationConfig conversationConfig = VIConversationConfig(
          participants: [participant], publicJoin: true, uber: true);
      VIConversationEvent event =
          await messenger.createConversation(conversationConfig);
      logConversationEvent(event);
      expect(event.type, VIMessengerEventType.createConversation);
      expect(event.action, VIMessengerAction.createConversation);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.sequence, 1);
      expect(event.timestamp, isNotNull);
      VIConversation conversation = event.conversation;
      expect(conversation.uuid, isNotNull);
      expect(conversation.createdTime, isNotNull);
      expect(conversation.customData, isNotNull);
      expect(conversation.lastUpdateTime, isNotNull);
      expect(conversation.participants, isNotNull);
      expect(conversation.direct, isFalse);
      expect(conversation.publicJoin, isTrue);
      expect(conversation.uber, isTrue);
      // 'New conversation' - default conversation title
      expect(conversation.title, 'New conversation');
      expect(conversation.lastSequence, 1);
      expect(conversation.participants.length, 2);
      conversation.participants.forEach((participant) {
        expect(participant.canWrite, isTrue);
        expect(participant.canManageParticipants, isTrue);
        expect(participant.canEditMessages, isTrue);
        expect(participant.canRemoveMessages, isTrue);
        expect(participant.canRemoveAllMessages, isTrue);
        // creator has all permissions by default
        if (participant.imUserId == _testUsers[0].id) {
          expect(participant.canEditAllMessages, isTrue);
          expect(participant.isOwner, isTrue);
        } else {
          expect(participant.canEditAllMessages, isFalse);
          expect(participant.isOwner, isFalse);
        }
      });
    });

    test('createConversation (direct with title and customData)', () async {
      //canWrite, canEditMessages, canRemoveMessages - true by default
      VIConversationParticipant participant = VIConversationParticipant(
          _testUsers[2].id,
          canRemoveAllMessages: true,
          canManageParticipants: true);
      Map<String, Object> customData = {'testData': 'some_data'};
      VIConversationConfig conversationConfig = VIConversationConfig(
          participants: [participant],
          direct: true,
          customData: customData,
          title: 'Test conversation with test user 3');
      VIConversationEvent event =
          await messenger.createConversation(conversationConfig);
      logConversationEvent(event);
      expect(event.type, VIMessengerEventType.createConversation);
      expect(event.action, VIMessengerAction.createConversation);
      expect(event.imUserId, _testUsers[0].id);
      // if a direct conversation with the same user has been already created,
      // the Messenger.createConversation will return already created conversation
      // sequence number may be not 1.
      expect(event.sequence >= 1, isTrue);
      expect(event.timestamp, isNotNull);
      VIConversation conversation = event.conversation;
      expect(conversation.uuid, isNotNull);
      expect(conversation.createdTime, isNotNull);
      expect(conversation.customData, isNotNull);
      expect(conversation.lastUpdateTime, isNotNull);
      expect(conversation.lastSequence >= 1, isTrue);
      expect(conversation.participants, isNotNull);
      expect(conversation.direct, isTrue);
      expect(conversation.publicJoin, isFalse);
      expect(conversation.uber, isFalse);
      expect(conversation.title, 'Test conversation with test user 3');
      expect(conversation.participants.length, 2);
      conversation.participants.forEach((participant) {
        expect(participant.canWrite, isTrue);
        expect(participant.canManageParticipants, isTrue);
        expect(participant.canEditMessages, isTrue);
        expect(participant.canRemoveMessages, isTrue);
        expect(participant.canRemoveAllMessages, isTrue);
        // creator has all permissions by default
        if (participant.imUserId == _testUsers[0].id) {
          expect(participant.canEditAllMessages, isTrue);
          expect(participant.isOwner, isTrue);
        } else {
          expect(participant.canEditAllMessages, isFalse);
          expect(participant.isOwner, isFalse);
        }
      });
    });
  }, skip: false);

  group('getConversations', () {
    test('getConversation', () async {
      VIUserEvent userEvent = await messenger.getUserByIMId(_testUsers[0].id);
      expect(userEvent.user, isNotNull);
      if (userEvent.user.conversationList.isEmpty) {
        print('The current user does not have any conversations');
        return;
      }
      String conversationUuid = userEvent.user.conversationList.first;
      VIConversationEvent event =
          await messenger.getConversation(conversationUuid);
      logConversationEvent(event);
      expect(event.type, VIMessengerEventType.getConversation);
      expect(event.action, VIMessengerAction.getConversation);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.sequence, 1);
      expect(event.timestamp, isNotNull);
      VIConversation conversation = event.conversation;
      expect(conversation.direct, isNotNull);
      expect(conversation.publicJoin, isNotNull);
      expect(conversation.uber, isNotNull);
      expect(conversation.title, isNotNull);
      expect(conversation.uuid, isNotNull);
      expect(conversation.createdTime, isNotNull);
      expect(conversation.customData, isNotNull);
      expect(conversation.lastUpdateTime, isNotNull);
      expect(conversation.lastSequence, isNotNull);
      expect(conversation.participants, isNotNull);
      bool foundMyselfInParticipants = false;
      for (VIConversationParticipant participant in conversation.participants) {
        if (participant.imUserId == _testUsers[0].id) {
          foundMyselfInParticipants = true;
          break;
        }
      }
      expect(foundMyselfInParticipants, isTrue);
    });

    test('getConversations', () async {
      VIUserEvent userEvent = await messenger.getUserByIMId(_testUsers[0].id);
      expect(userEvent.user, isNotNull);
      if (userEvent.user.conversationList.isEmpty) {
        print('The current user does not have any conversations');
        return;
      }
      List<String> allUuids = userEvent.user.conversationList;
      List<String> uuids =
          allUuids.sublist(0, allUuids.length < 30 ? allUuids.length : 29);
      int numberOfUuids = uuids.length;
      List<VIConversationEvent> events =
          await messenger.getConversations(uuids);
      expect(events.length, numberOfUuids);
      events.forEach((event) {
        logConversationEvent(event);
        expect(event.type, VIMessengerEventType.getConversation);
        expect(event.action, VIMessengerAction.getConversations);
        expect(event.imUserId, _testUsers[0].id);
        expect(event.sequence, isNotNull);
        expect(event.timestamp, isNotNull);
        VIConversation conversation = event.conversation;
        expect(conversation.direct, isNotNull);
        expect(conversation.publicJoin, isNotNull);
        expect(conversation.uber, isNotNull);
        expect(conversation.title, isNotNull);
        expect(conversation.uuid, isNotNull);
        expect(conversation.createdTime, isNotNull);
        expect(conversation.customData, isNotNull);
        expect(conversation.lastUpdateTime, isNotNull);
        expect(conversation.lastSequence, isNotNull);
        expect(conversation.participants, isNotNull);
        bool foundMyselfInParticipants = false;
        for (VIConversationParticipant participant
            in conversation.participants) {
          if (participant.imUserId == _testUsers[0].id) {
            foundMyselfInParticipants = true;
            break;
          }
        }
        expect(foundMyselfInParticipants, isTrue);
      });
    });

    test('getPublicConversations', () async {
      VIConversationListEvent event = await messenger.getPublicConversations();
      logConversationListEvent(event);
      expect(event.type, VIMessengerEventType.getPublicConversations);
      expect(event.action, VIMessengerAction.getPublicConversations);
      expect(event.imUserId, _testUsers[0].id);
      List<String> allUuids = event.conversationList;
      List<String> uuids =
          allUuids.sublist(0, allUuids.length < 30 ? allUuids.length : 29);
      int numberOfUuids = uuids.length;
      List<VIConversationEvent> conversationEvents =
          await messenger.getConversations(uuids);
      expect(conversationEvents.length, numberOfUuids);
      conversationEvents.forEach((event) {
        logConversationEvent(event);
        expect(event.type, VIMessengerEventType.getConversation);
        expect(event.action, VIMessengerAction.getConversations);
        expect(event.imUserId, _testUsers[0].id);
        expect(event.sequence, isNotNull);
        expect(event.timestamp, isNotNull);
        VIConversation conversation = event.conversation;
        expect(conversation.direct, isNotNull);
        expect(conversation.publicJoin, isNotNull);
        expect(conversation.uber, isNotNull);
        expect(conversation.title, isNotNull);
        expect(conversation.uuid, isNotNull);
        expect(conversation.createdTime, isNotNull);
        expect(conversation.customData, isNotNull);
        expect(conversation.lastUpdateTime, isNotNull);
        expect(conversation.lastSequence, isNotNull);
        expect(conversation.participants, isNotNull);
        expect(conversation.publicJoin, isTrue);
      });
    });
  }, skip: false);

  test('leave join public conversation', () async {
    VIConversationListEvent conversationListEvent =
        await messenger.getPublicConversations();
    logConversationListEvent(conversationListEvent);
    expect(conversationListEvent.type,
        VIMessengerEventType.getPublicConversations);
    expect(
        conversationListEvent.action, VIMessengerAction.getPublicConversations);
    expect(conversationListEvent.imUserId, _testUsers[0].id);
    String conversationUuid;
    if (conversationListEvent.conversationList.length == 0) {
      print('No public conversations available, create a new one');
      VIConversationConfig conversationConfig =
          VIConversationConfig(publicJoin: true);
      VIConversationEvent createConversationEvent =
          await messenger.createConversation(conversationConfig);
      logConversationEvent(createConversationEvent);
      expect(createConversationEvent.type,
          VIMessengerEventType.createConversation);
      expect(
          createConversationEvent.action, VIMessengerAction.createConversation);
      expect(createConversationEvent.imUserId, _testUsers[0].id);
      expect(createConversationEvent.conversation, isNotNull);
      conversationUuid = createConversationEvent.conversation.uuid;
      VIConversationEvent leaveConversationEvent =
          await messenger.leaveConversation(conversationUuid);
      logConversationEvent(leaveConversationEvent);
      expect(
          leaveConversationEvent.type, VIMessengerEventType.editConversation);
      expect(
          leaveConversationEvent.action, VIMessengerAction.leaveConversation);
      expect(leaveConversationEvent.imUserId, _testUsers[0].id);
      conversationUuid = leaveConversationEvent.conversation.uuid;
    } else {
      print('Public conversations are available, use the first one');
      VIConversationEvent getConversationEvent = await messenger
          .getConversation(conversationListEvent.conversationList.first);
      logConversationEvent(getConversationEvent);
      expect(getConversationEvent.type, VIMessengerEventType.getConversation);
      expect(getConversationEvent.action, VIMessengerAction.getConversation);
      expect(getConversationEvent.imUserId, _testUsers[0].id);
      expect(getConversationEvent.conversation, isNotNull);
      conversationUuid = getConversationEvent.conversation.uuid;
      for (VIConversationParticipant participant
          in getConversationEvent.conversation.participants) {
        if (participant.imUserId == _testUsers[0].id) {
          VIConversationEvent leaveConversationEvent =
              await messenger.leaveConversation(conversationUuid);
          logConversationEvent(leaveConversationEvent);
          expect(leaveConversationEvent.type,
              VIMessengerEventType.editConversation);
          expect(leaveConversationEvent.action,
              VIMessengerAction.leaveConversation);
          expect(leaveConversationEvent.imUserId, _testUsers[0].id);
          conversationUuid = leaveConversationEvent.conversation.uuid;
          break;
        }
      }
    }
    VIConversationEvent joinConversationEvent =
        await messenger.joinConversation(conversationUuid);
    logConversationEvent(joinConversationEvent);
    expect(joinConversationEvent.type, VIMessengerEventType.editConversation);
    expect(joinConversationEvent.action, VIMessengerAction.joinConversation);
    expect(joinConversationEvent.imUserId, _testUsers[0].id);
    expect(joinConversationEvent.conversation, isNotNull);
    expect(joinConversationEvent.conversation.uuid, conversationUuid);
    expect(joinConversationEvent.conversation.publicJoin, isTrue);
    bool containsMeAsParticipant = false;
    for (VIConversationParticipant participant
        in joinConversationEvent.conversation.participants) {
      if (participant.imUserId == _testUsers[0].id) {
        containsMeAsParticipant = true;
        break;
      }
    }
    expect(containsMeAsParticipant, isTrue);
    VIConversationEvent leaveConversationEvent =
        await messenger.leaveConversation(conversationUuid);
    logConversationEvent(leaveConversationEvent);
    expect(leaveConversationEvent.type, VIMessengerEventType.editConversation);
    expect(leaveConversationEvent.action, VIMessengerAction.leaveConversation);
    expect(leaveConversationEvent.imUserId, _testUsers[0].id);
    expect(leaveConversationEvent.conversation, isNotNull);
    expect(leaveConversationEvent.conversation.uuid, conversationUuid);
    expect(leaveConversationEvent.conversation.publicJoin, isTrue);
    VIUserEvent getUserEvent = await messenger.getUserByIMId(_testUsers[0].id);
    logUserEvent(getUserEvent);
    expect(getUserEvent.type, VIMessengerEventType.getUser);
    expect(getUserEvent.action, VIMessengerAction.getUser);
    expect(getUserEvent.imUserId, _testUsers[0].id);
    expect(getUserEvent.user.leaveConversationList.contains(conversationUuid),
        isTrue);
    expect(
        getUserEvent.user.conversationList.contains(conversationUuid), isFalse);
  }, skip: false);

  group('participants', () {
    test('addParticipants', () async {
      VIConversationParticipant participant = VIConversationParticipant(
          _testUsers[1].id,
          canEditAllMessages: true,
          canManageParticipants: true);
      VIConversationConfig conversationConfig =
          VIConversationConfig(participants: [participant]);
      VIConversationEvent conversationEvent =
          await messenger.createConversation(conversationConfig);
      expect(conversationEvent.type, VIMessengerEventType.createConversation);
      expect(conversationEvent.action, VIMessengerAction.createConversation);
      expect(conversationEvent.imUserId, _testUsers[0].id);
      expect(conversationEvent.sequence, 1);
      expect(conversationEvent.timestamp, isNotNull);
      VIConversation conversation = conversationEvent.conversation;
      expect(conversation, isNotNull);
      VIConversationParticipant newParticipant =
          VIConversationParticipant(_testUsers[2].id);
      VIConversationEvent addParticipantEvent =
          await conversation.addParticipants([newParticipant]);
      logConversationEvent(addParticipantEvent);
      expect(addParticipantEvent.type, VIMessengerEventType.editConversation);
      expect(addParticipantEvent.action, VIMessengerAction.addParticipants);
      expect(addParticipantEvent.imUserId, _testUsers[0].id);
      expect(addParticipantEvent.sequence, 2);
      expect(addParticipantEvent.timestamp, isNotNull);
      expect(addParticipantEvent.conversation.uber, conversation.uber);
      expect(
          addParticipantEvent.conversation.publicJoin, conversation.publicJoin);
      expect(addParticipantEvent.conversation.direct, conversation.direct);
      expect(addParticipantEvent.conversation.uber, conversation.uber);
      expect(
          addParticipantEvent.conversation.customData, conversation.customData);
      expect(addParticipantEvent.conversation.lastSequence, 2);
      List<VIConversationParticipant> participants =
          addParticipantEvent.conversation.participants;
      expect(participants.length, 3);
      for (VIConversationParticipant participant in participants) {
        expect(participant.canWrite, isTrue);
        expect(participant.canEditMessages, isTrue);
        expect(participant.canRemoveMessages, isTrue);
        // creator has all permissions by default
        if (participant.imUserId == _testUsers[0].id) {
          expect(participant.canRemoveAllMessages, isTrue);
          expect(participant.canManageParticipants, isTrue);
          expect(participant.canEditAllMessages, isTrue);
          expect(participant.isOwner, isTrue);
        } else if (participant.imUserId == _testUsers[1].id) {
          expect(participant.canRemoveAllMessages, isFalse);
          expect(participant.canManageParticipants, isTrue);
          expect(participant.canEditAllMessages, isTrue);
          expect(participant.isOwner, isFalse);
        } else if (participant.imUserId == _testUsers[2].id) {
          expect(participant.canRemoveAllMessages, isFalse);
          expect(participant.canManageParticipants, isFalse);
          expect(participant.canEditAllMessages, isFalse);
          expect(participant.isOwner, isFalse);
        }
      }
    });

    test('editParticipants', () async {
      VIConversationConfig conversationConfig = VIConversationConfig(
        participants: [
          VIConversationParticipant(_testUsers[1].id),
          VIConversationParticipant(_testUsers[2].id)
        ],
      );
      VIConversationEvent conversationEvent =
          await messenger.createConversation(conversationConfig);
      expect(conversationEvent.type, VIMessengerEventType.createConversation);
      expect(conversationEvent.action, VIMessengerAction.createConversation);
      expect(conversationEvent.imUserId, _testUsers[0].id);
      expect(conversationEvent.sequence, 1);
      expect(conversationEvent.timestamp, isNotNull);
      VIConversation conversation = conversationEvent.conversation;
      expect(conversation, isNotNull);
      List<VIConversationParticipant> editedParticipants = [
        VIConversationParticipant(_testUsers[2].id,
            canManageParticipants: true, canRemoveMessages: false)
      ];
      VIConversationEvent editParticipantEvent =
          await conversation.editParticipants(editedParticipants);
      logConversationEvent(editParticipantEvent);
      expect(editParticipantEvent.type, VIMessengerEventType.editConversation);
      expect(editParticipantEvent.action, VIMessengerAction.editParticipants);
      expect(editParticipantEvent.imUserId, _testUsers[0].id);
      expect(editParticipantEvent.sequence, 2);
      expect(editParticipantEvent.timestamp, isNotNull);
      expect(editParticipantEvent.conversation.lastSequence, 2);
      List<VIConversationParticipant> participants =
          editParticipantEvent.conversation.participants;
      expect(participants.length, 3);
      for (VIConversationParticipant participant in participants) {
        expect(participant.canWrite, isTrue);
        expect(participant.canEditMessages, isTrue);
        // creator has all permissions by default
        if (participant.imUserId == _testUsers[0].id) {
          expect(participant.canRemoveAllMessages, isTrue);
          expect(participant.canManageParticipants, isTrue);
          expect(participant.canEditAllMessages, isTrue);
          expect(participant.canRemoveMessages, isTrue);
          expect(participant.isOwner, isTrue);
        } else if (participant.imUserId == _testUsers[1].id) {
          expect(participant.canRemoveAllMessages, isFalse);
          expect(participant.canManageParticipants, isFalse);
          expect(participant.canEditAllMessages, isFalse);
          expect(participant.canRemoveMessages, isTrue);
          expect(participant.isOwner, isFalse);
        } else if (participant.imUserId == _testUsers[2].id) {
          expect(participant.canRemoveAllMessages, isFalse);
          expect(participant.canManageParticipants, isTrue);
          expect(participant.canEditAllMessages, isFalse);
          expect(participant.canRemoveMessages, isFalse);
          expect(participant.isOwner, isFalse);
        }
      }
    });

    test('removeParticipants', () async {
      VIConversationConfig conversationConfig = VIConversationConfig(
        participants: [
          VIConversationParticipant(_testUsers[1].id),
          VIConversationParticipant(_testUsers[2].id)
        ],
      );
      VIConversationEvent conversationEvent =
          await messenger.createConversation(conversationConfig);
      expect(conversationEvent.type, VIMessengerEventType.createConversation);
      expect(conversationEvent.action, VIMessengerAction.createConversation);
      expect(conversationEvent.imUserId, _testUsers[0].id);
      expect(conversationEvent.sequence, 1);
      expect(conversationEvent.timestamp, isNotNull);
      VIConversation conversation = conversationEvent.conversation;
      expect(conversation, isNotNull);
      List<VIConversationParticipant> participantsToRemove = [
        VIConversationParticipant(_testUsers[2].id)
      ];
      VIConversationEvent removeParticipantsEvent =
          await conversation.removeParticipants(participantsToRemove);
      logConversationEvent(removeParticipantsEvent);
      expect(
          removeParticipantsEvent.type, VIMessengerEventType.editConversation);
      expect(
          removeParticipantsEvent.action, VIMessengerAction.removeParticipants);
      expect(removeParticipantsEvent.imUserId, _testUsers[0].id);
      expect(removeParticipantsEvent.sequence, 2);
      expect(removeParticipantsEvent.timestamp, isNotNull);
      expect(removeParticipantsEvent.conversation.lastSequence, 2);
      List<VIConversationParticipant> participants =
          removeParticipantsEvent.conversation.participants;
      expect(participants.length, 2);
      for (VIConversationParticipant participant in participants) {
        expect(participant.canWrite, isTrue);
        expect(participant.canEditMessages, isTrue);
        expect(participant.canRemoveMessages, isTrue);
        // creator has all permissions by default
        if (participant.imUserId == _testUsers[0].id) {
          expect(participant.canRemoveAllMessages, isTrue);
          expect(participant.canManageParticipants, isTrue);
          expect(participant.canEditAllMessages, isTrue);
          expect(participant.isOwner, isTrue);
        } else if (participant.imUserId == _testUsers[1].id) {
          expect(participant.canRemoveAllMessages, isFalse);
          expect(participant.canManageParticipants, isFalse);
          expect(participant.canEditAllMessages, isFalse);
          expect(participant.isOwner, isFalse);
        }
      }
    });

    test('editConversation', () async {
      VIConversationConfig conversationConfig = VIConversationConfig();
      VIConversationEvent createConversationEvent =
          await messenger.createConversation(conversationConfig);
      logConversationEvent(createConversationEvent);
      expect(createConversationEvent.type,
          VIMessengerEventType.createConversation);
      expect(
          createConversationEvent.action, VIMessengerAction.createConversation);
      expect(createConversationEvent.imUserId, _testUsers[0].id);
      expect(createConversationEvent.sequence, 1);
      expect(createConversationEvent.timestamp, isNotNull);
      VIConversation conversation = createConversationEvent.conversation;
      expect(conversation.uuid, isNotNull);
      expect(conversation.createdTime, isNotNull);
      expect(conversation.customData, isNotNull);
      expect(conversation.lastUpdateTime, isNotNull);
      expect(conversation.participants, isNotNull);
      expect(conversation.direct, isFalse);
      expect(conversation.publicJoin, isFalse);
      expect(conversation.uber, isFalse);
      expect(conversation.title, 'New conversation');
      expect(conversation.lastSequence, 1);
      expect(conversation.participants.length, 1);
      conversation.title = 'Conversation title';
      conversation.publicJoin = true;
      Map<String, Object> customData = {'testData': 'some_data'};
      conversation.customData = customData;
      VIConversationEvent event = await conversation.update();
      logConversationEvent(event);
      expect(event.type, VIMessengerEventType.editConversation);
      expect(event.action, VIMessengerAction.editConversation);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.sequence, 2);
      expect(event.timestamp, isNotNull);
      expect(event.conversation, isNotNull);
      expect(event.conversation.uuid, isNotNull);
      expect(event.conversation.createdTime, isNotNull);
      expect(event.conversation.customData, isNotNull);
      expect(event.conversation.lastUpdateTime, isNotNull);
      expect(event.conversation.participants, isNotNull);
      expect(event.conversation.direct, isFalse);
      expect(event.conversation.publicJoin, isTrue);
      expect(event.conversation.uber, isFalse);
      expect(event.conversation.title, 'Conversation title');
      expect(event.conversation.lastSequence, 2);
      expect(event.conversation.participants.length, 1);
      expect(event.conversation.customData, customData);
    });
  });

  test('typing', () async {
    VIConversationEvent conversationEvent =
        await messenger.createConversation(VIConversationConfig());
    logConversationEvent(conversationEvent);
    expect(conversationEvent.type, VIMessengerEventType.createConversation);
    expect(conversationEvent.action, VIMessengerAction.createConversation);
    expect(conversationEvent.imUserId, _testUsers[0].id);
    expect(conversationEvent.sequence, 1);
    expect(conversationEvent.timestamp, isNotNull);
    VIConversation conversation = conversationEvent.conversation;
    expect(conversation.uuid, isNotNull);
    expect(conversation.createdTime, isNotNull);
    expect(conversation.customData, isNotNull);
    expect(conversation.lastUpdateTime, isNotNull);
    expect(conversation.participants, isNotNull);
    expect(conversation.direct, isFalse);
    expect(conversation.publicJoin, isFalse);
    expect(conversation.uber, isFalse);
    expect(conversation.title, 'New conversation');
    expect(conversation.lastSequence, 1);
    expect(conversation.participants.length, 1);
    VIConversationServiceEvent typingEvent = await conversation.typing();
    logServiceEvent(typingEvent);
    expect(typingEvent.type, VIMessengerEventType.typing);
    expect(typingEvent.action, VIMessengerAction.typing);
    expect(typingEvent.imUserId, _testUsers[0].id);
    expect(typingEvent.conversationUuid, conversation.uuid);
  });

  test('sendMessage', () async {
    VIConversationEvent conversationEvent =
        await messenger.createConversation(VIConversationConfig());
    logConversationEvent(conversationEvent);
    expect(conversationEvent.type, VIMessengerEventType.createConversation);
    expect(conversationEvent.action, VIMessengerAction.createConversation);
    expect(conversationEvent.imUserId, _testUsers[0].id);
    expect(conversationEvent.sequence, 1);
    expect(conversationEvent.timestamp, isNotNull);
    VIConversation conversation = conversationEvent.conversation;
    expect(conversation.uuid, isNotNull);
    expect(conversation.createdTime, isNotNull);
    expect(conversation.customData, isNotNull);
    expect(conversation.lastUpdateTime, isNotNull);
    expect(conversation.participants, isNotNull);
    expect(conversation.direct, isFalse);
    expect(conversation.publicJoin, isFalse);
    expect(conversation.uber, isFalse);
    expect(conversation.title, 'New conversation');
    expect(conversation.lastSequence, 1);
    expect(conversation.participants.length, 1);
    VIMessageEvent messageEvent =
        await conversation.sendMessage(text: 'test message');
    logMessageEvent(messageEvent);
    expect(messageEvent.type, VIMessengerEventType.sendMessage);
    expect(messageEvent.action, VIMessengerAction.sendMessage);
    expect(messageEvent.imUserId, _testUsers[0].id);
    expect(messageEvent.sequence, 2);
    expect(messageEvent.timestamp, isNotNull);
    expect(messageEvent.message, isNotNull);
    VIMessage message = messageEvent.message;
    expect(message.uuid, isNotNull);
    expect(message.sequence, 2);
    expect(message.text, 'test message');
    expect(message.conversation, conversation.uuid);
  });

  test('retransmitEvents', () async {
    List<_RetransmitMode> retransmitModes = [
      _RetransmitMode.from_to,
      _RetransmitMode.from,
      _RetransmitMode.to
    ];
    for (_RetransmitMode retransmitMode in retransmitModes) {
      print('======== retransmit mode: $retransmitMode ========');
      // 1. create conversation
      VIConversationConfig conversationConfig = VIConversationConfig(
        participants: [
          VIConversationParticipant(_testUsers[1].id,
              canRemoveAllMessages: true, canManageParticipants: true)
        ],
      );
      VIConversationEvent createConversationEvent =
          await messenger.createConversation(conversationConfig);
      expect(createConversationEvent.type,
          VIMessengerEventType.createConversation);
      expect(
          createConversationEvent.action, VIMessengerAction.createConversation);
      expect(createConversationEvent.imUserId, _testUsers[0].id);
      expect(createConversationEvent.sequence, 1);
      expect(createConversationEvent.timestamp, isNotNull);
      VIConversation conversation = createConversationEvent.conversation;
      expect(conversation, isNotNull);
      // 2. send message
      VIMessageEvent sendMessageEvent =
          await conversation.sendMessage(text: 'test message');
      expect(sendMessageEvent.type, VIMessengerEventType.sendMessage);
      expect(sendMessageEvent.action, VIMessengerAction.sendMessage);
      expect(sendMessageEvent.imUserId, _testUsers[0].id);
      expect(sendMessageEvent.sequence, 2);
      expect(sendMessageEvent.timestamp, isNotNull);
      expect(sendMessageEvent.message, isNotNull);
      VIMessage message = sendMessageEvent.message;
      // 3. edit conversation title
      conversation.title = 'Test conversation';
      VIConversationEvent editConversationEvent = await conversation.update();
      expect(editConversationEvent.type, VIMessengerEventType.editConversation);
      expect(editConversationEvent.action, VIMessengerAction.editConversation);
      expect(editConversationEvent.imUserId, _testUsers[0].id);
      expect(editConversationEvent.sequence, 3);
      expect(editConversationEvent.timestamp, isNotNull);
      conversation = editConversationEvent.conversation;
      // 4. edit message
      VIMessageEvent editMessageEvent =
          await message.update(text: 'updated test message');
      expect(editMessageEvent.type, VIMessengerEventType.editMessage);
      expect(editMessageEvent.action, VIMessengerAction.editMessage);
      expect(editMessageEvent.imUserId, _testUsers[0].id);
      expect(editMessageEvent.sequence, 4);
      expect(editMessageEvent.timestamp, isNotNull);
      // 5. send message
      VIMessageEvent sendMessageEvent2 =
          await conversation.sendMessage(text: 'another test message');
      expect(sendMessageEvent2.type, VIMessengerEventType.sendMessage);
      expect(sendMessageEvent2.action, VIMessengerAction.sendMessage);
      expect(sendMessageEvent2.imUserId, _testUsers[0].id);
      expect(sendMessageEvent2.sequence, 5);
      expect(sendMessageEvent2.timestamp, isNotNull);
      expect(sendMessageEvent2.message, isNotNull);
      message = sendMessageEvent2.message;
      // 6. remove message
      VIMessageEvent removeMessageEvent = await message.remove();
      expect(removeMessageEvent.type, VIMessengerEventType.removeMessage);
      expect(removeMessageEvent.action, VIMessengerAction.removeMessage);
      expect(removeMessageEvent.imUserId, _testUsers[0].id);
      expect(removeMessageEvent.sequence, 6);
      expect(removeMessageEvent.timestamp, isNotNull);
      expect(removeMessageEvent.message, isNotNull);
      // 7. retransmit
      VIRetransmitEvent retransmitEvent;
      if (retransmitMode == _RetransmitMode.from_to) {
        retransmitEvent = await conversation.retransmitEvents(1, 6);
      } else if (retransmitMode == _RetransmitMode.from) {
        retransmitEvent = await conversation.retransmitEventsFrom(1, 6);
      } else if (retransmitMode == _RetransmitMode.to) {
        retransmitEvent = await conversation.retransmitEventsTo(6, 6);
      } else {
        fail('unexpected retransmit mode');
      }
      logRetransmitEvent(retransmitEvent);
      expect(retransmitEvent.type, VIMessengerEventType.retransmitEvents);
      expect(retransmitEvent.action, VIMessengerAction.retransmitEvents);
      expect(retransmitEvent.imUserId, _testUsers[0].id);
      expect(retransmitEvent.fromSequence, 1);
      expect(retransmitEvent.toSequence, 6);
      expect(retransmitEvent.events, isNotNull);
      expect(retransmitEvent.events.length, 6);
      // check retransmit events
      VIConversationEvent retransmittedConversationEvent =
          retransmitEvent.events.first;
      print('Original event #1');
      logConversationEvent(createConversationEvent);
      print('Retransmitted event #1');
      logConversationEvent(retransmittedConversationEvent);
      expect(retransmittedConversationEvent.type, createConversationEvent.type);
      expect(retransmittedConversationEvent.action,
          createConversationEvent.action);
      expect(retransmittedConversationEvent.imUserId,
          createConversationEvent.imUserId);
      expect(retransmittedConversationEvent.sequence,
          createConversationEvent.sequence);
      expect(retransmittedConversationEvent.timestamp,
          createConversationEvent.timestamp);
      expect(retransmittedConversationEvent.conversation.title,
          'New conversation');
      expect(retransmittedConversationEvent.conversation.uber,
          createConversationEvent.conversation.uber);
      expect(retransmittedConversationEvent.conversation.publicJoin,
          createConversationEvent.conversation.publicJoin);
      expect(retransmittedConversationEvent.conversation.direct,
          createConversationEvent.conversation.direct);
      expect(retransmittedConversationEvent.conversation.createdTime,
          createConversationEvent.conversation.createdTime);
      expect(retransmittedConversationEvent.conversation.uuid,
          createConversationEvent.conversation.uuid);
      expect(retransmittedConversationEvent.conversation.customData,
          createConversationEvent.conversation.customData);
      expect(retransmittedConversationEvent.conversation.lastUpdateTime,
          createConversationEvent.conversation.lastUpdateTime);
      expect(retransmittedConversationEvent.conversation.lastSequence,
          createConversationEvent.conversation.lastSequence);
      VIMessageEvent retransmittedSendMessageEvent = retransmitEvent.events[1];
      print('Original event #2');
      logMessageEvent(sendMessageEvent);
      print('Retransmitted event #2');
      logMessageEvent(retransmittedSendMessageEvent);
      expect(retransmittedSendMessageEvent.type, sendMessageEvent.type);
      expect(retransmittedSendMessageEvent.action, sendMessageEvent.action);
      expect(retransmittedSendMessageEvent.imUserId, sendMessageEvent.imUserId);
      expect(retransmittedSendMessageEvent.sequence, sendMessageEvent.sequence);
      expect(
          retransmittedSendMessageEvent.timestamp, sendMessageEvent.timestamp);
      expect(retransmittedSendMessageEvent.message.text,
          sendMessageEvent.message.text);
      expect(retransmittedSendMessageEvent.message.payload,
          sendMessageEvent.message.payload);
      expect(retransmittedSendMessageEvent.message.sequence,
          sendMessageEvent.message.sequence);
      expect(retransmittedSendMessageEvent.message.conversation,
          sendMessageEvent.message.conversation);
      expect(retransmittedSendMessageEvent.message.uuid,
          sendMessageEvent.message.uuid);
      VIConversationEvent retransmittedEditConversationEvent =
          retransmitEvent.events[2];
      print('Original event #3');
      logConversationEvent(editConversationEvent);
      print('Retransmitted event #3');
      logConversationEvent(retransmittedEditConversationEvent);
      expect(
          retransmittedEditConversationEvent.type, editConversationEvent.type);
      expect(retransmittedEditConversationEvent.action,
          editConversationEvent.action);
      expect(retransmittedEditConversationEvent.imUserId,
          editConversationEvent.imUserId);
      expect(retransmittedEditConversationEvent.sequence,
          editConversationEvent.sequence);
      expect(retransmittedEditConversationEvent.timestamp,
          editConversationEvent.timestamp);
      expect(retransmittedEditConversationEvent.conversation.title,
          editConversationEvent.conversation.title);
      expect(retransmittedEditConversationEvent.conversation.uber,
          editConversationEvent.conversation.uber);
      expect(retransmittedEditConversationEvent.conversation.publicJoin,
          editConversationEvent.conversation.publicJoin);
      expect(retransmittedEditConversationEvent.conversation.direct,
          editConversationEvent.conversation.direct);
      expect(retransmittedEditConversationEvent.conversation.createdTime,
          editConversationEvent.conversation.createdTime);
      expect(retransmittedEditConversationEvent.conversation.uuid,
          editConversationEvent.conversation.uuid);
      expect(retransmittedEditConversationEvent.conversation.customData,
          editConversationEvent.conversation.customData);
      expect(retransmittedEditConversationEvent.conversation.lastUpdateTime,
          editConversationEvent.conversation.lastUpdateTime);
      expect(retransmittedEditConversationEvent.conversation.lastSequence,
          editConversationEvent.conversation.lastSequence);
      VIMessageEvent retransmittedEditMessageEvent = retransmitEvent.events[3];
      print('Original event #4');
      logMessageEvent(editMessageEvent);
      print('Retransmitted event #4');
      logMessageEvent(retransmittedEditMessageEvent);
      expect(retransmittedEditMessageEvent.type, editMessageEvent.type);
      expect(retransmittedEditMessageEvent.action, editMessageEvent.action);
      expect(retransmittedEditMessageEvent.imUserId, editMessageEvent.imUserId);
      expect(retransmittedEditMessageEvent.sequence, editMessageEvent.sequence);
      expect(
          retransmittedEditMessageEvent.timestamp, editMessageEvent.timestamp);
      expect(retransmittedEditMessageEvent.message.text,
          editMessageEvent.message.text);
      expect(retransmittedEditMessageEvent.message.payload,
          editMessageEvent.message.payload);
      expect(retransmittedEditMessageEvent.message.sequence,
          editMessageEvent.message.sequence);
      expect(retransmittedEditMessageEvent.message.conversation,
          editMessageEvent.message.conversation);
      expect(retransmittedEditMessageEvent.message.uuid,
          editMessageEvent.message.uuid);
      VIMessageEvent retransmittedSendMessageEvent2 = retransmitEvent.events[4];
      print('Original event #5');
      logMessageEvent(sendMessageEvent2);
      print('Retransmitted event #5');
      logMessageEvent(retransmittedSendMessageEvent2);
      expect(retransmittedSendMessageEvent2.type, sendMessageEvent2.type);
      expect(retransmittedSendMessageEvent2.action, sendMessageEvent2.action);
      expect(
          retransmittedSendMessageEvent2.imUserId, sendMessageEvent2.imUserId);
      expect(
          retransmittedSendMessageEvent2.sequence, sendMessageEvent2.sequence);
      expect(retransmittedSendMessageEvent2.timestamp,
          sendMessageEvent2.timestamp);
      expect(retransmittedSendMessageEvent2.message.text,
          sendMessageEvent2.message.text);
      expect(retransmittedSendMessageEvent2.message.payload,
          sendMessageEvent2.message.payload);
      expect(retransmittedSendMessageEvent2.message.sequence,
          sendMessageEvent2.message.sequence);
      expect(retransmittedSendMessageEvent2.message.conversation,
          sendMessageEvent2.message.conversation);
      expect(retransmittedSendMessageEvent2.message.uuid,
          sendMessageEvent2.message.uuid);
      VIMessageEvent retransmittedRemoveMessageEvent =
          retransmitEvent.events[5];
      print('Original event #6');
      logMessageEvent(removeMessageEvent);
      print('Retransmitted event #6');
      logMessageEvent(retransmittedRemoveMessageEvent);
      expect(retransmittedRemoveMessageEvent.type, removeMessageEvent.type);
      expect(retransmittedRemoveMessageEvent.action, removeMessageEvent.action);
      expect(retransmittedRemoveMessageEvent.imUserId,
          removeMessageEvent.imUserId);
      expect(retransmittedRemoveMessageEvent.sequence,
          removeMessageEvent.sequence);
      expect(retransmittedRemoveMessageEvent.timestamp,
          removeMessageEvent.timestamp);
      expect(retransmittedRemoveMessageEvent.message.text,
          removeMessageEvent.message.text);
      expect(retransmittedRemoveMessageEvent.message.payload,
          removeMessageEvent.message.payload);
      expect(retransmittedRemoveMessageEvent.message.sequence,
          removeMessageEvent.message.sequence);
      expect(retransmittedRemoveMessageEvent.message.conversation,
          removeMessageEvent.message.conversation);
      expect(retransmittedRemoveMessageEvent.message.uuid,
          removeMessageEvent.message.uuid);
    }
  }, timeout: Timeout(Duration(seconds: 60)));
}

enum _RetransmitMode { from_to, from, to }
