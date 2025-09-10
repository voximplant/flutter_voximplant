package com.voximplant.flutter_voximplant;

import com.voximplant.sdk.client.LogLevel;

import java.io.IOException;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.SimpleFormatter;

public class FileLoggerModule {
    private FileHandler fileHandler;

    public FileLoggerModule(String path, String fileName, int fileSizeLimit) throws IOException {
        fileHandler = new FileHandler(path + "/" + fileName, fileSizeLimit, 1, true);
        fileHandler.setFormatter(new SimpleFormatter());
    }

    public void writeLog(LogLevel logLevel, String log) {
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

        fileHandler.publish(new LogRecord(level, log));
    }

    public void close() {
        fileHandler.close();
    }
}
