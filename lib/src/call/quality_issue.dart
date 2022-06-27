part of voximplant;

/// Represents quality issue levels.
enum VIQualityIssueLevel {
  /// The quality issue level to indicate that an issue is not detected or
  /// is resolved.
  VIQualityIssueLevelNone,

  /// The quality issue level to indicate that an issue may have minor
  /// impact on the call quality.
  ///
  /// For audio calls it may result in temporary audio artifacts.
  ///
  /// For video calls it may result in video artifacts in case of a
  /// dynamically changing video stream.
  VIQualityIssueLevelMinor,

  /// The quality issue level to indicate that a detected issue may have a major
  /// impact on the call quality.
  ///
  /// For audio calls it may result in a corrupted stream (discord or
  /// robotic voice) for call participants, audio delays and glitches.
  ///
  /// For video calls it may result in significant video artifacts (pixelating,
  /// blurring, color bleeding, flickering, noise), one-way/no video stream
  /// between the call participants
  VIQualityIssueLevelMajor,

  /// The quality issue level to indicate that a detected issue has a critical
  /// impact on the call quality.
  ///
  /// In most cases it results in lost media stream between call participants
  /// or broken functionality.
  VIQualityIssueLevelCritical,
}

/// Represents quality issue types.
enum VIQualityIssueType {
  /// Indicates that local video is encoded by a codec different from the
  /// specified one.
  VIQualityIssueTypeCodecMismatch,

  /// Indicates that the video resolution sent to the endpoint is lower than a
  /// captured video resolution.
  VIQualityIssueTypeLocalVideoDegradation,

  /// Indicates that network-based media latency is detected in the call.
  VIQualityIssueTypeHighMediaLatency,

  /// Indicates that ICE connection is switched to the "disconnected" state
  /// during the call.
  VIQualityIssueTypeIceDisconnected,

  /// Indicates that no audio is captured by the microphone.
  VIQualityIssueTypeNoAudioSignal,

  /// Indicates packet loss for last 2.5 seconds.
  VIQualityIssueTypePacketLoss,

  /// Indicates that no audio is received on a remote audio stream.
  ///
  /// The issue level obtained may be:
  /// * [VIQualityIssueLevel.VIQualityIssueLevelNone] - that indicates that
  /// audio is receiving on all remote audio streams
  /// * [VIQualityIssueLevel.VIQualityIssueLevelCritical] - that indicates a
  /// problem with audio receive on at least one remote audio stream
  VIQualityIssueTypeNoAudioReceive,

  /// Indicates that no video is received on a remote video stream.
  ///
  /// The issue level obtained may be:
  /// * [VIQualityIssueLevel.VIQualityIssueLevelNone] - that indicates that
  /// video is receiving on all remote video streams according to their configuration
  /// * [VIQualityIssueLevel.VIQualityIssueLevelCritical] - that indicates a
  /// problem with video receive on at least one remote video stream
  VIQualityIssueTypeNoVideoReceive,
}

/// Represents send or captured a frame size.
class FrameSize {
  double width;
  double height;

  FrameSize({required this.width, required this.height});
}

/// Represents issues that affect call quality during a call.
abstract class QualityIssueEvent {}

/// Represents class reporting that local video is encoded by a codec
/// different from specified in `VICallSettings.preferredVideoCodec`.
///
/// Issue level is `VIQualityIssueLevel.VIQualityIssueLevelCritical` if video
/// is not sent, `VIQualityIssueLevel.VIQualityIssueLevelMajor` in case of
/// codec mismatch or `VIQualityIssueLevel.VIQualityIssueLevelNone` if the issue
/// is not detected.
///
/// Possible reasons:
/// * The video is not sent for some reasons. In this case codec will be null
/// * Different codecs are specified in the call endpoints
class CodecMismatch implements QualityIssueEvent {
  // Codec that is currently used or null if the video is not sent
  final String? codec;

  /// Issue level
  final VIQualityIssueLevel level;

  CodecMismatch({required this.level, required this.codec});
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
class LocalVideoDegradation implements QualityIssueEvent {
  /// Sent frame size.
  final FrameSize actualSize;

  /// Captured frame size.
  final FrameSize targetSize;

  ///Issue level
  final VIQualityIssueLevel level;

  LocalVideoDegradation({
    required this.actualSize,
    required this.targetSize,
    required this.level,
  });
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
class HighMediaLatency implements QualityIssueEvent {
  /// Network-based latency measured in milliseconds at the moment
  /// the issue triggered.
  final double latency;

  /// Issue level
  final VIQualityIssueLevel level;

  HighMediaLatency({required this.latency, required this.level});
}

/// Represents class reporting that ICE connection is switched to the
/// "disconnected" state during the call
///
/// Issue level is always `VIQualityIssueLevel.VIQualityIssueLevelCritical`,
/// because there is no media in the call until the issue is resolved.
///
/// Event may be triggered intermittently and be resolved just as spontaneously
/// on less reliable networks, or during temporary disconnections.
///
/// Possible reasons:
///
/// * Network issues
class IceDisconnected implements QualityIssueEvent {
  /// Issue level
  final VIQualityIssueLevel level;

  IceDisconnected({required this.level});
}

/// Represents class reporting that no audio is captured by the microphone.
///
/// Issue level can be only `VIQualityIssueLevel.VIQualityIssueLevelCritical`
/// if the issue is detected or VIQualityIssueLevelNone if the issue is not
/// detected or resolved.
///
/// Possible reasons:
///
/// * Access to microphone is denied
/// * Category of AVAudioSession is not AVAudioSessionCategoryPlayAndRecord
class NoAudioSignal implements QualityIssueEvent {
  /// Issue level
  final VIQualityIssueLevel level;

  NoAudioSignal({
    required this.level,
  });
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
class PacketLoss implements QualityIssueEvent {
  /// Average packet loss for 2.5 seconds.
  final double packetLoss;

  /// Issue level
  final VIQualityIssueLevel level;

  PacketLoss({
    required this.packetLoss,
    required this.level,
  });
}

/// Represents class reporting that no audio is received on the
/// remote audio stream.
///
/// Issue level can be only `VIQualityIssueLevel.VIQualityIssueLevelCritical`
/// if the issue is detected or `VIQualityIssueLevel.VIQualityIssueLevelNone`
/// if the issue is not detected or resolved.
///
/// If no audio receive is detected on several remote audio streams,the
/// event will be invoked for each of the remote audio streams with the issue.
///
/// If the issue level is `VIQualityIssueLevel.VIQualityIssueLevelCritical`
/// the event will not be invoked with the level VIQualityIssueLevelNone in cases:
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
class NoAudioReceive implements QualityIssueEvent {
  /// Id remote audio stream the issue occured on.
  final String audiostreamId;

  /// Id endpoint the issue belongs to.
  final String endpointId;

  /// Issue level
  final VIQualityIssueLevel level;

  NoAudioReceive({
    required this.audiostreamId,
    required this.endpointId,
    required this.level,
  });
}

/// Represents class reporting that no video is received on the
/// remote video stream.
///
/// Issue level can be only `VIQualityIssueLevel.VIQualityIssueLevelCritical`
/// if the issue is detected or `VIQualityIssueLevel.VIQualityIssueLevelNone`
/// if the issue is not detected or resolved.
///
/// If no video receive is detected on several remote video streams,the
/// event will be invoked for each of the remote video streams with the issue.
///
/// If the issue level is `VIQualityIssueLevel.VIQualityIssueLevelCritical`
/// the event will not be invoked with the level VIQualityIssueLevelNone in cases:
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
class NoVideoReceive implements QualityIssueEvent {
  /// Id remote video stream the issue occured on.
  final String videostreamId;

  /// Id endpoint the issue belongs to.
  final String endpointId;

  /// Issue level
  final VIQualityIssueLevel level;

  NoVideoReceive({
    required this.videostreamId,
    required this.endpointId,
    required this.level,
  });
}

/// Represents a quality issue.
class VIQualityIssue {
  StreamController<QualityIssueEvent> _qualityStreamController =
      StreamController.broadcast();

  VIQualityIssue._() {
    subscribeToIssues();
  }

  void subscribeToIssues() {
    EventChannel('plugins.voximplant.com/call_quality_issues')
        .receiveBroadcastStream('plugins.voximplant.com/call_quality_issues')
        .listen(_listener);
  }

  void _listener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'VIQualityIssueTypePacketLoss':
        double packetLoss = map['packetLoss'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController
            .add(PacketLoss(packetLoss: packetLoss, level: level));
        break;
      case 'VIQualityIssueTypeCodecMismatch':
        String? codec = map['codec'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController.add(CodecMismatch(level: level, codec: codec));
        break;
      case 'VIQualityIssueTypeLocalVideoDegradation':
        Map actualSize = map['actualSize'];
        Map targetSize = map['targetSize'];
        FrameSize actual =
            FrameSize(width: actualSize['width'], height: actualSize['height']);
        FrameSize target =
            FrameSize(width: targetSize['width'], height: targetSize['height']);
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController.add(LocalVideoDegradation(
            actualSize: actual, targetSize: target, level: level));
        break;
      case 'VIQualityIssueTypeIceDisconnected':
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController.add(IceDisconnected(level: level));
        break;
      case 'VIQualityIssueTypeHighMediaLatency':
        double latency = map['latency'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController
            .add(HighMediaLatency(latency: latency, level: level));
        break;
      case 'VIQualityIssueTypeNoAudioSignal':
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController.add(NoAudioSignal(level: level));
        break;
      case 'VIQualityIssueTypeNoAudioReceive':
        String audiostreamId = map['audiostreamId'];
        String endpointId = map['endpointId'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController.add(NoAudioReceive(
            audiostreamId: audiostreamId,
            endpointId: endpointId,
            level: level));
        break;
      case 'VIQualityIssueTypeNoVideoReceive':
        String videostreamId = map['videostreamId'];
        String endpointId = map['endpointId'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        _qualityStreamController.add(NoVideoReceive(
            videostreamId: videostreamId,
            endpointId: endpointId,
            level: level));
        break;
    }
  }
}
