part of voximplant;

/// Represents quality issue levels.
enum VIQualityIssueLevel {
  /// The quality issue level to indicate that an issue is not detected or
  /// is resolved.
  None,

  /// The quality issue level to indicate that an issue may have minor
  /// impact on the call quality.
  ///
  /// For audio calls it may result in temporary audio artifacts.
  ///
  /// For video calls it may result in video artifacts in case of a
  /// dynamically changing video stream.
  Minor,

  /// The quality issue level to indicate that a detected issue may have a major
  /// impact on the call quality.
  ///
  /// For audio calls it may result in a corrupted stream (discord or
  /// robotic voice) for call participants, audio delays and glitches.
  ///
  /// For video calls it may result in significant video artifacts (pixelating,
  /// blurring, color bleeding, flickering, noise), one-way/no video stream
  /// between the call participants
  Major,

  /// The quality issue level to indicate that a detected issue has a critical
  /// impact on the call quality.
  ///
  /// In most cases it results in lost media stream between call participants
  /// or broken functionality.
  Critical,
}

/// Represents quality issue types.
enum VIQualityIssueType {
  /// Indicates that local video is encoded by a codec different from the
  /// specified one.
  CodecMismatch,

  /// Indicates that the video resolution sent to the endpoint is lower than a
  /// captured video resolution.
  LocalVideoDegradation,

  /// Indicates that network-based media latency is detected in the call.
  HighMediaLatency,

  /// Indicates that ICE connection is switched to the "disconnected" state
  /// during the call.
  IceDisconnected,

  /// Indicates that no audio is captured by the microphone.
  NoAudioSignal,

  /// Indicates packet loss for last 2.5 seconds.
  PacketLoss,

  /// Indicates that no audio is received on a remote audio stream.
  ///
  /// The issue level obtained may be:
  /// * [VIQualityIssueLevel.None] - that indicates that
  /// audio is receiving on all remote audio streams
  /// * [VIQualityIssueLevel.Critical] - that indicates a
  /// problem with audio receive on at least one remote audio stream
  NoAudioReceive,

  /// Indicates that no video is received on a remote video stream.
  ///
  /// The issue level obtained may be:
  /// * [VIQualityIssueLevel.None] - that indicates that
  /// video is receiving on all remote video streams according to their configuration
  /// * [VIQualityIssueLevel.Critical] - that indicates a
  /// problem with video receive on at least one remote video stream
  NoVideoReceive,
}

/// Represents a captured or sent frame size.
class VIFrameSize {
  final int width;
  final int height;

  VIFrameSize({required this.width, required this.height});
}

/// Represents the superclass of all quality issues during a call.
///
/// Quality issues that are detected during a call:
///
/// * [VICodecMismatch]
/// * [VILocalVideoDegradation]
/// * [VIHighMediaLatency]
/// * [VIIceDisconnected]
/// * [VINoAudioSignal]
/// * [VIPacketLoss]
/// * [VINoAudioReceive]
/// * [VINoVideoReceive]
abstract class VIQualityIssue {
  /// Issue level
  final VIQualityIssueLevel level;

  VIQualityIssue._fromMap(Map<dynamic, dynamic> map)
      : this.level = VIQualityIssueLevel.values[map['issueLevel']];
}

/// Represents a quality issue reporting that the local video is encoded by a
/// codec different from specified one in [VICallSettings.preferredVideoCodec].
///
/// Issue level is [VIQualityIssueLevel.Critical] if video
/// is not sent, [VIQualityIssueLevel.Major] in case of
/// codec mismatch or [VIQualityIssueLevel.None] if the issue
/// is not detected.
///
/// Possible reasons:
/// * The video is not sent for some reasons. In this case codec will be null
/// * Different codecs are specified in the call endpoints
///
/// A subclass of [VIQualityIssue]
class VICodecMismatch extends VIQualityIssue {
  /// Codec that is currently used or null if the video is not sent
  final String? codec;

  VICodecMismatch._fromMap(Map<dynamic, dynamic> map)
      : this.codec = map['codec'],
        super._fromMap(map);
}

/// Represents a quality issue reporting that the video resolution sent to the
/// endpoint is lower than a captured video resolution. As a result it affects
/// remote video quality on the remote participant side, but do not affect the
/// quality of local video preview on the android application.
///
/// The issue level may vary during the call.
///
/// Possible reasons:
///
/// * High CPU load during the video call
/// * Network issues such as poor internet connection or low bandwidth
///
/// A subclass of [VIQualityIssue]
class VILocalVideoDegradation extends VIQualityIssue {
  /// Sent frame size.
  final VIFrameSize actualSize;

  /// Captured frame size.
  final VIFrameSize targetSize;

  VILocalVideoDegradation._fromMap(Map<dynamic, dynamic> map)
      : this.actualSize = VIFrameSize(
            width: map['actualSizeStruct']['width'],
            height: map['actualSizeStruct']['height']),
        this.targetSize = VIFrameSize(
            width: map['targetSizeStruct']['width'],
            height: map['targetSizeStruct']['height']),
        super._fromMap(map);
}

/// Represents a quality issue reporting that the network-based media latency
/// is detected in the call.
/// Network-based media latency is calculated based on rtt (round trip time)
/// and jitter buffer. Latency refers to the time it takes a voice/video packet
/// to reach its destination. Sufficient latency causes call participants
/// to speak over the top of each other.
///
/// Issue level may vary during the call.
///
/// Possible reasons:
///
/// * Network congestion/delays
/// * Lack of bandwidth
///
/// A subclass of [VIQualityIssue]
class VIHighMediaLatency extends VIQualityIssue {
  /// Network-based latency measured in milliseconds at the moment
  /// the issue triggered.
  final double latency;

  VIHighMediaLatency._fromMap(Map<dynamic, dynamic> map)
      : this.latency = map['latency'],
        super._fromMap(map);
}

/// Represents a quality issue reporting that the ICE connection is switched to
/// the "disconnected" state during the call
///
/// Issue level is always [VIQualityIssueLevel.Critical],
/// because there is no media in the call until the issue is resolved.
///
/// Event may be triggered intermittently and be resolved just as spontaneously
/// on less reliable networks, or during temporary disconnections.
///
/// Possible reasons:
///
/// * Network issues
///
/// A subclass of [VIQualityIssue]
class VIIceDisconnected extends VIQualityIssue {
  VIIceDisconnected._fromMap(Map<dynamic, dynamic> map) : super._fromMap(map);
}

/// Represents a quality issue reporting that no audio is captured by the
/// microphone.
///
/// Issue level can be only [VIQualityIssueLevel.Critical]
/// if the issue is detected or [VIQualityIssueLevel.None] if the issue is not
/// detected or resolved.
///
/// Possible reasons:
///
/// * Access to microphone is denied
/// * Category of AVAudioSession is not AVAudioSessionCategoryPlayAndRecord
///
/// A subclass of [VIQualityIssue]
class VINoAudioSignal extends VIQualityIssue {
  VINoAudioSignal._fromMap(Map<dynamic, dynamic> map) : super._fromMap(map);
}

/// Represents a quality issue reporting that packet loss detection.
/// Packet loss can lead to missing of entire sentences, awkward pauses in the
/// middle of a conversation or robotic voice during the call.
///
/// Issue level may vary during the call.
///
/// Possible reasons:
///
/// * Network congestion
/// * Bad hardware (parts of the network infrastructure)
///
/// A subclass of [VIQualityIssue]
class VIPacketLoss extends VIQualityIssue {
  /// Average packet loss for 2.5 seconds.
  final double packetLoss;

  VIPacketLoss._fromMap(Map<dynamic, dynamic> map)
      : this.packetLoss = map['packetLoss'],
        super._fromMap(map);
}

/// Represents a quality issue reporting that no audio is received on the
/// remote audio stream.
///
/// Issue level can be only [VIQualityIssueLevel.Critical]
/// if the issue is detected or [VIQualityIssueLevel.None]
/// if the issue is not detected or resolved.
///
/// If no audio receive is detected on several remote audio streams,the
/// event will be invoked for each of the remote audio streams with the issue.
///
/// If the issue level is [VIQualityIssueLevel.Critical]
/// the event will not be invoked with the level [VIQualityIssueLevel.None] in cases:
///
/// * The (conference) call ended
/// * The endpoint left the conference call -
/// [VIEndpoint.onEndpointRemoved] is invoked
///
/// The issue is not detected for the following cases:
///
/// * The endpoint put the call on hold via [VICall.hold]
/// * The endpoint stopped sending audio during a call via [VICall.sendAudio]
///
/// Possible reasons:
///
/// * Poor internet connection on the client or the endpoint
/// * Connection lost on the endpoint
///
/// A subclass of [VIQualityIssue]
class VINoAudioReceive extends VIQualityIssue {
  /// Id remote audio stream the issue occured on.
  final String audiostreamId;

  /// Id endpoint the issue belongs to.
  final String endpointId;

  VINoAudioReceive._fromMap(Map<dynamic, dynamic> map)
      : this.audiostreamId = map['audiostreamId'],
        this.endpointId = map['endpointId'],
        super._fromMap(map);
}

/// Represents a quality issue reporting that no video is received on the
/// remote video stream.
///
/// Issue level can be only [VIQualityIssueLevel.Critical]
/// if the issue is detected or [VIQualityIssueLevel.None]
/// if the issue is not detected or resolved.
///
/// If no video receive is detected on several remote video streams,the
/// event will be invoked for each of the remote video streams with the issue.
///
/// If the issue level is [VIQualityIssueLevel.Critical]
/// the event will not be invoked with the level [VIQualityIssueLevel.None] in cases:
///
/// * The (conference) call ended
/// * The remote video stream was removed -
/// [VIEndpoint.onRemoteVideoStreamRemoved] is invoked
/// * The endpoint left the conference call -
/// [VIEndpoint.onEndpointRemoved] is invoked
///
/// The issue is not detected for the following cases:
///
/// * The endpoint put the call on hold via [VICall.hold]
/// * The endpoint stopped sending audio during a call via [VICall.sendVideo]
/// * Video receiving was stopped on the remote video stream via
/// [VIEndpoint.stopReceiving]
///
/// Possible reasons:
///
/// * Poor internet connection on the client or the endpoint
/// * Connection lost on the endpoint
/// * The endpoint's application has been moved to the background state on an
/// iOS device (camera usage is prohibited while in the background on iOS)
///
/// A subclass of [VIQualityIssue]
class VINoVideoReceive extends VIQualityIssue {
  /// Id remote video stream the issue occured on.
  final String videostreamId;

  /// Id endpoint the issue belongs to.
  final String endpointId;

  VINoVideoReceive._fromMap(Map<dynamic, dynamic> map)
      : this.videostreamId = map['videostreamId'],
        this.endpointId = map['endpointId'],
        super._fromMap(map);
}

/// Represents a quality issue.
class _VICallQualityIssue {
  String _callId;

  StreamController<VIQualityIssue> _qualityStreamController =
      StreamController.broadcast();

  _VICallQualityIssue._(this._callId) {
    _subscribeToIssues();
  }

  void _subscribeToIssues() {
    EventChannel('plugins.voximplant.com/quality_issues_call_$_callId')
        .receiveBroadcastStream(
            'plugins.voximplant.com/quality_issues_call_$_callId')
        .listen(_listener);
  }

  void _listener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'VIQualityIssueTypePacketLoss':
        _qualityStreamController.add(VIPacketLoss._fromMap(map));
        break;
      case 'VIQualityIssueTypeCodecMismatch':
        _qualityStreamController.add(VICodecMismatch._fromMap(map));
        break;
      case 'VIQualityIssueTypeLocalVideoDegradation':
        _qualityStreamController.add(VILocalVideoDegradation._fromMap(map));
        break;
      case 'VIQualityIssueTypeIceDisconnected':
        _qualityStreamController.add(VIIceDisconnected._fromMap(map));
        break;
      case 'VIQualityIssueTypeHighMediaLatency':
        _qualityStreamController.add(VIHighMediaLatency._fromMap(map));
        break;
      case 'VIQualityIssueTypeNoAudioSignal':
        _qualityStreamController.add(VINoAudioSignal._fromMap(map));
        break;
      case 'VIQualityIssueTypeNoAudioReceive':
        _qualityStreamController.add(VINoAudioReceive._fromMap(map));
        break;
      case 'VIQualityIssueTypeNoVideoReceive':
        _qualityStreamController.add(VINoVideoReceive._fromMap(map));
        break;
    }
  }
}
