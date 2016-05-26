#pragma once
#include "RTSPServerConfig.h"
#include "MyMediaSubsession.h"

class MyAudioSubsession : public MyMediaSubsession
{
public:
	static MyAudioSubsession* createNew(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate);

private:
	MyAudioSubsession(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate);
	~MyAudioSubsession(void);

	virtual FramedSource* createNewStreamSource(unsigned clientSessionId, unsigned& estBitrate);
	virtual RTPSink* createNewRTPSink(Groupsock* rtpGroupsock, unsigned char rtpPayloadTypeIfDynamic, FramedSource* inputSource);
};
