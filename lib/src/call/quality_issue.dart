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

/// Represents send or captured a frame size.
class FrameSize {
  final double width;
  final double height;

  FrameSize({required this.width, required this.height});
}

/// Represents issues that affect call quality during a call.
abstract class QualityIssue {
  /// Issue level
  final VIQualityIssueLevel level;

  QualityIssue._fromMap(Map<dynamic, dynamic> map) : this.level = map['level'];
}

/// Represents class reporting that local video is encoded by a codec
/// different from specified in `VICallSettings.preferredVideoCodec`.
///
/// Issue level is `VIQualityIssueLevel.Critical` if video
/// is not sent, `VIQualityIssueLevel.Major` in case of
/// codec mismatch or `VIQualityIssueLevel.None` if the issue
/// is not detected.
///
/// Possible reasons:
/// * The video is not sent for some reasons. In this case codec will be null
/// * Different codecs are specified in the call endpoints
class CodecMismatch extends QualityIssue {
  // Codec that is currently used or null if the video is not sent
  final String? codec;

  CodecMismatch._fromMap(Map<dynamic, dynamic> map)
      : this.codec = map['codec'],
        super._fromMap(map);
}

/// Represents class reporting that video resolution sent to the endpoint
/// is lower than a captured video resolution. As a result it affects remote
/// video quality on the remote participant side, but do not affect the quality
/// of local video preview on the android application.
///
/// The issue level may vary during the call.
///
/// Possible reasons:
///
/// * High CPU load during the video call
/// * Network issues such as poor internet connection or low bandwidth
class LocalVideoDegradation extends QualityIssue {
  /// Sent frame size.
  final FrameSize actualSize;

  /// Captured frame size.
  final FrameSize targetSize;

  LocalVideoDegradation._fromMap(Map<dynamic, dynamic> map)
      : this.actualSize = FrameSize(
            width: map['actualSize']['width'],
            height: map['actualSize']['height']),
        this.targetSize = FrameSize(
            width: map['targetSize']['width'],
            height: map['targetSize']['height']),
        super._fromMap(map);
}

/// Represents class reporting that network-based media latency
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
class HighMediaLatency extends QualityIssue {
  /// Network-based latency measured in milliseconds at the moment
  /// the issue triggered.
  final double latency;

  HighMediaLatency._fromMap(Map<dynamic, dynamic> map)
      : this.latency = map['latency'],
        super._fromMap(map);
}

/// Represents class reporting that ICE connection is switched to the
/// "disconnected" state during the call
///
/// Issue level is always `VIQualityIssueLevel.Critical`,
/// because there is no media in the call until the issue is resolved.
///
/// Event may be triggered intermittently and be resolved just as spontaneously
/// on less reliable networks, or during temporary disconnections.
///
/// Possible reasons:
///
/// * Network issues
class IceDisconnected extends QualityIssue {
  IceDisconnected._fromMap(Map<dynamic, dynamic> map) : super._fromMap(map);
}

/// Represents class reporting that no audio is captured by the microphone.
///
/// Issue level can be only `VIQualityIssueLevel.Critical`
/// if the issue is detected or `VIQualityIssueLevel.None` if the issue is not
/// detected or resolved.
///
/// Possible reasons:
///
/// * Access to microphone is denied
/// * Category of AVAudioSession is not AVAudioSessionCategoryPlayAndRecord
class NoAudioSignal extends QualityIssue {
  NoAudioSignal._fromMap(Map<dynamic, dynamic> map) : super._fromMap(map);
}

/// Represents class reporting that packet loss detection. Packet loss can lead
/// to missing of entire sentences, awkward pauses in the middle of a
/// conversation or robotic voice during the call.
///
/// Issue level may vary during the call.
///
/// Possible reasons:
///
/// * Network congestion
/// * Bad hardware (parts of the network infrastructure)
class PacketLoss extends QualityIssue {
  /// Average packet loss for 2.5 seconds.
  final double packetLoss;

  PacketLoss._fromMap(Map<dynamic, dynamic> map)
      : this.packetLoss = map['packetLoss'],
        super._fromMap(map);
}

/// Represents class reporting that no audio is received on the
/// remote audio stream.
///
/// Issue level can be only `VIQualityIssueLevel.Critical`
/// if the issue is detected or `VIQualityIssueLevel.None`
/// if the issue is not detected or resolved.
///
/// If no audio receive is detected on several remote audio streams,the
/// event will be invoked for each of the remote audio streams with the issue.
///
/// If the issue level is `VIQualityIssueLevel.Critical`
/// the event will not be invoked with the level `VIQualityIssueLevel.None` in cases:
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
class NoAudioReceive extends QualityIssue {
  /// Id remote audio stream the issue occured on.
  final String audiostreamId;

  /// Id endpoint the issue belongs to.
  final String endpointId;

  NoAudioReceive._fromMap(Map<dynamic, dynamic> map)
      : this.audiostreamId = map['audiostreamId'],
        this.endpointId = map['endpointId'],
        super._fromMap(map);
}

/// Represents class reporting that no video is received on the
/// remote video stream.
///
/// Issue level can be only `VIQualityIssueLevel.Critical`
/// if the issue is detected or `VIQualityIssueLevel.None`
/// if the issue is not detected or resolved.
///
/// If no video receive is detected on several remote video streams,the
/// event will be invoked for each of the remote video streams with the issue.
///
/// If the issue level is `VIQualityIssueLevel.Critical`
/// the event will not be invoked with the level `VIQualityIssueLevel.None` in cases:
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
class NoVideoReceive extends QualityIssue {
  /// Id remote video stream the issue occured on.
  final String videostreamId;

  /// Id endpoint the issue belongs to.
  final String endpointId;

  NoVideoReceive._fromMap(Map<dynamic, dynamic> map)
      : this.videostreamId = map['videostreamId'],
        this.endpointId = map['endpointId'],
        super._fromMap(map);
}

/// Represents a quality issue.
class _VIQualityIssue {
  String _callId;

  StreamController<QualityIssue> _qualityStreamController =
      StreamController.broadcast();

  _VIQualityIssue._(this._callId) {
    subscribeToIssues();
  }

  void subscribeToIssues() {
    EventChannel('plugins.voximplant.com/quality_issues_call_$_callId')
        .receiveBroadcastStream(
            'plugins.voximplant.com/quality_issues_call_$_callId')
        .listen(_listener);
  }

  void _listener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'VIQualityIssueTypePacketLoss':
        _qualityStreamController.add(PacketLoss._fromMap(map));
        break;
      case 'VIQualityIssueTypeCodecMismatch':
        _qualityStreamController.add(CodecMismatch._fromMap(map));
        break;
      case 'VIQualityIssueTypeLocalVideoDegradation':
        _qualityStreamController.add(LocalVideoDegradation._fromMap(map));
        break;
      case 'VIQualityIssueTypeIceDisconnected':
        _qualityStreamController.add(IceDisconnected._fromMap(map));
        break;
      case 'VIQualityIssueTypeHighMediaLatency':
        _qualityStreamController.add(HighMediaLatency._fromMap(map));
        break;
      case 'VIQualityIssueTypeNoAudioSignal':
        _qualityStreamController.add(NoAudioSignal._fromMap(map));
        break;
      case 'VIQualityIssueTypeNoAudioReceive':
        _qualityStreamController.add(NoAudioReceive._fromMap(map));
        break;
      case 'VIQualityIssueTypeNoVideoReceive':
        _qualityStreamController.add(NoVideoReceive._fromMap(map));
        break;
    }
  }
}
