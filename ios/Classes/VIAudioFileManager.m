/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

#import "VIAudioFileManager.h"
#import "VIAudioFileModule.h"

@interface VIAudioFileManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, VIAudioFileModule *> *audioFileModules;
@property(nonatomic, weak) VoximplantPlugin *plugin;

@end


@implementation VIAudioFileManager

- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin {
    self = [super init];
    if (self) {
        _plugin = plugin;
        _audioFileModules = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (!call.arguments) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:[call.method stringByAppendingString:@": invalid arguments"]
                                   details:nil]);
        return;
    }
    
    if ([@"initWithFile" isEqualToString:call.method]) {
        NSString *fileName = call.arguments[@"name"];
        if (!fileName) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"VIAudioFile.initWithFile: name is null"
                                       details:nil]);
            return;
        }
        NSString *fileType = call.arguments[@"type"];
        if (!fileType) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"VIAudioFile.initWithFile: type is null"
                                       details:nil]);
            return;
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
        if (!filePath) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"VIAudioFile.initWithFile: failed to locate audio file"
                                       details:nil]);
            return;
        }
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        VIAudioFile *audioFile = [[VIAudioFile alloc] initWithURL:fileURL looped:NO];
        NSString *fileID = [NSUUID UUID].UUIDString;
        VIAudioFileModule *fileModule = [[VIAudioFileModule alloc] initWithPlugin:_plugin
                                                                        audioFile:audioFile
                                                                           fileID:fileID];
        _audioFileModules[fileID] = fileModule;
        result(fileID);
        
    } else if ([@"loadFile" isEqualToString:call.method]) {
        NSString *stringURL = call.arguments[@"url"];
        if (!stringURL) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"VIAudioFile.loadFile: url is null"
                                       details:nil]);
            return;
        }
        NSURL *URL = [NSURL URLWithString:stringURL];
        if (!URL) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"VIAudioFile.loadFile: could'nt build URL"
                                       details:nil]);
            return;
        }
        __weak VIAudioFileManager *weakSelf = self;
        NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:URL
                                                               completionHandler:^(NSData * _Nullable data,
                                                                                   NSURLResponse * _Nullable response,
                                                                                   NSError * _Nullable error) {
            if (error) {
                result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                           message:@"VIAudioFileModule.loadFile: failed to load audio file"
                                           details:nil]);
            } else {
                __strong VIAudioFileManager *strongSelf = weakSelf;
                VIAudioFile *audioFile = [[VIAudioFile alloc] initWithData:data looped:NO];
                NSString *fileID = [NSUUID UUID].UUIDString;
                VIAudioFileModule *fileModule = [[VIAudioFileModule alloc] initWithPlugin:strongSelf.plugin
                                                                                audioFile:audioFile
                                                                                   fileID:fileID];
                strongSelf.audioFileModules[fileID] = fileModule;
                result(fileID);
            }
        }];
        [task resume];
        
    } else if ([@"releaseResources" isEqualToString:call.method]) {
        NSString *fileID = call.arguments[@"fileId"];
        if (!fileID) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"VIAudioFile.releaseResources: fileId is null"
                                       details:nil]);
            return;
        }
        [_audioFileModules removeObjectForKey:fileID];
        result(nil);
        
    } else {
        NSString *fileID = [call.arguments objectForKey:@"fileId"];
        if (!fileID) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:[call.method stringByAppendingString:@": fileId is null"]
                                       details:nil]);
            return;
        }
        VIAudioFileModule *module = [_audioFileModules objectForKey:fileID];
        if (!module) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:[call.method stringByAppendingString:@": could'nt find audioFile"]
                                       details:nil]);
            return;
        }
        [module handleMethodCall:call result:result];
    }
}

@end
