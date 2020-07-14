/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';

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

  test('create direct and public error', () async {
    VIConversationParticipant participant = VIConversationParticipant(
        _testUsers[1].id,
        canRemoveAllMessages: true,
        canManageParticipants: true);
    VIConversationConfig config = VIConversationConfig(
        participants: [participant], publicJoin: true, direct: true);
    try {
      await messenger.createConversation(config);
    } on VIException catch (e) {
      expect(e.code, VIMessagingError.ERROR_DIRECT_CANNOT_BE_PUBLIC_OR_UBER);
      expect(e.message, 'Direct conversation cannot be public or uber.');
    }
  });

  test('create direct and uber error', () async {
    VIConversationParticipant participant = VIConversationParticipant(
        _testUsers[1].id,
        canRemoveAllMessages: true,
        canManageParticipants: true);
    VIConversationConfig config = VIConversationConfig(
        participants: [participant], uber: true, direct: true);
    try {
      await messenger.createConversation(config);
    } on VIException catch (error) {
      expect(
          error.code, VIMessagingError.ERROR_DIRECT_CANNOT_BE_PUBLIC_OR_UBER);
      expect(error.message, 'Direct conversation cannot be public or uber.');
    }
  });

  test('create direct without participants', () async {
    VIConversationConfig config =
        VIConversationConfig(participants: [], direct: true);
    try {
      await messenger.createConversation(config);
    } on VIException catch (error) {
      expect(error.code, VIMessagingError.ERROR_NUMBER_OF_USERS_IN_DIRECT);
      expect(error.message,
          'Direct conversation is allowed between two users only.');
    }
  });
}
