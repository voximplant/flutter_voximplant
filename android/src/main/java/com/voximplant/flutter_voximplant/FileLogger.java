package com.voximplant.flutter_voximplant;

import android.util.Log;

import com.voximplant.sdk.client.LogLevel;

import java.io.IOException;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.SimpleFormatter;

class FileLogger {
    private final static String TAG_NAME = "VOXFLUTTER";

    private FileHandler fileHandler;

    FileLogger(String path, String fileName, int fileSizeLimit) throws IOException, SecurityException, IllegalArgumentException {
        fileHandler = new FileHandler(path + "/" + fileName, fileSizeLimit, 1, true);
        fileHandler.setFormatter(new SimpleFormatter());
    }

    void writeLog(LogLevel logLevel, String msg) {
        Level level;
        switch (logLevel) {
            case ERROR:
                level = Level.SEVERE;
                break;
            case WARNING:
                level = Level.WARNING;
                break;
            case INFO:
                level = Level.INFO;
                break;
            case DEBUG:
                level = Level.CONFIG;
                break;
            case VERBOSE:
            default:
                level = Level.FINEST;
                break;
        }

        if (fileHandler != null) {
            fileHandler.publish(new LogRecord(level, msg));
        }
    }

    void close() {
        if (fileHandler != null) {
            try {
                fileHandler.close();
            } catch (SecurityException e) {
                Log.e(TAG_NAME, "FileLogger:: failed to close a file. " + e.getMessage());
            }
        }
        fileHandler = null;
    }
}
