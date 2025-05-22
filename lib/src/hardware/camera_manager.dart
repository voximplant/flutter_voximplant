// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Represents supported camera types.
enum VICameraType { Back, Front }

/// Manages cameras.
class VICameraManager {
  final MethodChannel _channel;

  VICameraManager._(this._channel);

  /// Selects camera.
  ///
  /// `cameraType` - Back or front camera
  Future<void> selectCamera(VICameraType cameraType) async {
    await _channel.invokeMethod('Camera.selectCamera',
        <String, dynamic>{'cameraType': cameraType.index});
  }

  /// Selects camera resolution.
  ///
  /// Camera captures frames in a format that is as close as possible
  /// to [width] x [height].
  ///
  /// `width` - Camera resolution width
  ///
  /// `height` - Camera resolution height
  Future<void> setCameraResolution(int width, int height) async {
    await _channel.invokeMethod('Camera.setCameraResolution',
        <String, dynamic>{'width': width, 'height': height});
  }
}
