/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

#import "VIAudioFileModule.h"
#import "VIAudioFileManager.h"
#import "VoximplantUtils.h"

@interface VIAudioFileModule ()

@property(nonatomic, strong) FlutterEventChannel *eventChannel;
@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, strong) VIAudioFile *audioFile;
@property(nonatomic, strong) NSString *fileID;
@property(nonatomic) FlutterResult playCompletion;
@property(nonatomic) FlutterResult stopCompletion;

@end


@implementation VIAudioFileModule

- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin audioFile:(VIAudioFile *)file fileID:(NSString *)fileID {
    self = [super init];
    if (self) {
        _eventChannel
            = [FlutterEventChannel eventChannelWithName:[@"plugins.voximplant.com/audio_file_events_" stringByAppendingString:fileID]
                                        binaryMessenger:plugin.registrar.messenger];
        [_eventChannel setStreamHandler:self];
        _fileID = fileID;
        _audioFile = file;
        _audioFile.delegate = self;
    }
    return self;
}

- (void)dealloc {
    _audioFile.delegate = nil;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"play" isEqualToString:call.method]) {
        NSNumber *looped = call.arguments[@"looped"];
        if (!looped) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"VIAudioFileModule.play: looped is null"
                                       details:nil]);
            return;
        }
        _audioFile.looped = looped.boolValue;
        [_audioFile play];
        _playCompletion = result;
    } else if ([@"stop" isEqualToString:call.method]) {
        [_audioFile stop];
        _stopCompletion = result;
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - VIAudioFileDelegate -
- (void)audioFile:(VIAudioFile *)audioFile didStartPlaying:(NSError *)playbackError {
    if (_playCompletion) {
        if (playbackError) {
            _playCompletion([FlutterError errorWithCode:[VoximplantUtils convertAudioFileErrorToString:playbackError.code]
                                                message:playbackError.localizedDescription
                                                details:nil]);
        } else {
            _playCompletion(nil);
        }
        _playCompletion = nil;
    }
}

- (void)audioFile:(VIAudioFile *)audioFile didStopPlaying:(NSError *)playbackError {
    if (_stopCompletion) {
        if (playbackError) {
            _stopCompletion([FlutterError errorWithCode:[VoximplantUtils convertAudioFileErrorToString:playbackError.code]
                                                message:playbackError.localizedDescription
                                                details:nil]);
        } else {
            _stopCompletion(nil);
        }
        _stopCompletion = nil;
    } else if (_eventSink) {
        NSString *error;
        if (playbackError) {
            error = [VoximplantUtils convertAudioFileErrorToString:playbackError.code];
        }
        self.eventSink(@{
            @"name": @"didStopPlaying",
            @"error": error ?: [NSNull null]
        });
    }
}

#pragma mark - FlutterStreamHandler -
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

@end
