/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import "VIMessagingModule.h"
#import "VoximplantUtils.h"

@interface VIMessagingModule()

@property(nonatomic, strong) FlutterEventChannel *eventChannel;
@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;

@end

@implementation VIMessagingModule

- (void)setMessenger:(VIMessenger *)messenger {
    _messenger = messenger;
    [self.messenger addDelegate:self];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        self.registrar = registrar;
        self.eventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.voximplant.com/messaging"
                                                      binaryMessenger:registrar.messenger];
        [self.eventChannel setStreamHandler:self];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getUserByName" isEqualToString:call.method]) {
        NSString *name = [call.arguments objectForKey:@"name"];
        if ([name isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.getUserByName: Name parameter can not be null"
                                       details:nil]);
            return;
        }
        [self.messenger getUserByName:name
                           completion:[VIMessengerCompletion success:^(VIUserEvent *event) {
            result([self makeDictionaryFromUserEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"getUserByIMId" isEqualToString:call.method]) {
        NSNumber *userId = [call.arguments objectForKey:@"id"];
        if ([userId isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.getUserByIMId: id parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger getUserByIMId:userId
                           completion:[VIMessengerCompletion success:^(VIUserEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromUserEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"getUsersByName" isEqualToString:call.method]) {
        NSArray *usernames = [call.arguments objectForKey:@"users"];
        if ([usernames isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.getUsersByName: users parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger getUsersByName:usernames
                           completion:[VIMessengerCompletion success:^(NSArray<VIUserEvent *> *events) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            NSMutableArray<NSDictionary *>* userEvents = [NSMutableArray new];
            for (VIUserEvent *userEvent in events) {
                [userEvents addObject:[strongSelf makeDictionaryFromUserEvent:userEvent]];
            }
            result(userEvents);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"getUsersByIMId" isEqualToString:call.method]) {
        NSArray *ids = [call.arguments objectForKey:@"users"];
        if ([ids isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.getUsersByIMId: users parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger getUsersByIMId:ids
                            completion:[VIMessengerCompletion success:^(NSArray<VIUserEvent *> *events) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            NSMutableArray<NSDictionary *>* userEvents = [NSMutableArray new];
            for (VIUserEvent *userEvent in events) {
                [userEvents addObject:[strongSelf makeDictionaryFromUserEvent:userEvent]];
            }
            result(userEvents);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"editUser" isEqualToString:call.method]) {
        NSDictionary *customData = [call.arguments objectForKey:@"customData"];
        NSDictionary *privateCustomData = [call.arguments objectForKey:@"privateCustomData"];
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger editUserWithCustomData:customData
                             privateCustomData:privateCustomData
                                    completion:[VIMessengerCompletion success:^(VIUserEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromUserEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];

    } else if ([@"managePushNotifications" isEqualToString:call.method]) {
        NSArray <NSNumber *>*notificationsNumbers = [call.arguments objectForKey:@"notifications"];
        NSMutableArray<VIMessengerNotification> *notifications = [NSMutableArray new];
        if (![notificationsNumbers isEqual:[NSNull null]]) {
            for (NSNumber *number in notificationsNumbers) {
                [notifications addObject:[self makeNotificationFromNumber:number]];
            }
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger managePushNotifications:notifications
                                    completion:[VIMessengerCompletion success:^(VIUserEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromUserEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"setStatus" isEqualToString:call.method]) {
        NSNumber *isOnline = [call.arguments objectForKey:@"online"];
        if ([isOnline isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.setStatus: online parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger setStatus:isOnline.boolValue
                       completion:[VIMessengerCompletion success:^(VIStatusEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromStatusEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"subscribe" isEqualToString:call.method]) {
        NSArray<NSNumber *> *users = [call.arguments objectForKey: @"users"];
        if ([users isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.subscribe: users parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger subscribe:users
                       completion:[VIMessengerCompletion success:^(VISubscriptionEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromSubscriptionEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"unsubscribe" isEqualToString:call.method]) {
        NSArray<NSNumber *> *users = [call.arguments objectForKey: @"users"];
        if ([users isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.unsubscribe: users parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger unsubscribe:users
                         completion:[VIMessengerCompletion success:^(VISubscriptionEvent *event) {
                        __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromSubscriptionEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"unsubscribeFromAll" isEqualToString:call.method]) {
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger unsubscribeFromAll:[VIMessengerCompletion success:^(VISubscriptionEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromSubscriptionEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"getSubscriptions" isEqualToString:call.method]) {
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger getSubscriptionList:[VIMessengerCompletion success:^(VISubscriptionEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromSubscriptionEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
    
    } else if ([@"createConversation" isEqualToString:call.method]) {
        NSDictionary *configDictionary = [call.arguments objectForKey:@"config"];
        if ([configDictionary isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.createConversation: config parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger createConversation:[self makeConversationConfigFromDictionary:configDictionary]
                                completion:[VIMessengerCompletion success:^(VIConversationEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromConversationEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"getConversation" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"uuid"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.getConversation: uuid parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger getConversation:uuid
                             completion:[VIMessengerCompletion success:^(VIConversationEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromConversationEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"getConversations" isEqualToString:call.method]) {
        NSArray <NSString *> *uuids = [call.arguments objectForKey:@"uuids"];
        if ([uuids isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.getConversations: uuids parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger getConversations:uuids
                              completion:[VIMessengerCompletion success:^(NSArray<VIConversationEvent *> *events) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            NSMutableArray<NSDictionary *>* conversationEvents = [NSMutableArray new];
            for (VIConversationEvent *conversationEvent in events) {
                [conversationEvents addObject:[strongSelf makeDictionaryFromConversationEvent:conversationEvent]];
            }
            result(conversationEvents);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"getPublicConversations" isEqualToString:call.method]) {
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger getPublicConversations:[VIMessengerCompletion success:^(VIConversationListEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromConversationListEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"joinConversation" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"uuid"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.joinConversation: uuid parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger joinConversation:uuid
                              completion:[VIMessengerCompletion success:^(VIConversationEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromConversationEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"leaveConversation" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"uuid"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.leaveConversation: uuid parameter can not be null"
                                       details:nil]);
            return;
        }
        __weak VIMessagingModule *weakSelf = self;
        [self.messenger leaveConversation:uuid
                               completion:[VIMessengerCompletion success:^(VIConversationEvent *event) {
            __strong VIMessagingModule *strongSelf = weakSelf;
            result([strongSelf makeDictionaryFromConversationEvent:event]);
        } failure:^(VIErrorEvent *event) {
            result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                       message:event.errorDescription
                                       details:nil]);
        }]];
        
    } else if ([@"addParticipants" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.addParticipants: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSMutableArray<VIConversationParticipant *> *participants = [NSMutableArray new];
        NSArray<NSDictionary *> *participantsList = [call.arguments objectForKey:@"participants"];
        if (![participantsList isEqual:[NSNull null]]) {
            for (NSDictionary *participant in participantsList) {
                [participants addObject:[self makeParticipantFromDictionary:participant]];
            }
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation addParticipants:participants
                               completion:[VIMessengerCompletion success:^(VIConversationEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromConversationEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.addParticipants: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"editParticipants" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.editParticipants: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSMutableArray<VIConversationParticipant *> *participants = [NSMutableArray new];
        NSArray<NSDictionary *> *participantsList = [call.arguments objectForKey:@"participants"];
        if (![participantsList isEqual:[NSNull null]]) {
            for (NSDictionary *participant in participantsList) {
                [participants addObject:[self makeParticipantFromDictionary:participant]];
            }
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation editParticipants:participants
                                completion:[VIMessengerCompletion success:^(VIConversationEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromConversationEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.editParticipants: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"removeParticipants" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.removeParticipants: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSMutableArray<VIConversationParticipant *> *participants = [NSMutableArray new];
        NSArray<NSDictionary *> *participantsList = [call.arguments objectForKey:@"participants"];
        if (![participantsList isEqual:[NSNull null]]) {
            for (NSDictionary *participant in participantsList) {
                [participants addObject:[self makeParticipantFromDictionary:participant]];
            }
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation removeParticipants:participants
                                  completion:[VIMessengerCompletion success:^(VIConversationEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromConversationEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.removeParticipants: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"updateConversation" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.updateConversation: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        VIConversationConfig *conversationConfig = [VIConversationConfig new];
        NSString *title = [call.arguments objectForKey:@"title"];
        [conversationConfig setTitle:[title isEqual:[NSNull null]] ? nil : title];
        NSDictionary *customData = [call.arguments objectForKey:@"customData"];
        [conversationConfig setCustomData:[customData isEqual:[NSNull null]] ? nil : customData];
        NSNumber *publicJoin = [call.arguments objectForKey:@"publicJoin"];
        if (![publicJoin isEqual:[NSNull null]]) {
            [conversationConfig setPublicJoin: publicJoin.boolValue];
        }
        VIConversation *conversation = [self.messenger recreateConversation:conversationConfig
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation update:[VIMessengerCompletion success:^(VIConversationEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromConversationEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.updateConversation: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"markAsRead" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.markAsRead: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSNumber *sequence = [call.arguments objectForKey:@"sequence"];
        if ([sequence isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.markAsRead: sequence parameter can not be null"
                                       details:nil]);
            return;
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation markAsRead:sequence.longLongValue
                          completion:[VIMessengerCompletion success:^(VIConversationServiceEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromConversationServiceEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.markAsRead: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"typing" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.typing: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation typing:[VIMessengerCompletion success:^(VIConversationServiceEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromConversationServiceEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.typing: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"sendMessage" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.sendMessage: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        NSString *text = [call.arguments objectForKey:@"text"];
        if ([text isEqual:[NSNull null]]) {
            text = nil;
        }
        NSArray<NSDictionary *> *payload = [call.arguments objectForKey:@"payload"];
        if ([payload isEqual:[NSNull null]]) {
            payload = nil;
        }
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation sendMessage:text
                              payload:payload
                           completion:[VIMessengerCompletion success:^(VIMessageEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromMessageEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.sendMessage: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"retransmitEvents" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEvents: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSNumber *from = [call.arguments objectForKey:@"from"];
        if ([from isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEvents: from parameter can not be null"
                                       details:nil]);
            return;
        }
        NSNumber *to = [call.arguments objectForKey:@"to"];
        if ([to isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEvents: to parameter can not be null"
                                       details:nil]);
            return;
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation retransmitEventsFrom:from.longLongValue
                                            to:to.longLongValue
                                    completion:[VIMessengerCompletion success:^(VIRetransmitEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromRetransmitEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEvents: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"retransmitEventsFrom" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsFrom: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSNumber *from = [call.arguments objectForKey:@"from"];
        if ([from isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsFrom: from parameter can not be null"
                                       details:nil]);
            return;
        }
        NSNumber *count = [call.arguments objectForKey:@"count"];
        if ([count isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsFrom: count parameter can not be null"
                                       details:nil]);
            return;
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation retransmitEventsFrom:from.longLongValue
                                         count:count.unsignedIntegerValue
                                    completion:[VIMessengerCompletion success:^(VIRetransmitEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromRetransmitEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsFrom: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"retransmitEventsTo" isEqualToString:call.method]) {
        NSString *uuid = [call.arguments objectForKey:@"conversation"];
        if ([uuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsTo: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSNumber *to = [call.arguments objectForKey:@"to"];
        if ([to isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsTo: to parameter can not be null"
                                       details:nil]);
            return;
        }
        NSNumber *count = [call.arguments objectForKey:@"count"];
        if ([count isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsTo: count parameter can not be null"
                                       details:nil]);
            return;
        }
        VIConversation *conversation = [self.messenger recreateConversation:[VIConversationConfig new]
                                                                       uuid:uuid
                                                               lastSequence:0
                                                             lastUpdateTime:0
                                                                createdTime:0];
        if (conversation) {
            __weak VIMessagingModule *weakSelf = self;
            [conversation retransmitEventsTo:to.longLongValue
                                       count:count.unsignedIntegerValue
                                  completion:[VIMessengerCompletion success:^(VIRetransmitEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromRetransmitEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.retransmitEventsTo: conversation with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"updateMessage" isEqualToString:call.method]) {
        NSString *conversation = [call.arguments objectForKey:@"conversation"];
        if ([conversation isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.updateMessage: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSString *messageUuid = [call.arguments objectForKey:@"message"];
        if ([messageUuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.updateMessage: messageUuid parameter can not be null"
                                       details:nil]);
            return;
        }
        NSString *text = [call.arguments objectForKey:@"text"];
        if ([text isEqual:[NSNull null]]) {
            text = nil;
        }
        NSArray<NSDictionary *> *payload = [call.arguments objectForKey:@"payload"];
        if ([payload isEqual:[NSNull null]]) {
            payload = nil;
        }
        VIMessage *message = [self.messenger recreateMessage:messageUuid
                                                conversation:conversation
                                                        text:text
                                                     payload:payload
                                                    sequence:0];
        if (message) {
            __weak VIMessagingModule *weakSelf = self;
            [message update:text
                    payload:payload
                 completion:[VIMessengerCompletion success:^(VIMessageEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromMessageEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.updateMessage: message with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else if ([@"removeMessage" isEqualToString:call.method]) {
        NSString *conversation = [call.arguments objectForKey:@"conversation"];
        if ([conversation isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.removeMessage: conversation parameter can not be null"
                                       details:nil]);
            return;
        }
        NSString *messageUuid = [call.arguments objectForKey:@"message"];
        if ([messageUuid isEqual:[NSNull null]]) {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.removeMessage: messageUuid parameter can not be null"
                                       details:nil]);
            return;
        }
        VIMessage *message = [self.messenger recreateMessage:messageUuid
                                                conversation:conversation text:nil
                                                     payload:nil
                                                    sequence:0];
        if (message) {
            __weak VIMessagingModule *weakSelf = self;
            [message remove:[VIMessengerCompletion success:^(VIMessageEvent *event) {
                __strong VIMessagingModule *strongSelf = weakSelf;
                result([strongSelf makeDictionaryFromMessageEvent:event]);
            } failure:^(VIErrorEvent *event) {
                result([FlutterError errorWithCode:[VoximplantUtils convertMessagingErrorToString:event]
                                           message:event.errorDescription
                                           details:nil]);
            }]];
        } else {
            result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                       message:@"Messenger.removeMessage: message with the given uuid couldn't be found"
                                       details:nil]);
        }
        
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - VIMessengerDelegate -
- (void)messenger:(VIMessenger *)messenger didEditUser:(VIUserEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onEditUser" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromUserEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didSubscribe:(VISubscriptionEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onSubscribe" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromSubscriptionEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didUnsubscribe:(VISubscriptionEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onUnsubscribe" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromSubscriptionEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didCreateConversation:(VIConversationEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onCreateConversation" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromConversationEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didRemoveConversation:(VIConversationEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onRemoveConversation" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromConversationEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didEditConversation:(VIConversationEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onEditConversation" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromConversationEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didSetStatus:(VIStatusEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onSetStatus" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromStatusEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didEditMessage:(VIMessageEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onEditMessage" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromMessageEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didSendMessage:(VIMessageEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onSendMessage" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromMessageEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didRemoveMessage:(VIMessageEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onRemoveMessage" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromMessageEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didReceiveTypingNotification:(VIConversationServiceEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"onTyping" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromConversationServiceEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

- (void)messenger:(VIMessenger *)messenger didReceiveReadConfirmation:(VIConversationServiceEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"isRead" forKey:@"name"];
    [dictionary setObject:[self makeDictionaryFromConversationServiceEvent:event] forKey:@"event"];
    [self sendEvent:dictionary];
}

#pragma mark - FlutterStreamHandler
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments
                                        eventSink:(nonnull FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

#pragma mark - Private
- (void)sendEvent:(NSDictionary *)event {
    if (self.eventSink) {
        self.eventSink(event);
    }
}

- (VIConversationConfig *)makeConversationConfigFromDictionary:(NSDictionary *)dictionary {
    VIConversationConfig *config = [VIConversationConfig new];
    NSNumber *direct = [dictionary valueForKey:@"direct"];
    if (![direct isEqual:[NSNull null]]) {
        config.direct = direct.boolValue;
    }
    NSNumber *publicJoin = [dictionary valueForKey:@"publicJoin"];
    if (![publicJoin isEqual:[NSNull null]]) {
        config.publicJoin = publicJoin.boolValue;
    }
    NSNumber *uber = [dictionary valueForKey:@"uber"];
    if (![uber isEqual:[NSNull null]]) {
        config.uber = uber.boolValue;
    }
    NSString *title = [dictionary valueForKey:@"title"];
    if (![title isEqual:[NSNull null]]) {
        config.title = title;
    }
    NSDictionary *customData = [dictionary valueForKey:@"customData"];
    if (![customData isEqual:[NSNull null]]) {
        config.customData = customData;
    }
    NSArray<NSDictionary *> *participantsDictionaries = [dictionary valueForKey:@"participants"];
    if (![participantsDictionaries isEqual:[NSNull null]]) {
        NSMutableArray <VIConversationParticipant *> *participants = [NSMutableArray new];
        for (NSDictionary *dictionary in participantsDictionaries) {
            [participants addObject: [self makeParticipantFromDictionary:dictionary]];
        }
        config.participants = participants;
    }
    return config;
}

- (VIConversationParticipant *)makeParticipantFromDictionary:(NSDictionary *)dictionary {
    NSNumber *imId = [dictionary valueForKey:@"id"];
    if ([imId isEqual:[NSNull null]]) {
        return nil;
    }
    VIConversationParticipant *participant = [VIConversationParticipant forIMUserId:imId];
    NSNumber *owner = [dictionary valueForKey:@"owner"];
    if (![owner isEqual:[NSNull null]]) {
        participant.owner = owner.boolValue;
    }
    NSNumber *canWrite = [dictionary valueForKey:@"canWrite"];
    if (![canWrite isEqual:[NSNull null]]) {
        participant.canWrite = canWrite.boolValue;
    }
    NSNumber *canEditMessages = [dictionary valueForKey:@"canEditMessages"];
    if (![canEditMessages isEqual:[NSNull null]]) {
        participant.canEditMessages = canEditMessages.boolValue;
    }
    NSNumber *canEditAllMessages = [dictionary valueForKey:@"canEditAllMessages"];
    if (![canEditAllMessages isEqual:[NSNull null]]) {
        participant.canEditAllMessages = canEditAllMessages.boolValue;
    }
    NSNumber *canRemoveMessages = [dictionary valueForKey:@"canRemoveMessages"];
    if (![canRemoveMessages isEqual:[NSNull null]]) {
        participant.canRemoveMessages = canRemoveMessages.boolValue;
    }
    NSNumber *canRemoveAllMessages = [dictionary valueForKey:@"canRemoveAllMessages"];
    if (![canRemoveAllMessages isEqual:[NSNull null]]) {
        participant.canRemoveAllMessages = canRemoveAllMessages.boolValue;
    }
    NSNumber *canManageParticipants = [dictionary valueForKey:@"canManageParticipants"];
    if (![canManageParticipants isEqual:[NSNull null]]) {
        participant.canManageParticipants = canManageParticipants.boolValue;
    }
    return participant;
}

- (NSDictionary *)makeDictionaryFromRetransmitEvent:(VIRetransmitEvent *)retransmitEvent {
    NSMutableDictionary *dictionary = [self makeMutableDictionaryFromEvent:retransmitEvent];
    NSMutableArray<NSDictionary *> *events = [NSMutableArray new];
    if (retransmitEvent.events) {
        for (VIMessengerEvent *event in retransmitEvent.events) {
            [events addObject:[self makeDictionaryFromMessengerEvent:event]];
        }
    }
    [dictionary setObject:events forKey:@"events"];
    [dictionary setObject:@(retransmitEvent.fromSequence) forKey:@"fromSequence"];
    [dictionary setObject:@(retransmitEvent.toSequence) forKey:@"toSequence"];
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromMessengerEvent:(VIMessengerEvent *)messengerEvent {
    if ([messengerEvent isKindOfClass:[VIMessageEvent class]]) {
        return [self makeDictionaryFromMessageEvent:(VIMessageEvent *)messengerEvent];
    } else if ([messengerEvent isKindOfClass:[VIConversationEvent class]]) {
        return [self makeDictionaryFromConversationEvent:(VIConversationEvent *)messengerEvent];
    } else {
        return nil;
    }
}

- (NSDictionary *)makeDictionaryFromMessageEvent:(VIMessageEvent *)messageEvent {
    NSMutableDictionary *dictionary = [self makeMutableDictionaryFromEvent:messageEvent];
    [dictionary setObject:[self makeDictionaryFromMessage:messageEvent.message] forKey:@"message"];
    [dictionary setObject:@(messageEvent.sequence) forKey:@"sequence"];
    [dictionary setObject:[NSNumber fromTimeInterval:messageEvent.timestamp] forKey:@"timestamp"];
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromMessage:(VIMessage *)message {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:message.uuid forKey:@"uuid"];
    [dictionary setObject:message.conversation forKey:@"conversation"];
    [dictionary setObject:@(message.sequence) forKey:@"sequence"];
    if (message.text) {
        [dictionary setObject:message.text forKey:@"text"];
    }
    if (message.payload) {
        [dictionary setObject:message.payload forKey:@"payload"];
    }
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromConversationServiceEvent:(VIConversationServiceEvent *)conversationServiceEvent {
    NSMutableDictionary *dictionary = [self makeMutableDictionaryFromEvent:conversationServiceEvent];
    [dictionary setObject:conversationServiceEvent.conversationUUID forKey:@"conversationUuid"];
    [dictionary setObject:@(conversationServiceEvent.sequence) forKey:@"sequence"];
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromConversationListEvent:(VIConversationListEvent *)conversationListEvent {
    NSMutableDictionary *dictionary = [self makeMutableDictionaryFromEvent:conversationListEvent];
    [dictionary setObject:conversationListEvent.conversationList forKey:@"conversationList"];
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromConversationEvent:(VIConversationEvent *)conversationEvent {
    NSMutableDictionary *dictionary = [self makeMutableDictionaryFromEvent:conversationEvent];
    [dictionary setObject:@(conversationEvent.sequence) forKey:@"sequence"];
    [dictionary setObject:[NSNumber fromTimeInterval:conversationEvent.timestamp] forKey:@"timestamp"];
    [dictionary setObject:[self makeDictionaryFromConversation:conversationEvent.conversation] forKey:@"conversation"];
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromConversation:(VIConversation *)conversation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:conversation.uuid forKey:@"uuid"];
    [dictionary setObject:conversation.title forKey:@"title"];
    [dictionary setObject:@(conversation.direct) forKey:@"direct"];
    [dictionary setObject:@(conversation.uber) forKey:@"uber"];
    [dictionary setObject:@(conversation.publicJoin) forKey:@"publicJoin"];
    NSMutableArray <NSDictionary *> *participants = [NSMutableArray new];
    for (VIConversationParticipant *participant in conversation.participants) {
        [participants addObject:[self makeDictionaryFromParticipant:participant]];
    }
    [dictionary setObject:participants forKey:@"participants"];
    [dictionary setObject:@(conversation.lastSequence) forKey:@"lastSequence"];
    [dictionary setObject:conversation.customData forKey:@"customData"];
    [dictionary setObject:[NSNumber fromTimeInterval:conversation.createdTime] forKey:@"createdTime"];
    [dictionary setObject:[NSNumber fromTimeInterval:conversation.lastUpdateTime] forKey:@"lastUpdateTime"];
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromParticipant:(VIConversationParticipant *)participant {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:participant.imUserId forKey:@"id"];
    [dictionary setObject:@(participant.lastReadEventSequence) forKey:@"lastReadSequence"];
    [dictionary setObject:@(participant.isOwner) forKey:@"isOwner"];
    [dictionary setObject:@(participant.canWrite) forKey:@"canWrite"];
    [dictionary setObject:@(participant.canEditMessages) forKey:@"canEditMessages"];
    [dictionary setObject:@(participant.canEditAllMessages) forKey:@"canEditAllMessages"];
    [dictionary setObject:@(participant.canRemoveMessages) forKey:@"canRemoveMessages"];
    [dictionary setObject:@(participant.canRemoveAllMessages) forKey:@"canRemoveAllMessages"];
    [dictionary setObject:@(participant.canManageParticipants) forKey:@"canManageParticipants"];
    return dictionary;
}

- (NSDictionary *)makeDictionaryFromSubscriptionEvent:(VISubscriptionEvent *)subscriptionEvent {
    NSMutableDictionary *event = [self makeMutableDictionaryFromEvent:subscriptionEvent];
    [event setObject:subscriptionEvent.users forKey:@"users"];
    return event;
}

- (NSDictionary *)makeDictionaryFromStatusEvent:(VIStatusEvent *)statusEvent {
    NSMutableDictionary *event = [self makeMutableDictionaryFromEvent:statusEvent];
    [event setObject:[NSNumber numberWithBool:statusEvent.online] forKey:@"isOnline"];
    return event;
}

- (NSDictionary *)makeDictionaryFromUserEvent:(VIUserEvent *)userEvent {
    NSMutableDictionary *user = [NSMutableDictionary new];
    [user setObject:userEvent.user.imId forKey:@"id"];
    [user setObject:userEvent.user.displayName forKey:@"displayName"];
    [user setObject:userEvent.user.name forKey:@"name"];
    [user setObject:[NSNumber numberWithBool:userEvent.user.isDeleted] forKey:@"isDeleted"];
    if (userEvent.user.conversationList) {
        [user setObject:userEvent.user.conversationList forKey:@"conversationList"];
    }
    if (userEvent.user.leaveConversationList) {
        [user setObject:userEvent.user.leaveConversationList forKey:@"leaveConversationList"];
    }
    if (userEvent.user.notifications) {
        NSMutableArray<NSNumber *> *notifications = [NSMutableArray new];
        for (VIMessengerNotification notification in userEvent.user.notifications) {
            [notifications addObject:[self makeNumberFromNotification:notification]];
        }
        [user setObject:notifications forKey:@"notifications"];
    }
    if (userEvent.user.privateCustomData) {
        [user setObject:userEvent.user.privateCustomData forKey:@"privateCustomData"];
    }
    if (userEvent.user.customData) {
        [user setObject:userEvent.user.customData forKey:@"customData"];
    }
    NSMutableDictionary *event = [self makeMutableDictionaryFromEvent:userEvent];
    [event setObject:user forKey:@"user"];
    return event;
}

- (NSMutableDictionary *)makeMutableDictionaryFromEvent:(VIMessengerEvent *)event {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:event.imUserId forKey:@"id"];
    [dictionary setObject:[self makeNumberFromMessengerAction:event.action] forKey:@"action"];
    [dictionary setObject:[self makeNumberFromMessengerEventType:event.eventType] forKey:@"type"];
    return dictionary;
}

- (NSNumber *)makeNumberFromNotification:(VIMessengerNotification)notification {
    if ([notification isEqualToString:VIMessengerNotificationSendMessage]) {
        return [NSNumber numberWithInt:1];
    }
    return [NSNumber numberWithInt:0];
}

- (VIMessengerNotification)makeNotificationFromNumber:(NSNumber *)number {
    if ([number isEqualToNumber:[NSNumber numberWithInt:1]]) {
        return VIMessengerEventTypeSendMessage;
    }
    return VIMessengerNotificationEditMessage;
}

- (NSNumber *)makeNumberFromMessengerEventType:(VIMessengerEventType)type {
    if ([type isEqualToString:VIMessengerEventTypeIsRead]) {
        return [NSNumber numberWithInt:1];
    }
    if ([type isEqualToString:VIMessengerEventTypeCreateConversation]) {
        return [NSNumber numberWithInt:2];
    }
    if ([type isEqualToString:VIMessengerEventTypeEditConversation]) {
        return [NSNumber numberWithInt:3];
    }
    if ([type isEqualToString:VIMessengerEventTypeEditMessage]) {
        return [NSNumber numberWithInt:4];
    }
    if ([type isEqualToString:VIMessengerEventTypeEditUser]) {
        return [NSNumber numberWithInt:5];
    }
    if ([type isEqualToString:VIMessengerEventTypeGetConversation]) {
        return [NSNumber numberWithInt:6];
    }
    if ([type isEqualToString:VIMessengerEventTypeGetPublicConversations]) {
        return [NSNumber numberWithInt:7];
    }
    if ([type isEqualToString:VIMessengerEventTypeGetSubscriptionList]) {
        return [NSNumber numberWithInt:8];
    }
    if ([type isEqualToString:VIMessengerEventTypeGetUser]) {
        return [NSNumber numberWithInt:9];
    }
    if ([type isEqualToString:VIMessengerEventTypeRemoveConversation]) {
        return [NSNumber numberWithInt:10];
    }
    if ([type isEqualToString:VIMessengerEventTypeRemoveMessage]) {
        return [NSNumber numberWithInt:11];
    }
    if ([type isEqualToString:VIMessengerEventTypeRetransmitEvents]) {
        return [NSNumber numberWithInt:12];
    }
    if ([type isEqualToString:VIMessengerEventTypeSendMessage]) {
        return [NSNumber numberWithInt:13];
    }
    if ([type isEqualToString:VIMessengerEventTypeSetStatus]) {
        return [NSNumber numberWithInt:14];
    }
    if ([type isEqualToString:VIMessengerEventTypeSubscribe]) {
        return [NSNumber numberWithInt:15];
    }
    if ([type isEqualToString:VIMessengerEventTypeTyping]) {
        return [NSNumber numberWithInt:16];
    }
    if ([type isEqualToString:VIMessengerEventTypeUnsubscribe]) {
        return [NSNumber numberWithInt:17];
    }
    return [NSNumber numberWithInt:0];
}

- (NSNumber *)makeNumberFromMessengerAction:(VIMessengerAction)action {
    if ([action isEqualToString:VIMessengerActionAddParticipants]) {
        return [NSNumber numberWithInt:1];
    }
    if ([action isEqualToString:VIMessengerActionCreateConversation]) {
        return [NSNumber numberWithInt:2];
    }
    if ([action isEqualToString:VIMessengerActionEditConversation]) {
        return [NSNumber numberWithInt:3];
    }
    if ([action isEqualToString:VIMessengerActionEditMessage]) {
        return [NSNumber numberWithInt:4];
    }
    if ([action isEqualToString:VIMessengerActionEditParticipants]) {
        return [NSNumber numberWithInt:5];
    }
    if ([action isEqualToString:VIMessengerActionEditUser]) {
        return [NSNumber numberWithInt:6];
    }
    if ([action isEqualToString:VIMessengerActionGetConversation]) {
        return [NSNumber numberWithInt:7];
    }
    if ([action isEqualToString:VIMessengerActionGetConversations]) {
        return [NSNumber numberWithInt:8];
    }
    if ([action isEqualToString:VIMessengerActionGetSubscriptionList]) {
        return [NSNumber numberWithInt:9];
    }
    if ([action isEqualToString:VIMessengerActionGetPublicConversations]) {
        return [NSNumber numberWithInt:10];
    }
    if ([action isEqualToString:VIMessengerActionGetUser]) {
        return [NSNumber numberWithInt:11];
    }
    if ([action isEqualToString:VIMessengerActionGetUsers]) {
        return [NSNumber numberWithInt:12];
    }
    if ([action isEqualToString:VIMessengerActionIsRead]) {
        return [NSNumber numberWithInt:13];
    }
    if ([action isEqualToString:VIMessengerActionJoinConversation]) {
        return [NSNumber numberWithInt:14];
    }
    if ([action isEqualToString:VIMessengerActionLeaveConversation]) {
        return [NSNumber numberWithInt:15];
    }
    if ([action isEqualToString:VIMessengerActionManageNotifications]) {
        return [NSNumber numberWithInt:16];
    }
    if ([action isEqualToString:VIMessengerActionRemoveConversation]) {
        return [NSNumber numberWithInt:17];
    }
    if ([action isEqualToString:VIMessengerActionRemoveMessage]) {
        return [NSNumber numberWithInt:18];
    }
    if ([action isEqualToString:VIMessengerActionRemoveParticipants]) {
        return [NSNumber numberWithInt:19];
    }
    if ([action isEqualToString:VIMessengerActionRetransmitEvents]) {
        return [NSNumber numberWithInt:20];
    }
    if ([action isEqualToString:VIMessengerActionSendMessage]) {
        return [NSNumber numberWithInt:21];
    }
    if ([action isEqualToString:VIMessengerActionSetStatus]) {
        return [NSNumber numberWithInt:22];
    }
    if ([action isEqualToString:VIMessengerActionSubscribe]) {
        return [NSNumber numberWithInt:23];
    }
    if ([action isEqualToString:VIMessengerActionTyping]) {
        return [NSNumber numberWithInt:24];
    }
    if ([action isEqualToString:VIMessengerActionUnsubscribe]) {
        return [NSNumber numberWithInt:25];
    }
    return [NSNumber numberWithInt:0];
}

@end
