/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Signature for callbacks reporting that the endpoint information such as
/// display name, user name, and SIP URI is updates.
///
/// Used in [VIEndpoint].
///
/// `endpoint` - VIEndpoint instance initiated the event
typedef void VIEndpointUpdated(VIEndpoint endpoint);

/// Signature for callbacks reporting that the endpoint removed from a call.
///
/// Used in [VIEndpoint].
///
/// `endpoint` - VIEndpoint instance initiated the event
typedef void VIEndpointRemoved(VIEndpoint endpoint);

/// Signature for callbacks reporting that the endpoint added the video stream
/// to the call.
///
/// Used in [VIEndpoint].
/// `endpoint` - VIEndpoint instance initiated the event
///
/// `videoStream` - Remote video stream
typedef void VIRemoteVideoStreamAdded(
  VIEndpoint endpoint,
  VIVideoStream videoStream,
);

/// Signature for callbacks reporting that the endpoint removed the video stream
/// from the call.
///
/// This callback is not triggered on call end.
///
/// Used in [VIEndpoint].
///
/// `endpoint` - VIEndpoint instance initiated the event
///
/// `videoStream` - Remote video stream
typedef void VIRemoteVideoStreamRemoved(
  VIEndpoint endpoint,
  VIVideoStream videoStream,
);

/// Signature for callbacks reporting when a voice activity of the endpoint is
/// detected in a conference call.
///
/// Used in [VIEndpoint].
/// `endpoint` - VIEndpoint instance initiated the event
typedef void VIVoiceActivityStarted(VIEndpoint endpoint);

/// Signature for callbacks reporting when a voice activity of the endpoint is
/// stopped in a conference call.
///
/// Used in [VIEndpoint].
/// `endpoint` - VIEndpoint instance initiated the event
typedef void VIVoiceActivityStopped(VIEndpoint endpoint);

/// Represents a remote call participant.
class VIEndpoint {
  /// Callback for getting notified when the endpoint information is updated.
  VIEndpointUpdated? onEndpointUpdated;

  /// Callback for getting notified when the endpoint is removed from the call.
  /// It is not triggered on call end.
  VIEndpointRemoved? onEndpointRemoved;

  /// Callback for getting notified when the endpoint added the video stream to
  /// the call.
  VIRemoteVideoStreamAdded? onRemoteVideoStreamAdded;

  /// Callback for getting notified when the endpoint removed the video stream
  /// from the call.
  VIRemoteVideoStreamRemoved? onRemoteVideoStreamRemoved;

  /// Callback for getting notified when a voice activity is detected
  /// in a conference call.
  VIVoiceActivityStarted? onVoiceActivityStarted;

  /// Callback for getting notified when a voice activity is stopped
  /// in a conference call.
  VIVoiceActivityStopped? onVoiceActivityStopped;

  String? _userName;
  String? _displayName;
  String? _sipUri;
  final String _endpointId;
  int? _place;
  List<VIVideoStream> _remoteVideoStreams = [];
  late MethodChannel _channel;

  /// This endpoint's user name.
  String? get userName => _userName;

  /// This endpoint's display name.
  String? get displayName => _displayName;

  /// This endpoint's SIP URI.
  String? get sipUri => _sipUri;

  /// The endpoint id.
  String get endpointId => _endpointId;

  /// All active video streams of the endpoint.
  List<VIVideoStream> get remoteVideoStreams => _remoteVideoStreams;

  /// Place of this endpoint in a video conference.
  /// May be used as a position of this endpoint’s video stream
  /// to render in a video conference call.
  int? get place => _place;

  VIEndpoint._(
    this._endpointId,
    this._userName,
    this._displayName,
    this._sipUri,
    this._place,
  );

  /// Starts receiving video on the video stream.
  ///
  /// Valid only for conferences.
  ///
  /// `streamId` - Remote video stream id
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_REJECTED] - If the operation is rejected.
  /// * [VICallError.ERROR_TIMEOUT] - If the operation is not completed in time.
  /// * [VICallError.ERROR_MEDIA_IS_ON_HOLD] - If the call is currently on hold.
  /// * [VICallError.ERROR_ALREADY_IN_THIS_STATE] - If the call is already in
  ///   the requested state.
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - If the call is not connected.
  /// * [VICallError.ERROR_INTERNAL] - If an internal error occurred.
  Future<void> startReceiving(String streamId) async {
    try {
      await _channel.invokeMethod<void>('Call.startReceivingRemoteVideoStream',
          <String, dynamic>{'streamId': streamId});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Stops receiving video on the video stream.
  ///
  /// Valid only for conferences.
  ///
  /// `streamId` - Remote video stream id
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_REJECTED] - If the operation is rejected.
  /// * [VICallError.ERROR_TIMEOUT] - If the operation is not completed in time.
  /// * [VICallError.ERROR_MEDIA_IS_ON_HOLD] - If the call is currently on hold.
  /// * [VICallError.ERROR_ALREADY_IN_THIS_STATE] - If the call is already in
  ///   the requested state.
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - If the call is not connected.
  /// * [VICallError.ERROR_INTERNAL] - If an internal error occurred.
  Future<void> stopReceiving(String streamId) async {
    try {
      await _channel.invokeMethod<void>('Call.stopReceivingRemoteVideoStream',
          <String, dynamic>{'streamId': streamId});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Requests the specified video size for the video stream.
  ///
  /// The stream resolution may be changed to the closest
  /// to the specified width and height.
  ///
  /// Valid only for conferences.
  ///
  /// `streamId` - Remote video stream id
  ///
  /// `width` - Requested width of the video stream
  ///
  /// `height` - Requested height of the video stream
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_INVALID_ARGUMENTS] - If failed to find remote video
  /// stream by provided video stream id
  Future<void> requestVideoSize(String streamId, int width, int height) async {
    try {
      await _channel.invokeMethod<void>(
          'Call.requestVideoSizeRemoteVideoStream', <String, dynamic>{
        'streamId': streamId,
        'width': width,
        'height': height
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  _invokeEndpointUpdatedEvent(
    String? username,
    String? displayName,
    String? sipUri,
    int? place,
  ) {
    this._displayName = displayName;
    this._userName = username;
    this._sipUri = sipUri;
    this._place = place;
    onEndpointUpdated?.call(this);
  }

  _invokeEndpointRemovedEvent() {
    onEndpointRemoved?.call(this);
  }

  _remoteVideoStreamAdded(VIVideoStream videoStream) {
    _remoteVideoStreams.add(videoStream);
    onRemoteVideoStreamAdded?.call(this, videoStream);
  }

  _remoteVideoStreamRemoved(String? videoStreamId) {
    VIVideoStream? remoteVideoStream;
    for (VIVideoStream videoStream in _remoteVideoStreams) {
      if (videoStream.streamId == videoStreamId) {
        remoteVideoStream = videoStream;
        break;
      }
    }
    if (remoteVideoStream != null) {
      onRemoteVideoStreamRemoved?.call(this, remoteVideoStream);
      _remoteVideoStreams.remove(remoteVideoStream);
    }
  }

  _voiceActivityStarted() {
    onVoiceActivityStarted?.call(this);
  }

  _voiceActivityStopped() {
    onVoiceActivityStopped?.call(this);
  }
}
