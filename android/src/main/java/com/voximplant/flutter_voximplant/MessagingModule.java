package com.voximplant.flutter_voximplant;

import android.os.Handler;
import android.os.Looper;

import com.voximplant.sdk.Voximplant;
import com.voximplant.sdk.messaging.ConversationConfig;
import com.voximplant.sdk.messaging.ConversationParticipant;
import com.voximplant.sdk.messaging.IConversation;
import com.voximplant.sdk.messaging.IConversationEvent;
import com.voximplant.sdk.messaging.IConversationListEvent;
import com.voximplant.sdk.messaging.IConversationServiceEvent;
import com.voximplant.sdk.messaging.IErrorEvent;
import com.voximplant.sdk.messaging.IMessage;
import com.voximplant.sdk.messaging.IMessageEvent;
import com.voximplant.sdk.messaging.IMessenger;
import com.voximplant.sdk.messaging.IMessengerCompletionHandler;
import com.voximplant.sdk.messaging.IMessengerEvent;
import com.voximplant.sdk.messaging.IMessengerListener;
import com.voximplant.sdk.messaging.IRetransmitEvent;
import com.voximplant.sdk.messaging.IStatusEvent;
import com.voximplant.sdk.messaging.ISubscriptionEvent;
import com.voximplant.sdk.messaging.IUserEvent;
import com.voximplant.sdk.messaging.MessengerAction;
import com.voximplant.sdk.messaging.MessengerEventType;
import com.voximplant.sdk.messaging.MessengerNotification;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_INVALID_ARGUMENTS;
import static com.voximplant.sdk.messaging.MessengerNotification.ON_EDIT_MESSAGE;
import static com.voximplant.sdk.messaging.MessengerNotification.ON_SEND_MESSAGE;

class MessagingModule implements EventChannel.StreamHandler, IMessengerListener {
    private EventChannel mEventChannel;
    private EventChannel.EventSink mEventSink;
    private IMessenger mMessenger;
    private Handler mHandler = new Handler(Looper.getMainLooper());

    MessagingModule(BinaryMessenger messenger) {
        mEventChannel = new EventChannel(messenger, "plugins.voximplant.com/messaging");
        mEventChannel.setStreamHandler(this);
        mMessenger = Voximplant.getMessenger();
        mMessenger.addMessengerListener(this);
    }

    void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "getUserByName":
                getUserByName(call, result);
                break;
            case "getUserByIMId":
                getUserById(call, result);
                break;
            case "getUsersByName":
                getUsersByName(call, result);
                break;
            case "getUsersByIMId":
                getUsersByIMId(call, result);
                break;
            case "editUser":
                editUser(call, result);
                break;
            case "managePushNotifications":
                managePushNotifications(call, result);
                break;
            case "setStatus":
                setStatus(call, result);
                break;
            case "subscribe":
                subscribe(call, result);
                break;
            case "unsubscribe":
                unsubscribe(call, result);
                break;
            case "unsubscribeFromAll":
                unsubscribeFromAll(result);
                break;
            case "getSubscriptions":
                getSubscriptionList(result);
                break;
            case "createConversation":
                createConversation(call, result);
                break;
            case "getConversation":
                getConversation(call, result);
                break;
            case "getConversations":
                getConversations(call, result);
                break;
            case "getPublicConversations":
                getPublicConversations(result);
                break;
            case "joinConversation":
                joinConversation(call, result);
                break;
            case "leaveConversation":
                leaveConversation(call, result);
                break;
            case "addParticipants":
                addParticipants(call, result);
                break;
            case "editParticipants":
                editParticipants(call, result);
                break;
            case "removeParticipants":
                removeParticipants(call, result);
                break;
            case "updateConversation":
                updateConversation(call, result);
                break;
            case "markAsRead":
                markAsRead(call, result);
                break;
            case "typing":
                typing(call, result);
                break;
            case "sendMessage":
                sendMessage(call, result);
                break;
            case "retransmitEvents":
                retransmitEvents(call, result);
                break;
            case "retransmitEventsFrom":
                retransmitEventsFrom(call, result);
                break;
            case "retransmitEventsTo":
                retransmitEventsTo(call, result);
                break;
            case "updateMessage":
                updateMessage(call, result);
                break;
            case "removeMessage":
                removeMessage(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void getUserByName(MethodCall call, MethodChannel.Result result) {
        String name = call.argument("name");
        if (name == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.getUserByName: name parameter can not be null", null));
            return;
        }
        mMessenger.getUser(name, new IMessengerCompletionHandler<IUserEvent>() {
            @Override
            public void onSuccess(IUserEvent iUserEvent) {
                mHandler.post(() -> result.success(makeMapFromUserEvent(iUserEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void getUserById(MethodCall call, MethodChannel.Result result) {
        Integer user = call.argument("id");
        if (user == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.getUserByIMId: id parameter can not be null", null));
            return;
        }
        mMessenger.getUser(user, new IMessengerCompletionHandler<IUserEvent>() {
            @Override
            public void onSuccess(IUserEvent iUserEvent) {
                mHandler.post(() -> result.success(makeMapFromUserEvent(iUserEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void getUsersByName(MethodCall call, MethodChannel.Result result) {
        List<String> users = call.argument("users");
        if (users == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.getUsersByName: users parameter can not be null", null));
            return;
        }
        mMessenger.getUsersByName(users, new IMessengerCompletionHandler<List<IUserEvent>>() {
            @Override
            public void onSuccess(List<IUserEvent> iUserEvents) {
                List<Map> events = new ArrayList<>();
                for (IUserEvent event : iUserEvents) {
                    events.add(makeMapFromUserEvent(event));
                }
                mHandler.post(() -> result.success(events));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void getUsersByIMId(MethodCall call, MethodChannel.Result result) {
        List<Long> users = new ArrayList<>();
        List<Integer> intIds = call.argument("users");
        if (intIds == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.getUsersByIMId: users parameter can not be null", null));
            return;
        }
        for (Integer intId : intIds) {
            users.add(intId.longValue());
        }
        mMessenger.getUsersByIMId(users, new IMessengerCompletionHandler<List<IUserEvent>>() {
            @Override
            public void onSuccess(List<IUserEvent> iUserEvents) {
                List<Map> users = new ArrayList<>();
                for (IUserEvent userEvent : iUserEvents) {
                    users.add(makeMapFromUserEvent(userEvent));
                }
                mHandler.post(() -> result.success(users));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void editUser(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> customData = call.argument("customData");
        Map<String, Object> privateCustomData = call.argument("privateCustomData");
        mMessenger.editUser(customData, privateCustomData, new IMessengerCompletionHandler<IUserEvent>() {
            @Override
            public void onSuccess(IUserEvent iUserEvent) {
                mHandler.post(() -> result.success(makeMapFromUserEvent(iUserEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void managePushNotifications(MethodCall call, MethodChannel.Result result) {
        List<Integer> notificationsInt = call.argument("notifications");
        List<MessengerNotification> notifications = new ArrayList<>();
        if (notificationsInt != null) {
            for (Integer notification : notificationsInt) {
                notifications.add(makeNotificationFromInt(notification));
            }
        }
        mMessenger.managePushNotifications(notifications, new IMessengerCompletionHandler<IUserEvent>() {
            @Override
            public void onSuccess(IUserEvent iUserEvent) {
                mHandler.post(() -> result.success(makeMapFromUserEvent(iUserEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void setStatus(MethodCall call, MethodChannel.Result result) {
        Boolean isOnline = call.argument("online");
        if (isOnline == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.setStatus: isOnline parameter can not be null", null));
            return;
        }
        mMessenger.setStatus(isOnline, new IMessengerCompletionHandler<IStatusEvent>() {
            @Override
            public void onSuccess(IStatusEvent iStatusEvent) {
                mHandler.post(() -> result.success(makeMapFromStatusEvent(iStatusEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void subscribe(MethodCall call, MethodChannel.Result result) {
        List<Long> users = new ArrayList<>();
        List<Integer> userIds = call.argument("users");
        if (userIds == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.subscribe: users parameter can not be null", null));
            return;
        }
        for (Integer userId : userIds) {
            users.add(userId.longValue());
        }
        mMessenger.subscribe(users, new IMessengerCompletionHandler<ISubscriptionEvent>() {
            @Override
            public void onSuccess(ISubscriptionEvent iSubscriptionEvent) {
                mHandler.post(() -> result.success(makeMapFromSubscriptionEvent(iSubscriptionEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void unsubscribe(MethodCall call, MethodChannel.Result result) {
        List<Long> users = new ArrayList<>();
        List<Integer> userIds = call.argument("users");
        if (userIds == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "Messaging.unsubscribe: users parameter can not be null", null);
            return;
        }
        for (Integer userId : userIds) {
            users.add(userId.longValue());
        }
        mMessenger.unsubscribe(users, new IMessengerCompletionHandler<ISubscriptionEvent>() {
            @Override
            public void onSuccess(ISubscriptionEvent iSubscriptionEvent) {
                mHandler.post(() -> result.success(makeMapFromSubscriptionEvent(iSubscriptionEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void unsubscribeFromAll(MethodChannel.Result result) {
        mMessenger.unsubscribeFromAll(new IMessengerCompletionHandler<ISubscriptionEvent>() {
            @Override
            public void onSuccess(ISubscriptionEvent iSubscriptionEvent) {
                mHandler.post(() -> result.success(makeMapFromSubscriptionEvent(iSubscriptionEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void getSubscriptionList(MethodChannel.Result result) {
        mMessenger.getSubscriptionList(new IMessengerCompletionHandler<ISubscriptionEvent>() {
            @Override
            public void onSuccess(ISubscriptionEvent iSubscriptionEvent) {
                mHandler.post(() -> result.success(makeMapFromSubscriptionEvent(iSubscriptionEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void createConversation(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> config = call.argument("config");
        if (config == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.createConversation: config parameter can not be null", null));
            return;
        }
        mMessenger.createConversation(makeConfigFromMap(config), new IMessengerCompletionHandler<IConversationEvent>() {
            @Override
            public void onSuccess(IConversationEvent iConversationEvent) {
                mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void getConversation(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("uuid");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.getConversation: uuid parameter can not be null", null));
            return;
        }
        mMessenger.getConversation(uuid, new IMessengerCompletionHandler<IConversationEvent>() {
            @Override
            public void onSuccess(IConversationEvent iConversationEvent) {
                mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void getConversations(MethodCall call, MethodChannel.Result result) {
        List<String> uuids = call.argument("uuids");
        if (uuids == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.getConversations: uuids parameter can not be null", null));
            return;
        }
        mMessenger.getConversations(uuids, new IMessengerCompletionHandler<List<IConversationEvent>>() {
            @Override
            public void onSuccess(List<IConversationEvent> iConversationEvents) {
                List<Map> events = new ArrayList<>();
                for (IConversationEvent event : iConversationEvents) {
                    events.add(makeMapFromConversationEvent(event));
                }
                mHandler.post(() -> result.success(events));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void getPublicConversations(MethodChannel.Result result) {
        mMessenger.getPublicConversations(new IMessengerCompletionHandler<IConversationListEvent>() {
            @Override
            public void onSuccess(IConversationListEvent iConversationListEvent) {
                mHandler.post(() -> result.success(makeMapFromConversationListEvent(iConversationListEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void joinConversation(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("uuid");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.joinConversation: uuid parameter can not be null", null));
            return;
        }
        mMessenger.joinConversation(uuid, new IMessengerCompletionHandler<IConversationEvent>() {
            @Override
            public void onSuccess(IConversationEvent iConversationEvent) {
                mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void leaveConversation(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("uuid");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.leaveConversation: uuid parameter can not be null", null));
            return;
        }
        mMessenger.leaveConversation(uuid, new IMessengerCompletionHandler<IConversationEvent>() {
            @Override
            public void onSuccess(IConversationEvent iConversationEvent) {
                mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
            }
            @Override
            public void onError(IErrorEvent iErrorEvent) {
                mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
            }
        });
    }

    private void addParticipants(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.addParticipants: conversation parameter can not be null", null));
            return;
        }
        List<ConversationParticipant> participants = new ArrayList<>();
        List<Map<String, Object>> participantsList = call.argument("participants");
        if (participantsList != null) {
            for (Map<String, Object> map : participantsList) {
                participants.add(makeParticipantFromMap(map));
            }
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.addParticipants(participants, new IMessengerCompletionHandler<IConversationEvent>() {
                @Override
                public void onSuccess(IConversationEvent iConversationEvent) {
                    mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.addParticipants: conversation with the given uuid couldn't be found", null));
        }
    }

    private void editParticipants(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.editParticipants: conversation parameter can not be null", null));
            return;
        }

        List<ConversationParticipant> participants = new ArrayList<>();
        List<Map<String, Object>> participantsList = call.argument("participants");
        if (participantsList != null) {
            for (Map<String, Object> map : participantsList) {
                participants.add(makeParticipantFromMap(map));
            }
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.editParticipants(participants, new IMessengerCompletionHandler<IConversationEvent>() {
                @Override
                public void onSuccess(IConversationEvent iConversationEvent) {
                    mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.editParticipants: conversation with the given uuid couldn't be found", null));
        }
    }

    private void removeParticipants(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.removeParticipants: conversation parameter can not be null", null));
            return;
        }

        List<ConversationParticipant> participants = new ArrayList<>();
        List<Map<String, Object>> participantsList = call.argument("participants");
        if (participantsList != null) {
            for (Map<String, Object> map : participantsList) {
                participants.add(makeParticipantFromMap(map));
            }
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.removeParticipants(participants, new IMessengerCompletionHandler<IConversationEvent>() {
                @Override
                public void onSuccess(IConversationEvent iConversationEvent) {
                    mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.removeParticipants: conversation with the given uuid couldn't be found", null));
        }
    }

    private void updateConversation(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.updateConversation: conversation parameter can not be null", null));
            return;
        }
        ConversationConfig.ConversationConfigBuilder builder = ConversationConfig.createBuilder();
        builder
                .setTitle(call.argument("title"))
                .setCustomData(call.argument("customData"));
        Boolean publicJoin = call.argument("publicJoin");
        if (publicJoin != null) {
            builder.setPublicJoin(publicJoin);
        }
        IConversation conversation = mMessenger.recreateConversation(builder.build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.update(new IMessengerCompletionHandler<IConversationEvent>() {
                @Override
                public void onSuccess(IConversationEvent iConversationEvent) {
                    mHandler.post(() -> result.success(makeMapFromConversationEvent(iConversationEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.updateConversation: conversation with the given uuid couldn't be found", null));
        }
    }

    private void markAsRead(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.markAsRead: conversation parameter can not be null", null));
            return;
        }
        Integer sequence = call.argument("sequence");
        if (sequence == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.markAsRead: sequence parameter can not be null", null));
            return;
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.markAsRead(sequence.longValue(), new IMessengerCompletionHandler<IConversationServiceEvent>() {
                @Override
                public void onSuccess(IConversationServiceEvent iConversationServiceEvent) {
                    mHandler.post(() -> result.success(makeMapFromConversationServiceEvent(iConversationServiceEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.markAsRead: conversation with the given uuid couldn't be found", null));
        }
    }

    private void typing(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.typing: conversation parameter can not be null", null));
            return;
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.typing(new IMessengerCompletionHandler<IConversationServiceEvent>() {
                @Override
                public void onSuccess(IConversationServiceEvent iConversationServiceEvent) {
                    mHandler.post(() -> result.success(makeMapFromConversationServiceEvent(iConversationServiceEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.typing: conversation with the given uuid couldn't be found", null));
        }
    }

    private void sendMessage(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.sendMessage: conversation parameter can not be null", null));
            return;
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.sendMessage(call.argument("text"), call.argument("payload"), new IMessengerCompletionHandler<IMessageEvent>() {
                @Override
                public void onSuccess(IMessageEvent iMessageEvent) {
                    mHandler.post(() -> result.success(makeMapFromMessageEvent(iMessageEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.sendMessage: conversation with the given uuid couldn't be found", null));
        }
    }

    private void retransmitEvents(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEvents: conversation parameter can not be null", null));
            return;
        }
        Integer from = call.argument("from");
        if (from == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEvents: from parameter can not be null", null));
            return;
        }
        Integer to = call.argument("to");
        if (to == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEvents: to parameter can not be null", null));

            return;
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.retransmitEvents(from.longValue(), to.longValue(), new IMessengerCompletionHandler<IRetransmitEvent>() {
                @Override
                public void onSuccess(IRetransmitEvent iRetransmitEvent) {
                    mHandler.post(() -> result.success(makeMapFromRetransmitEvent(iRetransmitEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEvents: conversation with the given uuid couldn't be found", null));
        }
    }

    private void retransmitEventsFrom(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsFrom: conversation parameter can not be null", null));
            return;
        }
        Integer from = call.argument("from");
        if (from == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsFrom: from parameter can not be null", null));
            return;
        }
        Integer count = call.argument("count");
        if (count == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsFrom: count parameter can not be null", null));
            return;
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.retransmitEventsFrom(from.longValue(), count, new IMessengerCompletionHandler<IRetransmitEvent>() {
                @Override
                public void onSuccess(IRetransmitEvent iRetransmitEvent) {
                    mHandler.post(() -> result.success(makeMapFromRetransmitEvent(iRetransmitEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsFrom: conversation with the given uuid couldn't be found", null));
        }
    }

    private void retransmitEventsTo(MethodCall call, MethodChannel.Result result) {
        String uuid = call.argument("conversation");
        if (uuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsTo: conversation parameter can not be null", null));
            return;
        }
        Integer to = call.argument("to");
        if (to == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsTo: to parameter can not be null", null));
            return;
        }
        Integer count = call.argument("count");
        if (count == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsTo: count parameter can not be null", null));
            return;
        }
        IConversation conversation = mMessenger.recreateConversation(ConversationConfig.createBuilder().build(), uuid, 0, 0, 0);
        if (conversation != null) {
            conversation.retransmitEventsTo(to.longValue(), count, new IMessengerCompletionHandler<IRetransmitEvent>() {
                @Override
                public void onSuccess(IRetransmitEvent iRetransmitEvent) {
                    mHandler.post(() -> result.success(makeMapFromRetransmitEvent(iRetransmitEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.retransmitEventsTo: conversation with the given uuid couldn't be found", null));
        }
    }

    private void updateMessage(MethodCall call, MethodChannel.Result result) {
        String conversation = call.argument("conversation");
        if (conversation == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.updateMessage: conversation parameter can not be null", null));
            return;
        }
        String messageUuid = call.argument("message");
        if (messageUuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.updateMessage: message parameter can not be null", null));
            return;
        }
        IMessage message = mMessenger.recreateMessage(messageUuid, conversation, call.argument("text"), call.argument("payload"), 0);
        if (message != null) {
            message.update(call.argument("text"), call.argument("payload"), new IMessengerCompletionHandler<IMessageEvent>() {
                @Override
                public void onSuccess(IMessageEvent iMessageEvent) {
                    mHandler.post(() -> result.success(makeMapFromMessageEvent(iMessageEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.updateMessage: message with the given uuid couldn't be found", null));
        }
    }

    private void removeMessage(MethodCall call, MethodChannel.Result result) {
        String conversation = call.argument("conversation");
        if (conversation == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.removeMessage: conversation parameter can not be null", null));
            return;
        }
        String messageUuid = call.argument("message");
        if (messageUuid == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.removeMessage: message parameter can not be null", null));
            return;
        }
        IMessage message = mMessenger.recreateMessage(messageUuid, conversation, null, null, 0);
        if (message != null) {
            message.remove(new IMessengerCompletionHandler<IMessageEvent>() {
                @Override
                public void onSuccess(IMessageEvent iMessageEvent) {
                    mHandler.post(() -> result.success(makeMapFromMessageEvent(iMessageEvent)));
                }
                @Override
                public void onError(IErrorEvent iErrorEvent) {
                    mHandler.post(() -> result.error(Utils.convertMessagingErrorToString(iErrorEvent), iErrorEvent.getErrorDescription(), null));
                }
            });
        } else {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Messaging.removeMessage: message with the given uuid couldn't be found", null));
        }
    }

    @Override
    public void onGetUser(IUserEvent iUserEvent) { }

    @Override
    public void onEditUser(IUserEvent iUserEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onEditUser");
        event.put("event", makeMapFromUserEvent(iUserEvent));
        sendEvent(event);
    }

    @Override
    public void onSubscribe(ISubscriptionEvent iSubscriptionEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onSubscribe");
        event.put("event", makeMapFromSubscriptionEvent(iSubscriptionEvent));
        sendEvent(event);
    }

    @Override
    public void onUnsubscribe(ISubscriptionEvent iSubscriptionEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onUnsubscribe");
        event.put("event", makeMapFromSubscriptionEvent(iSubscriptionEvent));
        sendEvent(event);
    }

    @Override
    public void onGetSubscriptionList(ISubscriptionEvent iSubscriptionEvent) { }

    @Override
    public void onCreateConversation(IConversationEvent iConversationEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onCreateConversation");
        event.put("event", makeMapFromConversationEvent(iConversationEvent));
        sendEvent(event);
    }

    @Override
    public void onRemoveConversation(IConversationEvent iConversationEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onRemoveConversation");
        event.put("event", makeMapFromConversationEvent(iConversationEvent));
        sendEvent(event);
    }

    @Override
    public void onGetConversation(IConversationEvent iConversationEvent) { }

    @Override
    public void onGetPublicConversations(IConversationListEvent iConversationListEvent) { }

    @Override
    public void onEditConversation(IConversationEvent iConversationEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onEditConversation");
        event.put("event", makeMapFromConversationEvent(iConversationEvent));
        sendEvent(event);
    }

    @Override
    public void onSetStatus(IStatusEvent iStatusEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onSetStatus");
        event.put("event", makeMapFromStatusEvent(iStatusEvent));
        sendEvent(event);
    }

    @Override
    public void onEditMessage(IMessageEvent iMessageEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onEditMessage");
        event.put("event", makeMapFromMessageEvent(iMessageEvent));
        sendEvent(event);
    }

    @Override
    public void onSendMessage(IMessageEvent iMessageEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onSendMessage");
        event.put("event", makeMapFromMessageEvent(iMessageEvent));
        sendEvent(event);
    }

    @Override
    public void onRemoveMessage(IMessageEvent iMessageEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onRemoveMessage");
        event.put("event", makeMapFromMessageEvent(iMessageEvent));
        sendEvent(event);
    }

    @Override
    public void onTyping(IConversationServiceEvent iConversationServiceEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "onTyping");
        event.put("event", makeMapFromConversationServiceEvent(iConversationServiceEvent));
        sendEvent(event);
    }

    @Override
    public void isRead(IConversationServiceEvent iConversationServiceEvent) {
        Map<String, Object> event = new HashMap<>();
        event.put("name", "isRead");
        event.put("event", makeMapFromConversationServiceEvent(iConversationServiceEvent));
        sendEvent(event);
    }

    @Override
    public void onError(IErrorEvent iErrorEvent) { }

    @Override
    public void onRetransmitEvents(IRetransmitEvent iRetransmitEvent) { }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        mEventSink = null;
    }

    private void sendEvent(Map<String, Object> event) {
        if (mEventSink != null) {
            mHandler.post(() -> mEventSink.success(event));
        }
    }

    private Map<String, Object> makeMapFromRetransmitEvent(IRetransmitEvent iRetransmitEvent) {
        Map<String, Object> map = makeMapFromEvent(iRetransmitEvent);
        List<Map<String, Object>> events = new ArrayList<>();
        for (IMessengerEvent event : iRetransmitEvent.getEvents()) {
            events.add(makeMapFromMessengerEvent(event));
        }
        map.put("events", events);
        map.put("fromSequence", iRetransmitEvent.getFromSequence());
        map.put("toSequence", iRetransmitEvent.getToSequence());
        return map;
    }

    private Map<String, Object> makeMapFromMessengerEvent(IMessengerEvent iMessengerEvent) {
        if (iMessengerEvent instanceof IMessageEvent) {
            return makeMapFromMessageEvent(((IMessageEvent) iMessengerEvent));
        } else if (iMessengerEvent instanceof IConversationEvent) {
            return makeMapFromConversationEvent(((IConversationEvent) iMessengerEvent));
        } else {
            return null;
        }
    }

    private Map<String, Object> makeMapFromMessageEvent(IMessageEvent iMessageEvent) {
        Map<String, Object> event = makeMapFromEvent(iMessageEvent);
        event.put("message", makeMapFromMessage(iMessageEvent.getMessage()));
        event.put("sequence", iMessageEvent.getSequence());
        event.put("timestamp", iMessageEvent.getTimestamp());
        return event;
    }

    private Map<String, Object> makeMapFromMessage(IMessage iMessage) {
        Map<String, Object> map = new HashMap<>();
        map.put("uuid", iMessage.getUUID());
        map.put("conversation", iMessage.getConversation());
        map.put("sequence", iMessage.getSequence());
        map.put("text", iMessage.getText());
        map.put("payload", iMessage.getPayload());
        return map;
    }

    private Map<String, Object> makeMapFromConversationServiceEvent(IConversationServiceEvent iConversationServiceEvent) {
        Map<String, Object> event = makeMapFromEvent(iConversationServiceEvent);
        event.put("conversationUuid", iConversationServiceEvent.getConversationUUID());
        event.put("sequence", iConversationServiceEvent.getSequence());
        return event;
    }

    private Map<String, Object> makeMapFromConversationEvent(IConversationEvent iConversationEvent) {
        Map<String, Object> event = makeMapFromEvent(iConversationEvent);
        event.put("conversation", makeMapFromConversation(iConversationEvent.getConversation()));
        event.put("sequence", iConversationEvent.getSequence());
        event.put("timestamp", iConversationEvent.getTimestamp());
        return event;
    }

    private Map<String, Object> makeMapFromConversation(IConversation iConversation) {
        Map<String, Object> map = new HashMap<>();
        map.put("uuid", iConversation.getUUID());
        map.put("title", iConversation.getTitle());
        map.put("direct", iConversation.isDirect());
        map.put("uber", iConversation.isUber());
        map.put("publicJoin", iConversation.isPublicJoin());
        List<Map<String, Object>> participants = new ArrayList<>();
        for (ConversationParticipant participant : iConversation.getParticipants()) {
            participants.add(makeMapFromParticipant(participant));
        }
        map.put("participants", participants);
        map.put("createdTime", iConversation.getCreatedTime());
        map.put("lastSequence", iConversation.getLastSequence());
        map.put("lastUpdateTime", iConversation.getLastUpdateTime());
        map.put("customData", iConversation.getCustomData());
        return map;
    }

    private Map<String, Object> makeMapFromConversationListEvent(IConversationListEvent iConversationListEvent) {
        Map<String, Object> event = makeMapFromEvent(iConversationListEvent);
        event.put("conversationList", iConversationListEvent.getConversationList());
        return event;
    }

    private Map<String, Object> makeMapFromSubscriptionEvent(ISubscriptionEvent iSubscriptionEvent) {
        Map<String, Object> event = makeMapFromEvent(iSubscriptionEvent);
        event.put("users", iSubscriptionEvent.getUsers());
        return event;
    }

    private Map<String, Object> makeMapFromStatusEvent(IStatusEvent iStatusEvent) {
        Map<String, Object> event = makeMapFromEvent(iStatusEvent);
        event.put("isOnline", iStatusEvent.isOnline());
        return event;
    }

    private Map<String, Object> makeMapFromUserEvent(IUserEvent iUserEvent) {
        Map<String, Object> user = new HashMap<>();
        user.put("id", iUserEvent.getUser().getIMId());
        user.put("displayName", iUserEvent.getUser().getDisplayName());
        user.put("name", iUserEvent.getUser().getName());
        user.put("isDeleted", iUserEvent.getUser().isDeleted());

        List<String> conversationList = iUserEvent.getUser().getConversationList();
        if (conversationList != null) {
            user.put("conversationList", conversationList);
        }

        List<String> leaveConversationList = iUserEvent.getUser().getLeaveConversationList();
        if (leaveConversationList != null) {
            user.put("leaveConversationList", leaveConversationList);
        }

        List<MessengerNotification> notifications = iUserEvent.getUser().getNotifications();
        if (notifications != null) {
            List<Integer> notificationsInt = new ArrayList<>();
            for (MessengerNotification notification : notifications) {
                notificationsInt.add(makeIntFromNotification(notification));
            }
            user.put("notifications", notificationsInt);
        }

        Map<String, Object> privateCustomData = iUserEvent.getUser().getPrivateCustomData();
        if (privateCustomData != null) {
            user.put("privateCustomData", privateCustomData);
        }

        Map<String, Object> customData = iUserEvent.getUser().getCustomData();
        if (customData != null) {
            user.put("customData", customData);
        } else {
            user.put("customData", Collections.emptyMap());
        }

        Map<String, Object> event = makeMapFromEvent(iUserEvent);
        event.put("user", user);

        return event;
    }

    private Map<String, Object> makeMapFromEvent(IMessengerEvent event) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", event.getIMUserId());
        map.put("action", makeIntFromAction(event.getMessengerAction()));
        map.put("type", makeIntFromEventType(event.getMessengerEventType()));
        return map;
    }

    private ConversationParticipant makeParticipantFromMap(Map<String, Object> map) {
        Object id = map.get("id");
        if (!(id instanceof Integer)) {
            return null;
        }
        ConversationParticipant participant = new ConversationParticipant(((Integer) id).longValue());
        Object isOwner = map.get("isOwner");
        if (isOwner instanceof Boolean) {
            participant.setOwner((Boolean)isOwner);
        }
        Object canWrite = map.get("canWrite");
        if (canWrite instanceof Boolean) {
            participant.setCanWrite((Boolean)canWrite);
        }
        Object canEditMessages = map.get("canEditMessages");
        if (canEditMessages instanceof Boolean) {
            participant.setCanEditMessages((Boolean)canEditMessages);
        }
        Object canEditAllMessages = map.get("canEditAllMessages");
        if (canEditAllMessages instanceof Boolean) {
            participant.setCanEditAllMessages((Boolean)canEditAllMessages);
        }
        Object canRemoveMessages = map.get("canRemoveMessages");
        if (canRemoveMessages instanceof Boolean) {
            participant.setCanRemoveMessages((Boolean)canRemoveMessages);
        }
        Object canRemoveAllMessages = map.get("canRemoveAllMessages");
        if (canRemoveAllMessages instanceof Boolean) {
            participant.setCanRemoveAllMessages((Boolean)canRemoveAllMessages);
        }
        Object canManageParticipants = map.get("canManageParticipants");
        if (canManageParticipants instanceof Boolean) {
            participant.setCanManageParticipants((Boolean)canManageParticipants);
        }
        return participant;
    }

    private Map<String, Object> makeMapFromParticipant(ConversationParticipant participant) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", participant.getIMUserId());
        map.put("lastReadSequence", participant.getLastReadEventSequence());
        map.put("isOwner", participant.isOwner());
        map.put("canWrite", participant.canWrite());
        map.put("canEditMessages", participant.canEditMessages());
        map.put("canEditAllMessages", participant.canEditAllMessages());
        map.put("canRemoveMessages", participant.canRemoveMessages());
        map.put("canRemoveAllMessages", participant.canRemoveAllMessages());
        map.put("canManageParticipants", participant.canManageParticipants());
        return map;
    }

    @SuppressWarnings("unchecked")
    private ConversationConfig makeConfigFromMap(Map<String, Object> map) {
        ConversationConfig.ConversationConfigBuilder builder = ConversationConfig.createBuilder();
        Object direct = map.get("direct");
        if (direct instanceof Boolean) {
            builder.setDirect((Boolean) direct);
        }
        Object publicJoin = map.get("publicJoin");
        if (publicJoin instanceof Boolean) {
            builder.setPublicJoin((Boolean) publicJoin);
        }
        Object uber = map.get("uber");
        if (uber instanceof Boolean) {
            builder.setUber((Boolean)uber);
        }
        builder.setTitle((String)map.get("title"));
        Object customData = map.get("customData");
        if (customData instanceof Map) {
            builder.setCustomData((Map<String, Object>)customData);
        }
        Object participantsObj = map.get("participants");
        if (participantsObj instanceof List) {
            List<Map> participantsList = (List<Map>) participantsObj;
            List<ConversationParticipant> participants = new ArrayList<>();
            for (Map participant : participantsList) {
                participants.add(makeParticipantFromMap(participant));
            }
            builder.setParticipants(participants);
        }
        return builder.build();
    }

    private Integer makeIntFromNotification(MessengerNotification notification) {
        switch (notification) {
            case ON_SEND_MESSAGE:
                return 1;
            case ON_EDIT_MESSAGE:
            default:
                return 0;
        }
    }

    private MessengerNotification makeNotificationFromInt(Integer notification) {
        switch (notification) {
            case 1:
                return ON_SEND_MESSAGE;
            case 0:
            default:
                return ON_EDIT_MESSAGE;
        }
    }

    private Integer makeIntFromEventType(MessengerEventType type) {
        switch (type) {
            case IS_READ:
                return 1;
            case ON_CREATE_CONVERSATION:
                return 2;
            case ON_EDIT_CONVERSATION:
                return 3;
            case ON_EDIT_MESSAGE:
                return 4;
            case ON_EDIT_USER:
                return 5;
            case ON_GET_CONVERSATION:
                return 6;
            case ON_GET_PUBLIC_CONVERSATIONS:
                return 7;
            case ON_GET_SUBSCRIPTION_LIST:
                return 8;
            case ON_GET_USER:
                return 9;
            case ON_REMOVE_CONVERSATION:
                return 10;
            case ON_REMOVE_MESSAGE:
                return 11;
            case ON_RETRANSMIT_EVENTS:
                return 12;
            case ON_SEND_MESSAGE:
                return 13;
            case ON_SET_STATUS:
                return 14;
            case ON_SUBSCRIBE:
                return 15;
            case ON_TYPING:
                return 16;
            case ON_UNSUBSCRIBE:
                return 17;
            case EVENT_UNKNOWN:
            default:
                return 0;
        }
    }

    private Integer makeIntFromAction(MessengerAction action) {
        switch (action) {
            case ADD_PARTICIPANTS:
                return 1;
            case CREATE_CONVERSATION:
                return 2;
            case EDIT_CONVERSATION:
                return 3;
            case EDIT_MESSAGE:
                return 4;
            case EDIT_PARTICIPANTS:
                return 5;
            case EDIT_USER:
                return 6;
            case GET_CONVERSATION:
                return 7;
            case GET_CONVERSATIONS:
                return 8;
            case GET_SUBSCRIPTION_LIST:
                return 9;
            case GET_PUBLIC_CONVERSATIONS:
                return 10;
            case GET_USER:
                return 11;
            case GET_USERS:
                return 12;
            case IS_READ:
                return 13;
            case JOIN_CONVERSATION:
                return 14;
            case LEAVE_CONVERSATION:
                return 15;
            case MANAGE_NOTIFICATIONS:
                return 16;
            case REMOVE_CONVERSATION:
                return 17;
            case REMOVE_MESSAGE:
                return 18;
            case REMOVE_PARTICIPANTS:
                return 19;
            case RETRANSMIT_EVENTS:
                return 20;
            case SEND_MESSAGE:
                return 21;
            case SET_STATUS:
                return 22;
            case SUBSCRIBE:
                return 23;
            case TYPING_MESSAGE:
                return 24;
            case UNSUBSCRIBE:
                return 25;
            case ACTION_UNKNOWN:
            default:
                return 0;
        }
    }
}
