// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Enum that represents the reason why video receive on the remote
/// video stream has stopped.
///
/// /// Used in [VICall].
enum VIVideoStreamReceiveStopReason {
  /// Indicates that video receive on a remote video stream is stopped by
  /// the Voximplant cloud due to a network issue on the device.
  AUTOMATIC,

  /// Indicates that video receive on a remote video stream is stopped
  /// by the client via [VICall.sendVideo] API.
  MANUAL,
}

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

/// Signature for callbacks reporting that video receive on a remote video
/// stream is started after previously being stopped.
/// Available only for the conference calls.
///
/// The event is triggered if:
/// 1.[VIEndpoint.startReceiving] is called and the request has been processed
/// successfully.
/// 2. A network issue that caused the Voximplant cloud to stop video receive
/// of the remote video stream is gone.
///
/// The event is not triggered if the endpoint client has started sending video
/// via [VICall.sendVideo] API.
///
/// Used in [VIEndpoint].
///
/// `endpoint` - VIEndpoint instance initiated the event
///
/// `videoStream` - The remote video stream where video receive is started
typedef void VIStartReceivingVideoStream(
    VIEndpoint endpoint, VIVideoStream videoStream);

/// Signature for callbacks reporting that video receive on a remote video
/// stream is stopped. Available only for the conference calls.
///
/// Video receive on a remote video stream can be stopped due to:
/// 1. [VIEndpoint.stopReceiving] has called and the request has been processed
/// successfully. In this case the value of the [reason] parameter is
/// [VIVideoStreamReceiveStopReason.MANUAL].
/// 2.Voximplant cloud has detected a network issue on the client and
/// automatically stopped the video. In this case the value of the [reason]
/// parameter is [VIVideoStreamReceiveStopReason.AUTOMATIC].
///
/// If the video receive is disabled automatically, it may be automatically
/// enabled as soon as the network condition on the device is good and there is
/// enough bandwidth to receive the video on this remote video stream.
/// In this case event is triggered.
///
/// The event is not triggered if the endpoint client has started sending video
/// via [VICall.sendVideo] API.
///
/// Used in [VIEndpoint].
///
/// `endpoint` - VIEndpoint instance initiated the event
///
/// `videoStream` - The remote video stream where video receive is stopped
///
/// `reason` - The reason for the event, such as video receive is disabled
/// by client or automatically
typedef void VIStopReceivingVideoStream(VIEndpoint endpoint,
    VIVideoStream videoStream, VIVideoStreamReceiveStopReason reason);

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
  /// Triggered when the endpoint information is updated.
  VIEndpointUpdated? onEndpointUpdated;

  /// Triggered when the endpoint is removed from the call.
  /// The event is not triggered on the call end.
  VIEndpointRemoved? onEndpointRemoved;

  /// Triggered when the endpoint added the video stream to
  /// the call.
  VIRemoteVideoStreamAdded? onRemoteVideoStreamAdded;

  /// Triggered when the endpoint removed the video stream
  /// from the call.
  VIRemoteVideoStreamRemoved? onRemoteVideoStreamRemoved;

  /// Triggered when a voice activity is detected
  /// in a conference call.
  VIVoiceActivityStarted? onVoiceActivityStarted;

  /// Triggered when a voice activity is stopped
  /// in a conference call.
  VIVoiceActivityStopped? onVoiceActivityStopped;

  /// Triggered when video receive on a remote video
  /// stream is started after previously being stopped.
  /// Available only for the conference calls.
  VIStartReceivingVideoStream? onStartReceivingVideoStream;

  /// Triggered when video receive on a remote video
  /// stream is stopped. Available only for the conference calls.
  VIStopReceivingVideoStream? onStopReceivingVideoStream;

  String? _userName;
  String? _displayName;
  String? _sipUri;
  final String _endpointId;
  int? _place;
  final List<VIVideoStream> _remoteVideoStreams = [];
  final MethodChannel _channel = Voximplant._channel;

  /// Endpoint's user name.
  String? get userName => _userName;

  /// Endpoint's display name.
  String? get displayName => _displayName;

  /// Endpoint's SIP URI.
  String? get sipUri => _sipUri;

  /// Endpoint's ID.
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

  /// Starts receiving video on the remote video stream.
  ///
  /// Available only for conference calls.
  ///
  /// If the video is already receiving, this method call is ignored.
  ///
  /// If the request is processed successfully, [VIStartReceivingVideoStream]
  /// event is triggered.
  ///
  /// `streamId` - Remote video stream id
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_INTERNAL] - If an internal error occurred.
  Future<void> startReceiving(String streamId) async {
    try {
      await _channel.invokeMethod<void>(
          'VideoStream.startReceivingRemoteVideoStream',
          <String, dynamic>{'streamId': streamId});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Stops receiving video on the remote video stream.
  ///
  /// Available only for conference calls.
  ///
  /// If the request is processed successfully,
  /// [VIStopReceivingVideoStream] event is triggered with
  /// the reason [VIVideoStreamReceiveStopReason.MANUAL].
  ///
  /// `streamId` - Remote video stream id
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_INTERNAL] - If an internal error occurred.
  Future<void> stopReceiving(String streamId) async {
    try {
      await _channel.invokeMethod<void>(
          'VideoStream.stopReceivingRemoteVideoStream',
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
          'VideoStream.requestVideoSizeRemoteVideoStream', <String, dynamic>{
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
    _displayName = displayName;
    _userName = username;
    _sipUri = sipUri;
    _place = place;
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

  _startReceivingVideoStream(String videoStreamId) {
    VIVideoStream? remoteVideoStream;
    for (VIVideoStream videoStream in _remoteVideoStreams) {
      if (videoStream.streamId == videoStreamId) {
        remoteVideoStream = videoStream;
        break;
      }
    }
    if (remoteVideoStream != null) {
      onStartReceivingVideoStream?.call(this, remoteVideoStream);
    }
  }

  _stopReceivingVideoStream(
      String videoStreamId, VIVideoStreamReceiveStopReason reason) {
    VIVideoStream? remoteVideoStream;
    for (VIVideoStream videoStream in _remoteVideoStreams) {
      if (videoStream.streamId == videoStreamId) {
        remoteVideoStream = videoStream;
        break;
      }
    }
    if (remoteVideoStream != null) {
      onStopReceivingVideoStream?.call(this, remoteVideoStream, reason);
    }
  }
}
