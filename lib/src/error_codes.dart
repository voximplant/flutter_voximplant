// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../flutter_voximplant.dart';

class VIException implements Exception {
  final String code;
  final String? message;

  VIException(this.code, this.message);

  @override
  String toString() => '$runtimeType($code, $message)';
}

class VILoggerError {
  static const String ERROR_FILE_OPEN = 'ERROR_FILE_OPEN';
  static const String ERROR_SYSTEM_SECURITY = 'ERROR_SYSTEM_SECURITY';
  static const String ERROR_INVALID_ARGUMENTS = 'ERROR_INVALID_ARGUMENTS';
}

class VIClientError {
  static const String ERROR_ACCOUNT_FROZEN = 'ERROR_ACCOUNT_FROZEN';
  static const String ERROR_INTERNAL = 'ERROR_INTERNAL';
  static const String ERROR_MAU_ACCESS_DENIED = 'ERROR_MAU_ACCESS_DENIED';
  static const String ERROR_INVALID_PASSWORD = 'ERROR_INVALID_PASSWORD';
  static const String ERROR_INVALID_STATE = 'ERROR_INVALID_STATE';
  static const String ERROR_INVALID_USERNAME = 'ERROR_INVALID_USERNAME';
  static const String ERROR_NETWORK_ISSUES = 'ERROR_NETWORK_ISSUES';
  static const String ERROR_TIMEOUT = 'ERROR_TIMEOUT';
  static const String ERROR_TOKEN_EXPIRED = 'ERROR_TOKEN_EXPIRED';
  static const String ERROR_CONNECTION_FAILED = 'ERROR_CONNECTION_FAILED';
  static const String ERROR_INVALID_ARGUMENTS = 'ERROR_INVALID_ARGUMENTS';
}

class VICallError {
  static const String ERROR_CLIENT_NOT_LOGGED_IN = 'ERROR_CLIENT_NOT_LOGGED_IN';
  static const String ERROR_REJECTED = 'ERROR_REJECTED';
  static const String ERROR_TIMEOUT = 'ERROR_TIMEOUT';
  static const String ERROR_MEDIA_IS_ON_HOLD = 'ERROR_MEDIA_IS_ON_HOLD';
  static const String ERROR_ALREADY_IN_THIS_STATE =
      'ERROR_ALREADY_IN_THIS_STATE';
  static const String ERROR_INCORRECT_OPERATION = 'ERROR_INCORRECT_OPERATION';
  static const String ERROR_INTERNAL = 'ERROR_INTERNAL';
  static const String ERROR_MISSING_PERMISSION = 'ERROR_MISSING_PERMISSION';
  static const String ERROR_INVALID_ARGUMENTS = 'ERROR_INVALID_ARGUMENTS';
  static const String ERROR_RECONNECTING = 'ERROR_RECONNECTING';
}

class VIAudioFileError {
  /// Audio file playing has been stopped due to <VIAudioFile> instance is deallocated.
  static const String ERROR_DESTROYED = 'ERROR_DESTROYED';

  /// Audio file playing has been interrupted by a third party application.
  static const String ERROR_INTERRUPTED = 'ERROR_INTERRUPTED';

  /// The audio file is already playing.
  static const String ERROR_ALREADY_PLAYING = 'ERROR_ALREADY_PLAYING';

  /// Audio file playing has been interrupted by CallKit activation.
  static const String ERROR_CALLKIT_ACTIVATED = 'ERROR_CALLKIT_ACTIVATED';

  /// Audio file playing has been interrupted by CallKit deactivation.
  static const String ERROR_CALLKIT_DEACTIVATED = 'ERROR_CALLKIT_DEACTIVATED';

  /// Audio file failed to start playing due to audio session configuration issues.
  static const String ERROR_FAILED_TO_CONFIGURE_AUDIO_SESSION =
      'ERROR_FAILED_TO_CONFIGURE_AUDIO_SESSION';

  /// Internal error occurred.
  static const String ERROR_INTERNAL = 'ERROR_INTERNAL';
}

class VIMessagingError {
  /// Something went wrong. Please check your input or required parameters.
  static const String ERROR_SOMETHING_WENT_WRONG = "ERROR_SOMETHING_WENT_WRONG";

  /// Transport message structure is wrong.
  static const String ERROR_TRANSPORT_MESSAGE_STRUCTURE_IS_WRONG =
      "ERROR_TRANSPORT_MESSAGE_STRUCTURE_IS_WRONG";

  /// Event name is unknown.
  static const String ERROR_EVENT_NAME_IS_UNKNOWN =
      "ERROR_EVENT_NAME_IS_UNKNOWN";

  /// Conversation does not exist.
  static const String ERROR_CONVERSATION_DOES_NOT_EXIST =
      "ERROR_CONVERSATION_DOES_NOT_EXIST";

  /// Message with this UUID does not exist in the conversation.
  static const String ERROR_MESSAGE_DOES_NOT_EXIST =
      "ERROR_MESSAGE_DOES_NOT_EXIST";

  /// Message with this UUID is deleted from the conversation.
  static const String ERROR_MESSAGE_DELETED = "ERROR_MESSAGE_DELETED";

  /// ACL error.
  static const String ERROR_ACL = "ERROR_ACL";

  /// User is already in the participants list.
  static const String ERROR_ALREADY_IN_PARTICIPANTS_LIST =
      "ERROR_ALREADY_IN_PARTICIPANTS_LIST";

  /// Public join is not available for this conversation.
  static const String ERROR_PUBLIC_JOIN_IS_UNAVAILABLE =
      "ERROR_PUBLIC_JOIN_IS_UNAVAILABLE";

  /// Conversation with this UUID is deleted.
  static const String ERROR_CONVERSATION_DELETED = "ERROR_CONVERSATION_DELETED";

  /// User validation error.
  static const String ERROR_USER_VALIDATION = "ERROR_USER_VALIDATION";

  /// User is not in the participants list.
  static const String ERROR_USER_IS_NOT_IN_THE_PARTICIPANT_LIST =
      "ERROR_USER_IS_NOT_IN_THE_PARTICIPANT_LIST";

  /// Message size exceeds the limit of 5000 symbols.
  static const String ERROR_MESSAGE_SIZE_EXCEEDS_LIMIT =
      "ERROR_MESSAGE_SIZE_EXCEEDS_LIMIT";

  /// User is not found.
  static const String ERROR_USER_NOT_FOUND = "ERROR_USER_NOT_FOUND";

  /// IM service is not available. Try again later.
  static const String ERROR_IM_SERVICE_UNAVAILABLE =
      "ERROR_IM_SERVICE_UNAVAILABLE";

  /// Method calls within 10s interval from the last call are discarded.
  static const String ERROR_METHOD_CALL_DISCARDED =
      "ERROR_METHOD_CALL_DISCARDED";

  /// Joining direct conversation is not allowed.
  static const String ERROR_EDITING_PARTICIPANTS_IN_DIRECT =
      "ERROR_EDITING_PARTICIPANTS_IN_DIRECT";

  /// Leaving direct conversation is not allowed.
  static const String ERROR_LEAVING_DIRECT_NOT_ALLOWED =
      "ERROR_LEAVING_DIRECT_NOT_ALLOWED";

  /// Specify at least two parameters: eventsFrom, eventsTo, count.
  static const String ERROR_SPECIFY_AT_LEAST_TWO_PARAMS =
      "ERROR_SPECIFY_AT_LEAST_TWO_PARAMS";

  /// Passing the 'eventsFrom', 'eventsTo' and 'count' parameters simultaneously
  /// is not allowed. You should use only two of these parameters.
  static const String ERROR_SPECIFY_MAXIMUM_TWO_PARAMS =
      "ERROR_SPECIFY_MAXIMUM_TWO_PARAMS";

  /// Removing participant from direct conversation is not allowed.
  static const String ERROR_REMOVING_FROM_DIRECT = "ERROR_REMOVING_FROM_DIRECT";

  /// Adding participant to direct conversation is not allowed.
  static const String ERROR_ADDING_TO_DIRECT = "ERROR_ADDING_TO_DIRECT";

  /// N messages per second limit reached. Please try again later.
  static const String ERROR_LIMIT_PER_SECOND = "ERROR_LIMIT_PER_SECOND";

  /// N messages per minute limit reached. Please try again later.
  static const String ERROR_LIMIT_PER_MINUTE = "ERROR_LIMIT_PER_MINUTE";

  ///  Direct conversation cannot be public or uber.
  static const String ERROR_DIRECT_CANNOT_BE_PUBLIC_OR_UBER =
      "ERROR_DIRECT_CANNOT_BE_PUBLIC_OR_UBER";

  /// Direct conversation is allowed between two users only.
  static const String ERROR_NUMBER_OF_USERS_IN_DIRECT =
      "ERROR_NUMBER_OF_USERS_IN_DIRECT";

  /// The 'seq' parameter value is greater than currently possible.
  static const String ERROR_WRONG_SEQUENCE_ARGUMENT =
      "ERROR_WRONG_SEQUENCE_ARGUMENT";

  /// The 'from' field value is greater than the 'to' field value.
  static const String ERROR_FROM_GREATER_THAN_TO = "ERROR_FROM_GREATER_THAN_TO";

  /// Number of requested objects is larger than allowed by the service.
  static const String ERROR_REQUESTED_NUMBER_TOO_BIG =
      "ERROR_REQUESTED_NUMBER_TOO_BIG";

  /// Number of requested objects is 0 or larger than allowed by the service.
  static const String ERROR_REQUESTED_NUMBER_TOO_BIG_OR_0 =
      "ERROR_REQUESTED_NUMBER_TOO_BIG_OR_0";

  /// Response timeout.
  static const String ERROR_TIMEOUT = "ERROR_TIMEOUT";

  /// User is not authorized.
  static const String ERROR_NOT_AUTHORIZED = "ERROR_NOT_AUTHORIZED";

  /// Failed to process response.
  static const String ERROR_FAILED_TO_PROCESS_RESPONSE =
      "ERROR_FAILED_TO_PROCESS_RESPONSE";

  /// Internal error.
  static const String ERROR_INTERNAL = "ERROR_INTERNAL";

  /// Invalid argument(s). | Message text exceeds the length limit.
  static const String ERROR_INVALID_ARGUMENTS = "ERROR_INVALID_ARGUMENTS";

  /// Client is not logged in.
  static const String ERROR_CLIENT_NOT_LOGGED_IN = "ERROR_CLIENT_NOT_LOGGED_IN";

  /// The notification event is incorrect.
  static const String ERROR_NOTIFICATION_EVENT_INCORRECT =
      "ERROR_NOTIFICATION_EVENT_INCORRECT";
}
