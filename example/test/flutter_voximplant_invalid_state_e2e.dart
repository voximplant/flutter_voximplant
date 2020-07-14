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

  test('use messenger before client', () async {
    try {
      VIMessenger messenger = Voximplant().getMessenger();
      await messenger.getUserByName(_testUsers[1].name);
    } on VIException catch (e) {
      expect(e.code, VIMessagingError.ERROR_CLIENT_NOT_LOGGED_IN);
      expect(e.message, 'Client is not logged in.');
    }
  });
}
