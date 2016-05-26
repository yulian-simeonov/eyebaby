#pragma once
#include "RTSPServerConfig.h"
#include "Mutex.h"
#include <stdlib.h>
#include <vector>
#include "liveMedia.hh"

#define ReadyBufferSize 500000
using namespace std;

struct PacketInfo
{
    int size;
    uint64_t pts;
};

class MyMediaSource;
class MyAudioSource : public FramedSource
{
public:
	static MyAudioSource* createNew(UsageEnvironment& env, MyMediaSource& mediaSource);

	void Add(AVPacket* packet);
private:
	MyAudioSource(UsageEnvironment& env, MyMediaSource& mediaSource);
	~MyAudioSource(void);

	virtual void doGetNextFrame();

private:
	MyMediaSource& m_mediaSource;

	OSMutex m_mutex;
	vector<AVPacket*> m_packetArray;
    uint8_t m_readyBuffer[ReadyBufferSize];
    int     m_dataSizeInBuffer;
    static void audioReadyPoller(void* clientData);
    static EventTriggerId m_eventTriggerID;
	static void deliverFrame0(void* clientData);
	void deliverFrame();
};
