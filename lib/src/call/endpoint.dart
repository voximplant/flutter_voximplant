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

  String? _userName;
  String? _displayName;
  String? _sipUri;
  final String _endpointId;
  int? _place;
  List<VIVideoStream> _remoteVideoStreams = [];

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
}
