// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Represents video stream types.
enum VIVideoStreamType {
  /// Indicates that a video stream source is camera or custom video source.
  VIDEO,

  /// Indicates that a video stream source is screen sharing.
  SCREEN_SHARING
}

/// Represents local or remote video stream within a call.
class VIVideoStream {
  final String _streamId;
  final VIVideoStreamType _streamType;

  /// Video stream ID.
  ///
  /// Used to connect a widget [VIVideoView] and this video stream to render
  /// local or remote video.
  String get streamId => _streamId;

  /// Video stream type.
  VIVideoStreamType get streamType => _streamType;

  VIVideoStream._(this._streamId, this._streamType);
}
