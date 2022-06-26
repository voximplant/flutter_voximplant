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
/// different from specified in [VICallSettings.preferredVideoCodec]
class CodecMismatch implements QualityIssueEvent {
  // Codec that is currently used or null if the video is not sent
  final String? codec;

  /// Issue level
  final VIQualityIssueLevel level;

  CodecMismatch({required this.level, required this.codec});
}

/// Represents class reporting that video resolution sent to the endpoint
/// is lower than a captured video resolution.
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
class IceDisconnected implements QualityIssueEvent {
  /// Issue level
  final VIQualityIssueLevel level;

  IceDisconnected({required this.level});
}

/// Represents class reporting that no audio is captured by the microphone.
class NoAudioSignal implements QualityIssueEvent {
  /// Issue level
  final VIQualityIssueLevel level;

  NoAudioSignal({
    required this.level,
  });
}

/// Represents class reporting that packet loss detection.
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
