part of voximplant;

/// Represents quality issue levels.
enum VIQualityIssueLevel {
  VIQualityIssueLevelNone,
  VIQualityIssueLevelMinor,
  VIQualityIssueLevelMajor,
  VIQualityIssueLevelCritical,
}

/// Represents quality issue types.
enum VIQualityIssueType {
  VIQualityIssueTypeCodecMismatch,
  VIQualityIssueTypeLocalVideoDegradation,
  VIQualityIssueTypeHighMediaLatency,
  VIQualityIssueTypeIceDisconnected,
  VIQualityIssueTypeNoAudioSignal,
  VIQualityIssueTypePacketLoss,
  VIQualityIssueTypeNoAudioReceive,
  VIQualityIssueTypeNoVideoReceive,
}

/// Represents send or captured frame size.
class FrameSize {
  double width;
  double height;

  FrameSize({required this.width, required this.height});
}

/// Signature for base event that detected quality issues.
abstract class QualityIssueEvent {}

/// Signature for events reporting that local video is encoded by a codec
/// different from specified in [VICallSettings]
///
/// `codec` - Codec that is currently used or null if the video is not sent.
///
/// `level` - Issue level
class CodecMismatch implements QualityIssueEvent {
  final String? codec;
  final VIQualityIssueLevel level;

  CodecMismatch({required this.level, required this.codec});
}

/// Signature for events reporting that video resolution sent to the endpoint
/// is lower than a captured video resolution.
///
/// `actualSize` - Sent frame size.
///
/// `targetSize` - Captured frame size.
///
/// `level` - Issue level
class LocalVideoDegradation implements QualityIssueEvent {
  final FrameSize actualSize;
  final FrameSize targetSize;
  final VIQualityIssueLevel level;

  LocalVideoDegradation({
    required this.actualSize,
    required this.targetSize,
    required this.level,
  });
}

/// Signature for events reporting that network-based media latency
/// is detected in the call.
///
/// `latency` - Network-based latency measured in milliseconds at the moment
/// the issue triggered.
///
/// `level` - Issue level
class HighMediaLatency implements QualityIssueEvent {
  final double latency;
  final VIQualityIssueLevel level;

  HighMediaLatency({required this.latency, required this.level});
}

/// Signature for events reporting that ICE connection is switched to the
/// "disconnected" state during the call
///
/// `level` - Issue level
class IceDisconnected implements QualityIssueEvent {
  final VIQualityIssueLevel level;

  IceDisconnected({required this.level});
}

/// Signature for events reporting that no audio is captured by the microphone.
///
/// `level` - Issue level
class NoAudioSignal implements QualityIssueEvent {
  final VIQualityIssueLevel level;

  NoAudioSignal({
    required this.level,
  });
}

/// Signature for events reporting that packet loss detection.
///
/// `packetLoss` - Average packet loss for 2.5 seconds.
///
/// `level` - Issue level
class PacketLoss implements QualityIssueEvent {
  final double packetLoss;
  final VIQualityIssueLevel level;

  PacketLoss({
    required this.packetLoss,
    required this.level,
  });
}

/// Signature for events reporting that no audio is received on the
/// remote audio stream.
///
/// `audiostreamId` - Id remote audio stream the issue occured on.
///
/// `endpointId` - Id endpoint the issue belongs to.
///
/// `level` - Issue level
class NoAudioReceive implements QualityIssueEvent {
  final String audiostreamId;
  final String endpointId;
  final VIQualityIssueLevel level;

  NoAudioReceive({
    required this.audiostreamId,
    required this.endpointId,
    required this.level,
  });
}

/// Signature for events reporting that no video is received on the
/// remote video stream.
///
/// `videostreamId` - Id remote video stream the issue occured on.
///
/// `endpointId` - Id endpoint the issue belongs to.
///
/// `level` - Issue level
class NoVideoReceive implements QualityIssueEvent {
  final String videostreamId;
  final String endpointId;
  final VIQualityIssueLevel level;

  NoVideoReceive({
    required this.videostreamId,
    required this.endpointId,
    required this.level,
  });
}

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
