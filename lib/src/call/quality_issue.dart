part of voximplant;

enum VIQualityIssueLevel {
  VIQualityIssueLevelNone,
  VIQualityIssueLevelMinor,
  VIQualityIssueLevelMajor,
  VIQualityIssueLevelCritical,
}

typedef void VIQualityIssueTypeCodecMismatch(
    String? codec, VIQualityIssueLevel level);

typedef void VIQualityIssueTypeLocalVideoDegradation(
    double actualSize, double targetSize, VIQualityIssueLevel level);

typedef void VIQualityIssueTypeHighMediaLatency(
    DateTime latency, VIQualityIssueLevel level);

typedef void VIQualityIssueTypeIceDisconnected(VIQualityIssueLevel level);

typedef void VIQualityIssueTypeLowBandwidth(
    double actualBitrate, double targetBitrate, VIQualityIssueLevel level);

typedef void VIQualityIssueTypeNoAudioSignal(VIQualityIssueLevel level);

typedef void VIQualityIssueTypePacketLoss(
    double packetLoss, VIQualityIssueLevel level);

typedef void VIQualityIssueTypeNoAudioReceive(
    String endpointId, VIQualityIssueLevel level);

typedef void VIQualityIssueTypeNoVideoReceive(
    String endpointId, VIQualityIssueLevel level);

class VIQualityIssue {
  VIQualityIssueTypeCodecMismatch? onCodecMismatch;

  VIQualityIssueTypeLocalVideoDegradation? onLocalVideoDegradation;

  VIQualityIssueTypeHighMediaLatency? onHighMediaLatency;

  VIQualityIssueTypeIceDisconnected? onIceDisconnected;

  VIQualityIssueTypeLowBandwidth? onLowBandwidth;

  VIQualityIssueTypeNoAudioSignal? onNoAudioSignal;

  VIQualityIssueTypePacketLoss? onPacketLoss;

  VIQualityIssueTypeNoAudioReceive? onNoAudioReceive;

  VIQualityIssueTypeNoVideoReceive? onNoVideoReceive;

  String _callId;
  late StreamSubscription<dynamic> _eventSubscription;

  VIQualityIssue._(this._callId) {
    subscribeToIssues();
  }

  void subscribeToIssues() {
    this._eventSubscription =
        EventChannel('plugins.voximplant.com/call_$_callId')
            .receiveBroadcastStream('plugins.voximplant.com/call_$_callId')
            .listen(_listener);
  }

  void _listener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'callDisconnected':
        _eventSubscription.cancel();
        break;
      case 'callFailed':
        _eventSubscription.cancel();
        break;
      case 'VIQualityIssueTypePacketLoss':
        double packetLoss = map['packetLoss'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onPacketLoss?.call(packetLoss, level);
        break;
      case 'VIQualityIssueTypeCodecMismatch':
        String? codec = map['codec'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onCodecMismatch?.call(codec, level);
        break;
      case 'VIQualityIssueTypeLocalVideoDegradation':
        double actualSize = map['actualSize'];
        double targetSize = map['targetSize'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onLocalVideoDegradation?.call(actualSize, targetSize, level);
        break;
      case 'VIQualityIssueTypeIceDisconnected':
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onIceDisconnected?.call(level);
        break;
      case 'VIQualityIssueTypeHighMediaLatency':
        DateTime latency = map['latency'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onHighMediaLatency?.call(latency, level);
        break;
      case 'VIQualityIssueTypeLowBandwidth':
        double actualBitrate = map['actualBitrate'];
        double targetBitrate = map['targetBitrate'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onLowBandwidth?.call(actualBitrate, targetBitrate, level);
        break;
      case 'VIQualityIssueTypeNoAudioSignal':
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onNoAudioSignal?.call(level);
        break;
      case 'VIQualityIssueTypeNoAudioReceive':
        String endpointId = map['endpointId'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onNoAudioReceive?.call(endpointId, level);
        break;
      case 'VIQualityIssueTypeNoVideoReceive':
        String endpointId = map['endpointId'];
        VIQualityIssueLevel level =
            VIQualityIssueLevel.values[map['issueLevel']];
        onNoVideoReceive?.call(endpointId, level);
        break;
    }
  }
}
