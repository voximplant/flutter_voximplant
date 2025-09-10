/*
 * Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_INTERNAL;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.voximplant.sdk.Voximplant;
import com.voximplant.sdk.client.ILogListener;
import com.voximplant.sdk.client.LogLevel;

import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class LoggerModule implements ILogListener {
    private final static String TAG_NAME = "VOXFLUTTER";

    @Nullable
    private static LoggerModule instance = null;

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
            configure(path, fileName, fileSizeLimit, result);
        } else {
            result.notImplemented();
        }
    }

    private void configure(@NonNull String path, @NonNull String fileName, int fileSizeLimit, MethodChannel.Result result) {
        if (fileLoggerModule != null) {
            fileLoggerModule.close();
        }
        try {
            fileLoggerModule = new FileLoggerModule(path, fileName, fileSizeLimit);
            result.success(null);
        } catch (IOException e) {
            Log.e(TAG_NAME, "LoggerModule:: failed to open file. " + e.getMessage());
            result.error(ERROR_INTERNAL, "Failed to configure Logger", null);
        } catch (SecurityException e) {
            Log.e(TAG_NAME, "LoggerModule:: does not have LoggingPermission(\"control\")");
            result.error(ERROR_INTERNAL, "Failed to configure Logger", null);
        }
    }

    @Override
    public void onLogMessage(LogLevel logLevel, String s) {
        if (fileLoggerModule != null) {
            fileLoggerModule.writeLog(logLevel, s);
        }
    }

    public static LoggerModule getInstance() {
        if (instance == null) {
            instance = new LoggerModule();
        }
        return instance;
    }
}
