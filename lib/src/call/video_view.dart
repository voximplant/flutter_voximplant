/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Represents supported video rotations.
enum VIVideoRotation {
  Rotation_0,
  Rotation_90,
  Rotation_180,
  Rotation_270,
}

/// Stateful widget to render local or remote video represented via [VIVideoStream].
///
/// Video stream should be connected with [VIVideoView] via the video stream id.
/// To render the video stream, it is required to set [VIVideoStream.streamId] to
/// [VIVideoViewController.streamId].
/// To stop rendering the video stream, [VIVideoViewController.streamId] should
/// be set to null.
///
/// Returns a Texture widget if streamId is set, or empty
/// Container widget if no [VIVideoStream] is connected.
class VIVideoView extends StatefulWidget {
  final VIVideoViewController controller;

  const VIVideoView(this.controller);

  @override
  State<StatefulWidget> createState() {
    return _VIVideoViewState(controller);
  }
}

class _VIVideoViewState extends State<VIVideoView> {
  final VIVideoViewController _controller;
  int? _textureId;

  _VIVideoViewState(this._controller) {
    _controller._textureChanged = _textureChanged;
  }

  void _textureChanged(int? textureId) {
    setState(() {
      _VILog._i('textureChanged: $textureId');
      _textureId = textureId;
    });
  }

  @override
  Widget build(BuildContext context) {
    var id = _textureId;
    return id != null ? Texture(textureId: id) : Container();
  }
}

typedef void _TextureChanged(int? textureId);

/// A controller for a video view.
class VIVideoViewController extends ValueNotifier<_VIVideoViewValue> {
  String? _streamId;
  StreamSubscription<dynamic>? _rendererSubscription;
  final MethodChannel _channel = Voximplant._channel;

  /// Current video frame width.
  ///
  /// Use [addListener] method to subscribe to the video frame width changes.
  int get width => value.width;

  /// Current video frame height.
  ///
  /// Use [addListener] method to subscribe to the video frame height changes.
  int get height => value.height;

  /// Current video aspect ratio.
  ///
  /// Use [addListener] method to subscribe to the video frame aspect ratio
  /// changes.
  double get aspectRatio => value.aspectRatio;

  /// Current video rotation.
  ///
  /// Use [addListener] method to subscribe to the video frame rotation changes.
  VIVideoRotation get rotation => value.rotation;

  set streamId(String? value) => _setStreamId(value);

  /// The id of the [VIVideoStream] to be rendered to the [VIVideoView] this
  /// controller belongs to.
  String? get streamId => _streamId;
  _TextureChanged? _textureChanged;

  VIVideoViewController() : super(_VIVideoViewValue());

  Future<void> _setStreamId(String? streamId) async {
    if (streamId != null) {
      if (this._streamId != null && this._streamId == streamId) {
        return Future<void>.value();
      }

      Map<String, int>? data = await _channel.invokeMapMethod<String, int>(
          'VideoStream.addVideoRenderer', <String, String>{
        'streamId': streamId,
      });

      if (data == null) {
        _VILog._w('VideoView: setStreamId: data was null, skipping');
        return;
      }

      _VILog._i('VideoView: setStreamId: textureId ${data['textureId']} '
          'is allocated for streamId $streamId');
      EventChannel rendererChannel =
          EventChannel('plugins.voximplant.com/renderer_${data['textureId']}');
      _rendererSubscription = rendererChannel
          .receiveBroadcastStream(
              'plugins.voximplant.com/renderer_${data['textureId']}')
          .listen(_onRendererEvent);
      _textureChanged?.call(data['textureId']);
      _streamId = streamId;
    } else {
      if (this._streamId == null) {
        return Future<void>.value();
      }
      await _channel
          .invokeMethod('VideoStream.removeVideoRenderer', <String, String?>{
        'streamId': this._streamId,
      });
      _rendererSubscription?.cancel();
      _rendererSubscription = null;
      _textureChanged?.call(null);
      _streamId = null;
    }
  }

  void _onRendererEvent(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'resolutionChanged') {
      _VILog._i(
          'VideoView: resolutionChanged: ${map['width']} x ${map['height']}, '
          'aspect ratio: ${map['aspectRatio']}, '
          'rotation: ${map['rotation']}, '
          'textureId: ${map['textureId']}');
      value = value.copyWith(
        width: map['width'],
        height: map['height'],
        aspectRatio: map['aspectRatio'],
        rotation: VIVideoRotation.values[map['rotation']],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _rendererSubscription?.cancel();
    _rendererSubscription = null;
  }
}

class _VIVideoViewValue {
  final int width;
  final int height;
  final double aspectRatio;
  final VIVideoRotation rotation;

  _VIVideoViewValue({
    this.width = 0,
    this.height = 0,
    this.aspectRatio = 1.0,
    this.rotation = VIVideoRotation.Rotation_0,
  });

  _VIVideoViewValue.copy(
    this.width,
    this.height,
    this.aspectRatio,
    this.rotation,
  );

  _VIVideoViewValue copyWith({
    int? width,
    int? height,
    double? aspectRatio,
    VIVideoRotation? rotation,
  }) =>
      _VIVideoViewValue.copy(
        width ?? this.width,
        height ?? this.height,
        aspectRatio ?? this.aspectRatio,
        rotation ?? this.rotation,
      );
}
