/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.graphics.SurfaceTexture;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.webrtc.EglBase;
import org.webrtc.GlRectDrawer;
import org.webrtc.RendererCommon;
import org.webrtc.SurfaceEglRenderer;
import org.webrtc.ThreadUtils;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;

class VoximplantRenderer implements RendererCommon.RendererEvents, EventChannel.StreamHandler {
    private final String TAG_NAME = "VOXFLUTTER";
    private final TextureRegistry.SurfaceTextureEntry mSurfaceTextureEntry;
    private final SurfaceTexture mSurfaceTexture;

    private final EventChannel mRendererEventChannel;
    private EventChannel.EventSink mRendererEventSink;
    private boolean mReportRendererEvent;

    private SurfaceEglRenderer mRenderer;
    private int mFrameWidth;
    private int mFrameHeight;
    private double mAspectRatio;
    private int mRotation;
    private Handler mHandler = new Handler(Looper.getMainLooper());

    VoximplantRenderer(BinaryMessenger messenger, TextureRegistry textures) {
        mSurfaceTextureEntry = textures.createSurfaceTexture();
        mSurfaceTexture = mSurfaceTextureEntry.surfaceTexture();

        mRendererEventChannel = new EventChannel(messenger, "plugins.voximplant.com/renderer_" + getTextureId());
        mRendererEventChannel.setStreamHandler(this);

        mRenderer = new SurfaceEglRenderer("vox_renderer");
        mRenderer.init(SharedContext.getSharedEglBase().getEglBaseContext(), this,  EglBase.CONFIG_PLAIN, new GlRectDrawer());
        mRenderer.createEglSurface(mSurfaceTexture);

    }

    void release() {
        Log.i(TAG_NAME, "VoximplantRenderer: release");
        if (mRenderer != null) {
            final CountDownLatch completionLatch = new CountDownLatch(1);
            mRenderer.releaseEglSurface(completionLatch::countDown);
            ThreadUtils.awaitUninterruptibly(completionLatch);
            mRenderer.release();
            mRenderer = null;
        }
    }

    SurfaceEglRenderer getRenderer() {
        return mRenderer;
    }

    int getTextureId() {
        return (int)mSurfaceTextureEntry.id();
    }

    @Override
    public void onFirstFrameRendered() {
        Log.e(TAG_NAME, "onFirstFrameRendered");
    }

    @Override
    public void onFrameResolutionChanged(int videoWidth, int videoHeight, int rotation) {
        Log.e(TAG_NAME, "onFrameResolutionChanged: " + videoWidth + " " + videoHeight + " " + rotation);
        mSurfaceTexture.setDefaultBufferSize(videoWidth, videoHeight);
        if (mFrameWidth != videoWidth || mFrameHeight != videoHeight || mRotation != rotation) {
            if (rotation == 90 || rotation == 270) {
                mFrameWidth = videoHeight;
                mFrameHeight = videoWidth;
            } else {
                mFrameWidth = videoWidth;
                mFrameHeight = videoHeight;
            }
            mRotation = rotation;
            sendResolutionChangedEvent();
        }
    }

    private void sendResolutionChangedEvent() {
        if (mRendererEventSink != null) {
            Map<String, Object> params = new HashMap<>();
            params.put("event", "resolutionChanged");
            params.put("width", mFrameWidth);
            params.put("height", mFrameHeight);
            if (mFrameHeight != 0) {
                params.put("aspectRatio", (double) mFrameWidth / mFrameHeight);
            }
            params.put("rotation", mRotation / 90);
            params.put("textureId", getTextureId());
            mHandler.post(() -> mRendererEventSink.success(params));
            mReportRendererEvent = false;
        } else {
            mReportRendererEvent = true;
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        if (arguments instanceof String) {
            String type = (String) arguments;
            if (type.equals("plugins.voximplant.com/renderer_" + getTextureId())) {
                mRendererEventSink = events;
                if (mReportRendererEvent) {
                    sendResolutionChangedEvent();
                }
            }
        }
    }

    @Override
    public void onCancel(Object arguments) {
        if (arguments instanceof String) {
            String type = (String) arguments;
            if (type.equals("plugins.voximplant.com/renderer_" + getTextureId())) {
                mRendererEventSink = null;
            }
        }
    }
}
