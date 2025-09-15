/*
 * Copyright (c) 2011-2025, Voximplant, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_FILE_OPEN;
import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_INVALID_ARGUMENTS;
import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_SYSTEM_SECURITY;

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
    private FileLogger fileLogger = null;

    private LoggerModule() {}

    public synchronized static LoggerModule getInstance() {
        if (instance == null) {
            instance = new LoggerModule();
        }
        return instance;
    }

    void handleMethodCall(@NonNull MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("configureFileLogger")) {
            String path = null;
            if (call.hasArgument("path")) {
                String value = call.argument("path");
                if (value != null) {
                    path = value;
                }
            }
            String fileName = null;
            if (call.hasArgument("fileName")) {
                String value = call.argument("fileName");
                if (value != null) {
                    fileName = value;
                }
            }
            int fileSizeLimit = 0;
            if (call.hasArgument("fileSizeLimit")) {
                Integer value = call.argument("fileSizeLimit");
                if (value != null) {
                    fileSizeLimit = value;
                }
            }

            if (path == null || fileName == null || path.isEmpty() || fileName.isEmpty()) {
                result.error(ERROR_INVALID_ARGUMENTS, "Invalid arguments", null);
                return;
            }
            if (fileSizeLimit <= 0) {
                result.error(ERROR_INVALID_ARGUMENTS, "File size limit must be greater than 0", null);
                return;
            }

            configure(path, fileName, fileSizeLimit, result);
        } else {
            result.notImplemented();
        }
    }

    private void configure(@NonNull String path, @NonNull String fileName, int fileSizeLimit, MethodChannel.Result result) {
        if (fileLogger != null) {
            fileLogger.close();
            fileLogger = null;
        }
        try {
            fileLogger = new FileLogger(path, fileName, fileSizeLimit);
            Voximplant.setLogListener(this);
            result.success(null);
        } catch (IOException e) {
            Log.e(TAG_NAME, "LoggerModule: failed to open file. " + e.getMessage());
            result.error(ERROR_FILE_OPEN, "IO problems opening the file: " + e.getMessage(), null);
        } catch (SecurityException e) {
            Log.e(TAG_NAME, "LoggerModule: SecurityException: " + e.getMessage());
            result.error(ERROR_SYSTEM_SECURITY, "Security exception: " + e.getMessage(), null);
        } catch (IllegalArgumentException e) {
            Log.e(TAG_NAME, "LoggerModule: Invalid arguments: " + e.getMessage());
            result.error(ERROR_INVALID_ARGUMENTS, "Invalid arguments: " + e.getMessage(), null);
        }
    }

    void logInfo(@NonNull String message) {
        if (fileLogger != null) {
            fileLogger.writeLog(LogLevel.INFO, message);
        }
    }

    @Override
    public void onLogMessage(LogLevel logLevel, String s) {
        if (fileLogger != null) {
            fileLogger.writeLog(logLevel, s);
        }
    }
}
