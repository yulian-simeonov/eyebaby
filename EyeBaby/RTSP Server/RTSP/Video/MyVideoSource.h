#pragma once

#include "RTSPServerConfig.h"
#include "Mutex.h"
#include <stdlib.h>
#include <vector>
#include "liveMedia.hh"
#include "UsageEnvironment.hh"

using namespace std;

class MyMediaSource;

class MyVideoSource : public FramedSource
{
public:
	static MyVideoSource* createNew(UsageEnvironment& env, MyMediaSource& mediaSource);

	void Add(AVPacket* packet);

private:
	MyVideoSource(UsageEnvironment& env, MyMediaSource& mediaSource);
	~MyVideoSource(void);

	virtual void doGetNextFrame();

private:
	MyMediaSource& m_mediaSource;
    
	OSMutex m_mutex;
    vector<AVPacket*> m_packetArray;
    
    static void audioReadyPoller(void* clientData);
    static EventTriggerId m_eventTriggerID;
	static void deliverFrame0(void* clientData);
	void deliverFrame();
};
