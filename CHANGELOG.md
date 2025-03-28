# Changelog

## 3.14.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.41.1 and Voximplant iOS SDK 2.54.0
* Introduce [VINode.Node11](/docs/references/fluttersdk/client/vinode#node11)
* Fix(android): update build.gradle and VoximplantPlugin for compatibility with the latest flutter versions

## 3.13.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.40.1 and Voximplant iOS SDK 2.53.0
* [VINode](/docs/references/fluttersdk/client/vinode) is a required parameter to establish the connection with the Voximplant Cloud. 
  Find more information about [VINode](/docs/references/fluttersdk/client/vinode) in the [getting started guide](/docs/getting-started/platform/flutter#connect-to-the-voximplant-cloud-and-log-in).
* Update example project
* Resolve dart static analyzer issues
* Update dependency constraints to
  * sdk: '>=2.18.0 <4.0.0'
  * flutter: '>=3.3.0'

## 3.12.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.39.0 and Voximplant iOS SDK 2.52.0
* Change minimum iOS deployment target to 12.0
* Introduce [VINode](/docs/references/fluttersdk/client/vinode) enum
* [VIClient.connect](/docs/references/fluttersdk/client/viclient#connect) API now takes an optional parameter to specify the node the Voximplant account belongs to

## 3.11.1
* Fix(android): End all calls on Flutter engine detach

## 3.11.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.38.2 and Voximplant iOS SDK 2.51.0
* Fix(android): [VILocalVideoDegradation](/docs/references/fluttersdk/call/vilocalvideodegradation) is not processed correctly in native code

## 3.10.1
* Fix(android): crash if the resolution of the video stream changes at the same moment when the renderer is removed

## 3.10.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.37.0 and Voximplant iOS SDK 2.50.0
* Introduce new API to handle video receive stop on a remote video stream and its reason (see 3.10.0-beta changelog)

## 3.10.0-beta.4
* Fix(ios): crash on receiving a message during a call

## 3.10.0-beta.3
* Fix(ios): crash on remove video renderer that does not exist anymore

## 3.10.0-beta.2
* Fix(ios): crash on rendering local video when an iPhone is rotated
* Remove e2e from dev_dependencies

## 3.10.0-beta
* This is a beta SDK version. Not recommended for production use.
* Update Android and iOS platform code to use Voximplant Android SDK 2.37.0-beta and Voximplant iOS SDK 2.50.0-beta
* The result of [VIEndpoint.startReceiving](/docs/references/fluttersdk/call/viendpoint#startreceiving) and [VIEndpoint.stopReceiving](/docs/references/fluttersdk/call/viendpoint#stopreceiving) API call is now provided via events:
  * [VIEndpoint.onStartReceivingVideoStream](/docs/references/fluttersdk/call/viendpoint#onstartreceivingvideostream)
  * [VIEndpoint.onStopReceivingVideoStream](/docs/references/fluttersdk/call/viendpoint#onstopreceivingvideostream)
* Introduce new API to handle video receive stop on a remote video stream:
  * [VIEndpoint.onStartReceivingVideoStream](/docs/references/fluttersdk/call/viendpoint#onstartreceivingvideostream)
  * [VIEndpoint.onStopReceivingVideoStream](/docs/references/fluttersdk/call/viendpoint#onstopreceivingvideostream)
* Introduce new API [VIVideoStreamReceiveStopReason](/docs/references/fluttersdk/call/vivideostreamreceivestopreason) to handle the reason for video receive stop on a remote video stream.

## 3.8.3
* Fix(ios): crash on receiving a message during a call

## 3.8.2
* Fix(ios): crash on remove video renderer that does not exist anymore

## 3.8.1
* Fix(ios): crash on rendering local video when an iPhone is rotated
* Remove e2e from dev_dependencies

## 3.8.0
* Update iOS platform code to use Voximplant iOS SDK 2.46.12

## 3.7.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.34.0 and Voximplant iOS SDK 2.46.11
* Fix(android): "java.lang.IllegalStateException: Reply already submitted" on [VIClient.getClientState()](/docs/references/fluttersdk/client/viclient#getclientstate) API call

## 3.6.0:
* Update Android and iOS platform code to use Voximplant Android SDK 2.33.1 and Voximplant iOS SDK 2.46.10
* Fix for [#43](https://github.com/voximplant/flutter_voximplant/issues/43)

## 3.5.1
* Hotfix for quality issues events:
  * Unhandled exception on processing VIQualityIssueLevel
  * Unhandled exception on processing VIFrameSize on iOS platform

## 3.5.0
* Introduce new APIs to monitor issues that affect call quality [#35](https://github.com/voximplant/flutter_voximplant/issues/35):
  * [VICall.qualityIssuesStream](/docs/references/fluttersdk/call/vicall#qualityissuesstream) - stream to handle quality issues.
  * [VICall.currentQualityIssues](/docs/references/fluttersdk/call/vicall#currentqualityissues) - get current status for all quality issues.

* Fix for [#37](https://github.com/voximplant/flutter_voximplant/issues/37)

## 3.4.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.32.4 and Voximplant iOS SDK 2.46.8

## 3.3.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.32.3 and Voximplant iOS SDK 2.46.7
* Introduce [VIClientConfig.forceRelayTraffic](/docs/references/fluttersdk/client/viclientconfig#forcerelaytraffic) API to force the media to go through TURN servers.

## 3.2.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.32.1 and Voximplant iOS SDK 2.46.4
* Introduce new APIs to restore the connection to the Voximplant Cloud if it was closed due to network issues during a call:
  * [VIClientState.Reconnecting](/docs/references/fluttersdk/client/viclientstate#reconnecting) - client state representing that the client is reconnecting to the Voximplant Cloud
  * [VICall.onCallReconnecting](/docs/references/fluttersdk/call/vicallreconnecting#vicallreconnecting) - notifies that the SDK is reconnecting to the Voximplant Cloud and 
    media streams may not be active
  * [VICall.onCallReconnected](/docs/references/fluttersdk/call/vicallreconnected#vicallreconnected) - notifies that the SDK is successfully reconnected to the Voximplant Cloud and
    media streams are restored
  * [VICallError.ERROR_RECONNECTING](/docs/references/fluttersdk/vicallerror#error_reconnecting) - call error that informs that a call operation cannot be completed 
    while a call is reconnecting
* Introduce simulcast feature support for video conference. Simulcast is currently disabled by default, 
  but can be enabled via [VICallSettings.enableSimulcast](/docs/references/fluttersdk/call/vicallsettings#enablesimulcast) parameter.
* Introduce new APIs to control remote video streams in a video conference call:
  * [VIEndpoint.startReceiving](/docs/references/fluttersdk/call/viendpoint#startreceiving) - Starts receiving video on the video stream.
  * [VIEndpoint.stopReceiving](/docs/references/fluttersdk/call/viendpoint#stopreceiving) - Stops receiving video on the video stream.
  * [VIEndpoint.requestVideoSize](/docs/references/fluttersdk/call/viendpoint#requestvideosize) - Requests the specified video size for the video stream.
    The stream resolution may be changed to the closest to the specified width and height.
* Introduced [VIEndpoint.onVoiceActivityStarted](/docs/references/fluttersdk/call/viendpoint#onvoiceactivitystarted) and [VIEndpoint.onVoiceActivityStopped](/docs/references/fluttersdk/call/viendpoint#onvoiceactivitystopped) API to handle voice activity of an endpoint in a conference call.

## 3.1.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.28.0
  and Voximplant iOS SDK 2.45.0
* Fix for [#24](https://github.com/voximplant/flutter_voximplant/issues/24)
* Introduce VILogListener

## 3.0.0
* Migrate to null safety
* Minimum Dart SDK version increased to 2.12.0
* Minimum Flutter SDK version increased to 1.20.0

API changes:
* Voximplant.getAudioDeviceManager() -> [Voximplant.audioDeviceManager](/docs/references/fluttersdk/voximplant#audioDeviceManager)
* Voximplant.getCameraManager() -> [Voximplant.cameraManager](/docs/references/fluttersdk/voximplant/#cameraManager)
* Voximplant.getMessenger() -> [Voximplant.messenger](/docs/references/fluttersdk/voximplant/#messenger)
* Added named `settings` argument to [VIClient.call()](/docs/references/fluttersdk/client/viclient#call), [VIClient.conference()](/docs/references/fluttersdk/client/viclient#conference) and [VICall.answer()](/docs/references/fluttersdk/call/vicall#answer)

Other changes:
* [VIConversation.title](/docs/references/fluttersdk/messaging/viconversation#title) field nullability changed to nullable
* [VIConversationConfig.title](/docs/references/fluttersdk/messaging/viconversationconfig#title) field nullability changed to nullable
* [VIAuthResult.loginTokens](/docs/references/fluttersdk/client/viauthresult#logintokens) field nullability changed to nullable
* Minor internal improvements

## 2.6.1
* Fix for [#20](https://github.com/voximplant/flutter_voximplant/issues/20)

## 2.6.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.21.3
  and Voximplant iOS SDK 2.36.2
* VIAudioFile._type private field changed to VIAudioFile.type public final field

## 2.5.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.21.0
  and Voximplant iOS SDK 2.35.0
* Fix [VICall.onCallAudioStarted](/docs/references/fluttersdk/call/vicall#oncallaudiostarted)
  callback execution on iOS

## 2.4.3
* Fix a bug leading to non-execution of VIAudioFile.stop() Future in some cases

## 2.4.2
* Fix a crash on stop non-looped VIAudioFile (iOS)

## 2.4.1
* Reformat code according to Dartfmt
* Fix VIAudioDeviceManager.getAudioDevice always throws issue

## 2.4.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.20.4
  and Voximplant iOS SDK 2.34.3
* Introduce VIAudioFile API

## 2.3.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.19.0 
  and Voximplant iOS SDK 2.33.0
* Introduce Messaging API
* Fix for [#14](https://github.com/voximplant/flutter_voximplant/issues/14)

## 2.2.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.17.0 
  and Voximplant iOS SDK 2.31.0
* Supporting the new Android plugins APIs based on FlutterPlugin
* VIClient.conference method added
* VIEndpoint.place value added
* VIEndpoint.onEndpointRemoved callback added

## 2.1.2
* Update iOS platform code to use Voximplant iOS SDK 2.30.0
* Xcode 11.4 support added
* VIVideoRenderer null handling improvements
* VIClient bundleId won't be set to native SDK if it is null

## 2.1.1
* VIVideoFlags incorrect initialisation fix

## 2.1.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.16.1
  and Voximplant iOS SDK 2.29.0
* Improve video rendering on iOS
* VICameraManager.selectCamera is now available for iOS
* Add VICall.getCallDuration API

## 2.0.0
* Update iOS platform code to use Voximplant iOS SDK 2.26.0
* Add 'VI' prefix to public API to avoid conflicts with other packages
* Add video call functionality
* Add camera management functionality
* Improve multiple call management
* Improve error descriptions for iOS
* Public API will no longer throw PlatformException. All exceptions are now wrapped 
  with VIException. Error codes for VIClient and VICall are described in VIClientError
  and VICallError classes.
* Fix build issues in example project
* Changed minimum Flutter SDK version to 1.10.0

## 1.2.0
* Update Android and iOS platform code to use Voximplant Android SDK 2.15.0
  and Voximplant iOS SDK 2.25.2
* Native code refactoring

## 1.1.0
* Add API for CallKit integration on iOS platform
* Update Android and iOS platform code to use Voximplant Android SDK 2.14.1
  and Voximplant iOS SDK 2.25.1

## 1.0.0
* Audio call functionality
