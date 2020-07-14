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
    messenger = instance.getMessenger();
    print('setUp completed');
  });

  tearDown(() async {
    await client.disconnect();
    client = null;
    messenger = null;
    instance = null;
    print('tearDown completed');
  });

  group('message', () {
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
      expect(conversation.direct, isNotNull);
      expect(conversation.publicJoin, isNotNull);
      expect(conversation.uber, isNotNull);
      expect(conversation.title, isNotNull);
      expect(conversation.lastSequence, isNotNull);
      String messageText = 'test message';
      List<Map<String, Object>> messagePayload = [
        {
          'testString': 'test_string',
          'testNumber': 12344,
          'testBoolean': true,
          'testArray': [1, 2, 4, 7],
        },
        {
          'testObject': {
            'testString': 'test_string_2',
          },
        },
      ];
      VIMessageEvent messageEvent = await conversation.sendMessage(
          text: messageText, payload: messagePayload);
      logMessageEvent(messageEvent);
      expect(messageEvent.type, VIMessengerEventType.sendMessage);
      expect(messageEvent.action, VIMessengerAction.sendMessage);
      expect(messageEvent.imUserId, _testUsers[0].id);
      expect(messageEvent.sequence, 2);
      expect(messageEvent.timestamp, isNotNull);
      VIMessage message = messageEvent.message;
      expect(message, isNotNull);
      expect(message.text, messageText);
      expect(message.conversation, conversation.uuid);
      expect(message.payload, messagePayload);
      expect(message.sequence, 2);
    });

    test('editMessage', () async {
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
      expect(conversation.direct, isNotNull);
      expect(conversation.publicJoin, isNotNull);
      expect(conversation.uber, isNotNull);
      expect(conversation.title, isNotNull);
      expect(conversation.lastSequence, isNotNull);
      String messageText = 'test message';
      List<Map<String, Object>> messagePayload = [
        {
          'testString': 'test_string',
          'testNumber': 12344,
          'testBoolean': true,
          'testArray': [1, 2, 4, 7],
        },
        {
          'testObject': {
            'testString': 'test_string_2',
          },
        },
      ];
      VIMessageEvent messageEvent = await conversation.sendMessage(
          text: messageText, payload: messagePayload);
      logMessageEvent(messageEvent);
      expect(messageEvent.type, VIMessengerEventType.sendMessage);
      expect(messageEvent.action, VIMessengerAction.sendMessage);
      expect(messageEvent.imUserId, _testUsers[0].id);
      expect(messageEvent.sequence, 2);
      expect(messageEvent.timestamp, isNotNull);
      VIMessage message = messageEvent.message;
      expect(message, isNotNull);
      expect(message.text, messageText);
      expect(message.conversation, conversation.uuid);
      expect(message.payload, messagePayload);
      expect(message.sequence, 2);
      String newMessageText = 'new test message';
      VIMessageEvent editMessageEvent =
          await message.update(text: newMessageText);
      logMessageEvent(editMessageEvent);
      expect(editMessageEvent.type, VIMessengerEventType.editMessage);
      expect(editMessageEvent.action, VIMessengerAction.editMessage);
      expect(editMessageEvent.imUserId, _testUsers[0].id);
      expect(editMessageEvent.sequence, 3);
      expect(editMessageEvent.timestamp, isNotNull);
      VIMessage editedMessage = editMessageEvent.message;
      expect(editedMessage, isNotNull);
      expect(editedMessage.text, newMessageText);
      expect(editedMessage.conversation, conversation.uuid);
      expect(editedMessage.payload, messagePayload);
      expect(editedMessage.sequence, 3);
    });

    test('removeMessage', () async {
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
      expect(conversation.direct, isNotNull);
      expect(conversation.publicJoin, isNotNull);
      expect(conversation.uber, isNotNull);
      expect(conversation.title, isNotNull);
      expect(conversation.lastSequence, isNotNull);
      String messageText = 'test message';
      VIMessageEvent messageEvent =
          await conversation.sendMessage(text: messageText);
      logMessageEvent(messageEvent);
      expect(messageEvent.type, VIMessengerEventType.sendMessage);
      expect(messageEvent.action, VIMessengerAction.sendMessage);
      expect(messageEvent.imUserId, _testUsers[0].id);
      expect(messageEvent.sequence, 2);
      expect(messageEvent.timestamp, isNotNull);
      VIMessage message = messageEvent.message;
      expect(message, isNotNull);
      expect(message.text, messageText);
      expect(message.conversation, conversation.uuid);
      expect(message.sequence, 2);
      VIMessageEvent removeMessageEvent = await message.remove();
      logMessageEvent(removeMessageEvent);
      expect(removeMessageEvent.type, VIMessengerEventType.removeMessage);
      expect(removeMessageEvent.action, VIMessengerAction.removeMessage);
      expect(removeMessageEvent.imUserId, _testUsers[0].id);
      expect(removeMessageEvent.sequence, 3);
      expect(removeMessageEvent.timestamp, isNotNull);
      VIMessage removedMessage = removeMessageEvent.message;
      expect(removedMessage.conversation, conversation.uuid);
      expect(removedMessage.uuid, message.uuid);
      expect(removedMessage.sequence, 3);
    });

    test('markAsRead', () async {
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
      expect(conversation.direct, isNotNull);
      expect(conversation.publicJoin, isNotNull);
      expect(conversation.uber, isNotNull);
      expect(conversation.title, isNotNull);
      expect(conversation.lastSequence, isNotNull);
      String messageText = 'test message';
      VIMessageEvent messageEvent =
          await conversation.sendMessage(text: messageText);
      logMessageEvent(messageEvent);
      expect(messageEvent.type, VIMessengerEventType.sendMessage);
      expect(messageEvent.action, VIMessengerAction.sendMessage);
      expect(messageEvent.imUserId, _testUsers[0].id);
      expect(messageEvent.sequence, 2);
      expect(messageEvent.timestamp, isNotNull);
      VIMessage message = messageEvent.message;
      expect(message, isNotNull);
      expect(message.text, messageText);
      expect(message.conversation, conversation.uuid);
      expect(message.sequence, 2);
      VIConversationServiceEvent readEvent =
          await conversation.markAsRead(message.sequence);
      logServiceEvent(readEvent);
      expect(readEvent.type, VIMessengerEventType.read);
      expect(readEvent.action, VIMessengerAction.read);
      expect(readEvent.imUserId, _testUsers[0].id);
      expect(readEvent.sequence, message.sequence);
      expect(readEvent.conversationUuid, conversation.uuid);
      VIConversationEvent getConversationEvent =
          await messenger.getConversation(conversation.uuid);
      expect(getConversationEvent.type, VIMessengerEventType.getConversation);
      expect(getConversationEvent.action, VIMessengerAction.getConversation);
      expect(getConversationEvent.imUserId, _testUsers[0].id);
      expect(
          getConversationEvent.conversation.participants.first.lastReadSequence,
          message.sequence);
    });
  });
}
