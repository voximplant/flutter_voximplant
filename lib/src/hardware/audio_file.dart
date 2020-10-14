/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Signature for callbacks reporting when the audio file playing is stopped.
///
/// `error` - A reason to stop. iOS ONLY.
/// For all possible errors see [VIAudioFileError]
///
/// Used in [VIAudioFile].
typedef void VIAudioFileStopped(String error);

/// Enum representing supported audio file usage modes
///
/// ANDROID ONLY.
enum VIAudioFileUsage {
  /// Should be used to play audio file during a call, for example to play progress tone.
  ///
  /// The volume is controlled by system call volume.
  inCall,

  /// Should be used to play audio file for notifications outside a call.
  ///
  /// The volume is controlled by system alarm volume
  notification,

  /// Should be used to play audio file for ringtone.
  ///
  /// The volume is controlled by system ring volume.
  ringtone,

  /// Should be used if other modes are not applicable.
  unknown
}

/// Class may be used to play audio files.
class VIAudioFile {

  /// HTTP URL of the stream to play
  final String url;

  /// Local audio file name
  final String name;

  /// Indicate if the audio file should be played repeatedly or once
  bool get looped => _looped;

  /// Invoked when the audio file playing is stopped.
  VIAudioFileStopped onStopped;

  static MethodChannel get _methodChannel => Voximplant._channel;
  StreamSubscription<dynamic> _eventSubscription;
  String _fileId;
  final String _type;
  final VIAudioFileUsage _usage;
  final _VIAudioFileDataSource _dataSource;
  bool _looped = false;

  /// Constructs a [VIAudioFile] to play an audio from a file.
  ///
  /// `name` - Local audio file name
  ///
  /// `type` - Local audio file type/format, for example ".mp3"
  ///
  /// `usage` - Audio file usage mode. ANDROID ONLY.
  ///
  /// On android, the audio file must be located in resources "raw" folder.
  VIAudioFile.file(this.name, this._type,
      {VIAudioFileUsage usage = VIAudioFileUsage.unknown})
      : _dataSource = _VIAudioFileDataSource.file,
        _usage = usage,
        url = null;

  /// Constructs a [VIAudioFile] to play an audio file obtained from the network.
  ///
  /// `url` - HTTP URL of the stream to play
  ///
  /// `usage` - Audio file usage mode. ANDROID ONLY.
  VIAudioFile.network(this.url,
      {VIAudioFileUsage usage = VIAudioFileUsage.unknown})
      : _dataSource = _VIAudioFileDataSource.network,
        _usage = usage,
        name = null,
        _type = null;

  /// Initialize and prepare the audio file to play
  ///
  /// Must be used before any other interactions with the object
  Future<void> initialize() async {
    try {
      if (_dataSource == _VIAudioFileDataSource.file) {
        _fileId = await _methodChannel.invokeMethod(
            'AudioFile.initWithFile', <String, dynamic>{
          'name': name,
          'type': _type,
          'usage': _audioFileUsageToString(_usage)
        });
      } else if (_dataSource == _VIAudioFileDataSource.network) {
        _fileId = await Voximplant._channel.invokeMethod(
            'AudioFile.loadFile', <String, dynamic>{
          'url': url,
          'usage': _audioFileUsageToString(_usage)
        });
      }
      this._eventSubscription =
          EventChannel('plugins.voximplant.com/audio_file_events_$_fileId')
              .receiveBroadcastStream()
              .listen((event) {
        if (event['name'] == 'didStopPlaying') {
          if (onStopped != null) {
            onStopped(event['error']);
          }
        }
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    } catch (e) {
      rethrow;
    }
  }

  /// Starts playing the audio file
  ///
  /// `looped` - Indicate if the audio file should be played repeatedly or once
  ///
  /// Throws [VIException], if an error occurred.
  /// For all possible errors see [VIAudioFileError]
  Future<void> play(bool looped) async {
    try {
      await _methodChannel.invokeMethod('AudioFile.play',
          <String, dynamic>{'fileId': _fileId, 'looped': looped});
      _looped = looped;
      return Future.value();
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    } catch (e) {
      rethrow;
    }
  }

  /// Stops playing of the audio file
  ///
  /// Throws [VIException], if an error occurred.
  /// For all possible errors see [VIAudioFileError]
  Future<void> stop() async {
    try {
      await _methodChannel
          .invokeMethod('AudioFile.stop', <String, dynamic>{'fileId': _fileId});
      return Future.value();
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    } catch (e) {
      rethrow;
    }
  }

  /// Releases all resources allocated for playing audio file.
  ///
  /// Must be called even if the file was not played.
  ///
  /// Throws [VIException], if an error occurred.
  Future<void> releaseResources() async {
    try {
      await _methodChannel.invokeMethod(
          'AudioFile.releaseResources', <String, dynamic>{'fileId': _fileId});
      _eventSubscription.cancel();
      return Future.value();
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    } catch (e) {
      rethrow;
    }
  }

  String _audioFileUsageToString(VIAudioFileUsage usage) {
    switch (usage) {
      case VIAudioFileUsage.inCall:
        return 'incall';
      case VIAudioFileUsage.notification:
        return 'notification';
      case VIAudioFileUsage.ringtone:
        return 'ringtone';
      case VIAudioFileUsage.unknown:
        return 'unknown';
      default:
        return 'unknown';
    }
  }
}

enum _VIAudioFileDataSource {
  file, network
}
