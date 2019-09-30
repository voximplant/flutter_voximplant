/// Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.

part of voximplant;

typedef void EndpointUpdated(Endpoint endpoint);

class Endpoint {
  EndpointUpdated onEndpointUpdated;

  String _userName;
  String _displayName;
  String _sipUri;
  String _endpointId;

  String get userName => _userName;
  String get displayName => _displayName;
  String get sipUri => _sipUri;
  String get endpointId => _endpointId;



  Endpoint._(this._endpointId, this._userName, this._displayName, this._sipUri);

  _invokeEndpointUpdatedEvent(String username, String displayName, String sipUri) {
    this._displayName = displayName;
    this._userName = username;
    this._sipUri = sipUri;
    if (onEndpointUpdated != null) {
      onEndpointUpdated(this);
    }
  }

}
