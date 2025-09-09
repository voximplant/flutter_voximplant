/*
 * Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_INTERNAL;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.voximplant.sdk.Voximplant;
import com.voximplant.sdk.client.ILogListener;
import com.voximplant.sdk.client.LogLevel;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class LoggerModule implements ILogListener {
    @Nullable
    private static FileLoggerModule fileLoggerModule = null;

    private final static int FILE_SIZE_LIMIT = 2_097_152;

    LoggerModule() {
        Voximplant.setLogListener(this);
    }

    void handleMethodCall(@NonNull MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("configureFileLogger")) {
            if (!call.hasArgument("path") || !call.hasArgument("fileName")) {
                result.error(ERROR_INTERNAL, "Invalid arguments", null);
                return;
            }

            @NonNull String path = call.argument("path");
            @NonNull String fileName = call.argument("fileName");
            int fileSizeLimit = call.hasArgument("fileSizeLimit") ? call.argument("fileSizeLimit") : FILE_SIZE_LIMIT;
            configure(path, fileName, fileSizeLimit);
        } else {
            result.notImplemented();
        }
    }

    private void configure(@NonNull String path, @NonNull String fileName, int fileSizeLimit) {
        if (fileLoggerModule != null) {
            fileLoggerModule.close();
        }
        fileLoggerModule = new FileLoggerModule(path, fileName, fileSizeLimit);
    }

    @Override
    public void onLogMessage(LogLevel logLevel, String s) {
        if (fileLoggerModule != null) {
            fileLoggerModule.writeLog(logLevel, s);
        }
    }
}
