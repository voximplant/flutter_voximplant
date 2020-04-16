/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

class _VIVideoViewValue {
  int _width;
  int _height;
  double _aspectRatio;
  VIVideoRotation _rotation;

  _VIVideoViewValue._() {
    _width = 0;
    _height = 0;
    _aspectRatio = 1.0;
    _rotation = VIVideoRotation.Rotation_0;
  }

  _VIVideoViewValue._copy(
      this._width, this._height, this._aspectRatio, this._rotation);

  _VIVideoViewValue _copyWith(
      int width, int height, double aspectRatio, VIVideoRotation rotation) {
    return _VIVideoViewValue._copy(width, height, aspectRatio, rotation);
  }
}

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
  int _textureId;

  _VIVideoViewState(this._controller) {
    _controller._textureChanged = _textureChanged;
  }

  void _textureChanged(int textureId) {
    setState(() {
      _VILog._i('textureChanged: $textureId');
      _textureId = textureId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _textureId != null ? Texture(textureId: _textureId) : Container();
  }
}

typedef void _TextureChanged(int textureId);

/// A controller for a video view.
class VIVideoViewController extends ValueNotifier<_VIVideoViewValue> {
  String _streamId;
  StreamSubscription<dynamic> _rendererSubscription;
  final MethodChannel _channel = Voximplant._channel;

  /// Current video frame width.
  ///
  /// Use [addListener] method to subscribe to the video frame width changes.
  int get width => value._width;

  /// Current video frame height.
  ///
  /// Use [addListener] method to subscribe to the video frame height changes.
  int get height => value._height;

  /// Current video aspect ratio.
  ///
  /// Use [addListener] method to subscribe to the video frame aspect ratio
  /// changes.
  double get aspectRatio => value._aspectRatio;

  /// Current video rotation.
  ///
  /// Use [addListener] method to subscribe to the video frame rotation changes.
  VIVideoRotation get rotation => value._rotation;

  set streamId(String value) => _setStreamId(value);

  /// The id of the [VIVideoStream] to be rendered to the [VIVideoView] this
  /// controller belongs to.
  String get streamId => _streamId;
  _TextureChanged _textureChanged;

  VIVideoViewController() : super(_VIVideoViewValue._());

  Future<void> _setStreamId(String streamId) async {
    if (this._streamId != null &&
        streamId != null &&
        this._streamId == streamId) {
      return Future<void>.value();
    }
    if (streamId != null) {
      Map<String, int> data =
          await _channel.invokeMapMethod('addVideoRenderer', <String, String>{
        'streamId': streamId,
      });
      _VILog._i('VideoView: setStreamId: textureId ${data['textureId']} '
          'is allocated for streamId $streamId');
      EventChannel rendererChannel =
          EventChannel('plugins.voximplant.com/renderer_${data['textureId']}');
      _rendererSubscription = rendererChannel
          .receiveBroadcastStream(
              'plugins.voximplant.com/renderer_${data['textureId']}')
          .listen(_onRendererEvent);
      if (_textureChanged != null) {
        _textureChanged(data['textureId']);
      }
      _streamId = streamId;
    } else {
      if (this._streamId == null) {
        return Future<void>.value();
      }
      await _channel.invokeMethod('removeVideoRenderer', <String, String>{
        'streamId': this._streamId,
      });
      if (_rendererSubscription != null) {
        _rendererSubscription.cancel();
        _rendererSubscription = null;
      }
      if (_textureChanged != null) {
        _textureChanged(null);
      }
      _streamId = null;
    }
  }

  void _onRendererEvent(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'resolutionChanged') {
      _VILog._i('VideoView: resolutionChanged: ${map['width']} x ${map['height']}, '
          'aspect ratio: ${map['aspectRatio']}, '
          'rotation: ${map['rotation']}, '
          'textureId: ${map['textureId']}');
      value = value._copyWith(map['width'], map['height'], map['aspectRatio'],
          VIVideoRotation.values[map['rotation']]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_rendererSubscription != null) {
      _rendererSubscription.cancel();
      _rendererSubscription = null;
    }
  }
}
