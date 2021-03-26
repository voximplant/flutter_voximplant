/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:e2e/e2e.dart';

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
    client = instance.getClient(null);
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

  group('get user', () {
    test('getMe', () {
      expect(_testUsers[0].name.contains(messenger.me), true);
      print('me == ${messenger.me}');
    });

    test('getUserByName (me)', () async {
      VIUserEvent event = await messenger.getUserByName(messenger.me);
      expect(event, isNotNull);
      logUser(event.user);
      expect(event.type, VIMessengerEventType.getUser);
      expect(event.action, VIMessengerAction.getUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user, isNotNull);
      expect(_testUsers[0].name.contains(event.user.name), true);
      expect(event.user.isDeleted, false);
    });

    test('getUserByID (me)', () async {
      VIUser me = (await messenger.getUserByName(messenger.me)).user;
      VIUserEvent event = await messenger.getUserByIMId(me.imId);
      logUser(event.user);
      expect(event, isNotNull);
      expect(event.type, VIMessengerEventType.getUser);
      expect(event.action, VIMessengerAction.getUser);
      expect(event.imUserId, me.imId);
      expect(event.user.imId, me.imId);
      expect(event.user.customData, me.customData);
      expect(event.user.privateCustomData, me.privateCustomData);
      expect(event.user.conversationList, me.conversationList);
      expect(event.user.leaveConversationList, me.leaveConversationList);
      expect(event.user.notifications, me.notifications);
      expect(event.user.displayName, me.displayName);
      expect(event.user.isDeleted, me.isDeleted);
      expect(event.user.name, me.name);
      expect(_testUsers[0].name.contains(event.user.name), true);
      expect(event.user.isDeleted, false);
    });

    test('getUserByName (another)', () async {
      VIUserEvent event = await messenger.getUserByName(_testUsers[1].name);
      logUser(event.user);
      expect(event.type, VIMessengerEventType.getUser);
      expect(event.action, VIMessengerAction.getUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user, isNotNull);
      expect(_testUsers[1].name.contains(event.user.name), true);
      expect(event.user.imId, _testUsers[1].id);
      expect(event.user.isDeleted, false);
    });

    test('getUserByID (another)', () async {
      VIUserEvent event = await messenger.getUserByIMId(_testUsers[1].id);
      logUser(event.user);
      expect(event.type, VIMessengerEventType.getUser);
      expect(event.action, VIMessengerAction.getUser);
      expect(event.user, isNotNull);
      expect(event.imUserId, _testUsers[0].id);
      expect(_testUsers[1].name.contains(event.user.name), true);
      expect(event.user.imId, _testUsers[1].id);
      expect(event.user.isDeleted, false);
    });

    test('getUsersByName', () async {
      List<String> users = _testUsers.map((e) => e.name).toList();
      List<VIUserEvent> events = await messenger.getUsersByName(users);
      expect(events.length, users.length);
      events.forEach((event) {
        logUser(event.user);
        expect(event.type, VIMessengerEventType.getUser);
        expect(event.action, VIMessengerAction.getUsers);
        expect(event.user, isNotNull);
        expect(event.imUserId, _testUsers[0].id);
        expect(event.user.imId, isNotNull);
        expect(event.user.name, isNotNull);
        expect(event.user.displayName, isNotNull);
        expect(event.user.isDeleted, isNotNull);
        expect(event.user.customData, isNotNull);
        if (event.user.imId == _testUsers[0].id) {
          expect(event.user.privateCustomData, isNotNull);
          expect(event.user.notifications, isNotNull);
          expect(event.user.conversationList, isNotNull);
          expect(event.user.leaveConversationList, isNotNull);
        } else {
          expect(event.user.privateCustomData, isNull);
          expect(event.user.notifications, isNull);
          expect(event.user.conversationList, isNull);
          expect(event.user.leaveConversationList, isNull);
        }
      });
    });

    test('getUsersByIMId', () async {
      List<int> users = _testUsers.map((e) => e.id).toList();
      List<VIUserEvent> events = await messenger.getUsersByIMId(users);
      expect(events.length, users.length);
      events.forEach((event) {
        logUser(event.user);
        expect(event.type, VIMessengerEventType.getUser);
        expect(event.action, VIMessengerAction.getUsers);
        expect(event.user, isNotNull);
        expect(event.imUserId, _testUsers[0].id);
        expect(event.user.imId, isNotNull);
        expect(event.user.name, isNotNull);
        expect(event.user.displayName, isNotNull);
        expect(event.user.isDeleted, isNotNull);
        expect(event.user.customData, isNotNull);
        if (event.user.imId == _testUsers[0].id) {
          expect(event.user.privateCustomData, isNotNull);
          expect(event.user.notifications, isNotNull);
          expect(event.user.conversationList, isNotNull);
          expect(event.user.leaveConversationList, isNotNull);
        } else {
          expect(event.user.privateCustomData, isNull);
          expect(event.user.notifications, isNull);
          expect(event.user.conversationList, isNull);
          expect(event.user.leaveConversationList, isNull);
        }
      });
    });
  }, skip: false);

  group('edit user', () {
    test('editUser (string)', () async {
      Map<String, Object> customData = {
        'testCustomData': 'Test custom data 111',
        'testCustomData2': 'Test custom data 2222'
      };
      Map<String, Object> privateCustomData = {
        'testPrivateData': 'Test private data 111',
        'testPrivateData2': 'Test private data 2222'
      };
      VIUserEvent event =
      await messenger.editUser(customData, privateCustomData);
      logUserEvent(event);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.editUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, _testUsers[0].id);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.customData, customData);
      expect(event.user.privateCustomData, privateCustomData);
    });

    test('editUser (int)', () async {
      Map<String, Object> customData = {
        'testCustomData': 123,
        'testCustomData2': 456
      };
      Map<String, Object> privateCustomData = {
        'testPrivateData': 789,
        'testPrivateData2': 890
      };
      VIUserEvent event =
      await messenger.editUser(customData, privateCustomData);
      logUserEvent(event);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.editUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, _testUsers[0].id);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.customData, customData);
      expect(event.user.privateCustomData, privateCustomData);
    });

    test('editUser (bool)', () async {
      Map<String, Object> customData = {
        'testCustomData': true,
        'testCustomData2': false
      };
      Map<String, Object> privateCustomData = {
        'testPrivateData': false,
        'testPrivateData2': true
      };
      VIUserEvent event =
      await messenger.editUser(customData, privateCustomData);
      logUserEvent(event);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.editUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, _testUsers[0].id);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.customData, customData);
      expect(event.user.privateCustomData, privateCustomData);
    });

    test('editUser (array)', () async {
      Map<String, Object> customData = {
        'testCustomData': ["data 1", "data 2"],
        'testCustomData2': [123, 456]
      };
      Map<String, Object> privateCustomData = {
        'testPrivateData': [true, true],
        'testPrivateData2': []
      };
      VIUserEvent event =
      await messenger.editUser(customData, privateCustomData);
      logUserEvent(event);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.editUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, _testUsers[0].id);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.customData, customData);
      expect(event.user.privateCustomData, privateCustomData);
    });

    test('editUser (map)', () async {
      Map<String, Object> customData = {
        'testCustomData': {'data': "data"},
        'testCustomData2': {"key": 12344}
      };
      Map<String, Object> privateCustomData = {
        'testPrivateData': {"data": true},
        'testPrivateData2': {"key": false}
      };
      VIUserEvent event =
      await messenger.editUser(customData, privateCustomData);
      logUserEvent(event);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.editUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, _testUsers[0].id);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.customData, customData);
      expect(event.user.privateCustomData, privateCustomData);
    });

    test('editUser (only customData)', () async {
      VIUserEvent userEvent = await messenger.getUserByName(_testUsers[0].name);
      Map<String, Object> customData = {
        'testCustomData': 67890,
        'testCustomData2': 3456788
      };
      VIUserEvent event = await messenger.editUser(customData, null);
      logUserEvent(event);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.editUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, _testUsers[0].id);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.customData, customData);
      expect(event.user.privateCustomData, userEvent.user.privateCustomData);
    });

    test('editUser (remove customData)', () async {
      VIUserEvent event = await messenger.editUser({}, null);
      logUserEvent(event);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.editUser);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, _testUsers[0].id);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.customData, {});
    });
  }, skip: false);

  group('manageNotifications', () {
    test('managePushNotifications (enable sendMessage)', () async {
      VIUserEvent event = await messenger
          .managePushNotifications([VIMessengerNotification.onSendMessage]);
      logUserEvent(event);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.manageNotifications);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, isNotNull);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.user.customData, isNotNull);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(
          event.user.notifications
              .contains(VIMessengerNotification.onSendMessage),
          isTrue);
    });

    test('managePushNotifications (disable)', () async {
      VIUserEvent event = await messenger.managePushNotifications([]);
      logUserEvent(event);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.manageNotifications);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, isNotNull);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.user.customData, isNotNull);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.notifications.isEmpty, isTrue);
    });

    test('managePushNotifications (disable via passing null)', () async {
      VIUserEvent event = await messenger.managePushNotifications(null);
      logUserEvent(event);
      expect(event.type, VIMessengerEventType.editUser);
      expect(event.action, VIMessengerAction.manageNotifications);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.user.imId, isNotNull);
      expect(event.user.name, isNotNull);
      expect(event.user.displayName, isNotNull);
      expect(event.user.isDeleted, isNotNull);
      expect(event.user.customData, isNotNull);
      expect(event.user.privateCustomData, isNotNull);
      expect(event.user.notifications, isNotNull);
      expect(event.user.conversationList, isNotNull);
      expect(event.user.leaveConversationList, isNotNull);
      expect(event.user.notifications.isEmpty, isTrue);
    });
  }, skip: false);

  group('status', () {
    test('setStatus (online)', () async {
      VIStatusEvent event = await messenger.setStatus(true);
      logStatusEvent(event);
      expect(event.type, VIMessengerEventType.setStatus);
      expect(event.action, VIMessengerAction.setStatus);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.isOnline, isNotNull);
      expect(event.isOnline, true);
    });

    test('setStatus (offline)', () async {
      VIStatusEvent event = await messenger.setStatus(false);
      logStatusEvent(event);
      expect(event.type, VIMessengerEventType.setStatus);
      expect(event.action, VIMessengerAction.setStatus);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.isOnline, false);
    });
  }, skip: false);

  group('subscriptions', () {
    test('subscribe', () async {
      List<int> users =
      [_testUsers[1], _testUsers[2]].map((e) => e.id).toList();
      VISubscriptionEvent event = await messenger.subscribe(users);
      logSubscriptionEvent(event);
      expect(event.type, VIMessengerEventType.subscribe);
      expect(event.action, VIMessengerAction.subscribe);
      expect(event.imUserId, _testUsers[0].id);
      expect(event.users, users);
      VISubscriptionEvent subscriptionEvent =
      await messenger.getSubscriptions();
      expect(subscriptionEvent.type, VIMessengerEventType.getSubscriptions);
      expect(subscriptionEvent.action, VIMessengerAction.getSubscriptions);
      expect(subscriptionEvent.imUserId, _testUsers[0].id);
      expect(subscriptionEvent.users, users);
    });

    test('unsubscribe', () async {
      VISubscriptionEvent subscriptionEvent =
      await messenger.getSubscriptions();
      expect(subscriptionEvent.type, VIMessengerEventType.getSubscriptions);
      expect(subscriptionEvent.action, VIMessengerAction.getSubscriptions);
      expect(subscriptionEvent.imUserId, _testUsers[0].id);
      expect(subscriptionEvent.users, isNotNull);
      if (!subscriptionEvent.users.contains(_testUsers[2].id)) {
        VISubscriptionEvent subscribeEvent =
        await messenger.subscribe([_testUsers[2].id]);
        logSubscriptionEvent(subscribeEvent);
      }
      VISubscriptionEvent unsubscribeEvent =
      await messenger.unsubscribe([_testUsers[2].id]);
      logSubscriptionEvent(unsubscribeEvent);
      expect(unsubscribeEvent.type, VIMessengerEventType.unsubscribe);
      expect(unsubscribeEvent.action, VIMessengerAction.unsubscribe);
      expect(unsubscribeEvent.imUserId, _testUsers[0].id);
      expect(unsubscribeEvent.users, isNotNull);
      expect(unsubscribeEvent.users.length, 1);
      expect(unsubscribeEvent.users.contains(_testUsers[2].id), isTrue);
    });

    test('unsubscribeFromAll', () async {
      VISubscriptionEvent subscriptionsEvent =
      await messenger.getSubscriptions();
      logSubscriptionEvent(subscriptionsEvent);
      expect(subscriptionsEvent.type, VIMessengerEventType.getSubscriptions);
      expect(subscriptionsEvent.action, VIMessengerAction.getSubscriptions);
      expect(subscriptionsEvent.imUserId, _testUsers[0].id);
      expect(subscriptionsEvent.users, isNotNull);
      int length = subscriptionsEvent.users.length;
      if (length == 0) {
        VISubscriptionEvent subscribeEvent =
        await messenger.subscribe([_testUsers[1].id, _testUsers[2].id]);
        logSubscriptionEvent(subscribeEvent);
        length = subscribeEvent.users.length;
      }
      VISubscriptionEvent unsubscribeEvent =
      await messenger.unsubscribeFromAll();
      logSubscriptionEvent(unsubscribeEvent);
      expect(unsubscribeEvent.type, VIMessengerEventType.unsubscribe);
      expect(unsubscribeEvent.action, VIMessengerAction.unsubscribe);
      expect(unsubscribeEvent.imUserId, _testUsers[0].id);
      expect(unsubscribeEvent.users, isNotNull);
      expect(unsubscribeEvent.users.length, length);
    });
  }, skip: false);
}
