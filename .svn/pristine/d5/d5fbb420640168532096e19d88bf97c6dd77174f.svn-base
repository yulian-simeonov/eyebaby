//
//  MyAudioFramedSource.h
//  EyeBaby
//
//  Created by     on 11/26/13.
//
//

#ifndef __EyeBaby__MyAudioFramedSource__
#define __EyeBaby__MyAudioFramedSource__

#include <iostream>
#include "RTSPServerConfig.h"
#include "liveMedia.hh"
#include "UsageEnvironment.hh"
#include "Mutex.h"
#include <stdlib.h>
#include <vector>
#include "MyMediaSource.h"

using namespace std;
#endif /* defined(__EyeBaby__MyAudioFramedSource__) */

class MyAudioFramedSource: public FramedSource
{
//    MyAudioFramedSource(UsageEnvironment& env, int inputPortNumber,
//                                             unsigned char bitsPerSample,
//                                             unsigned char numChannels,
//                                             unsigned samplingFrequency,
//                                             unsigned granularityInMS);
public:
    static MyAudioFramedSource* createNew(UsageEnvironment& env, MyMediaSource& mediaSource);
    MyAudioFramedSource(UsageEnvironment& env, MyMediaSource& mediaSource);
    
	void Add(AVPacket* packet);
    ~MyAudioFramedSource();
private:
    MyMediaSource& m_mediaSource;
    OSMutex m_mutex;
	vector<AVPacket*> m_packetArray;
    
    // redefined virtual functions:
    virtual void doGetNextFrame();
    virtual void doStopGettingFrames();
//    virtual double getAverageLevel() const;
    
    static void audioReadyPoller(void* clientData);
    void audioReadyPoller1();
    void onceAudioIsReady();
};