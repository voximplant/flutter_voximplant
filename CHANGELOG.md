# Changelog

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
