/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import com.voximplant.webrtc.EglBase;

class SharedContext {
    private static EglBase mSharedEglBase;

    static synchronized EglBase getSharedEglBase() {
        if (mSharedEglBase == null) {
            mSharedEglBase = EglBase.create();
        }
        return mSharedEglBase;
    }

}
