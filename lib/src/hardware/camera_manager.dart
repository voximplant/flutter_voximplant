/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Represents supported camera types.
enum VICameraType {
  Back,
  Front
}

/// Manages cameras.
class VICameraManager {
  final MethodChannel _channel;

  VICameraManager._(this._channel);

  /// Selects camera.
  Future<void> selectCamera(VICameraType cameraType) async {
    await _channel.invokeMethod('selectCamera', <String, dynamic>{
      'cameraType': cameraType.index
    });
  }

  /// Selects camera resolution.
  ///
  /// Camera will capture frames in a format that is as close as posssible
  /// to [width] x [height].
  Future<void> setCameraResolution(int width, int height) async {
    await _channel.invokeMethod('setCameraResolution', <String, dynamic>{
      'width': width,
      'height': height
    });
  }
}
