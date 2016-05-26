#pragma once

#include "MyMediaSubsession.h"

class MyVideoSubsession : public MyMediaSubsession
{
public:
	static MyVideoSubsession* createNew(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate);

	void setDoneFlag() { m_bDoneFlag = ~0; }
	void checkForAuxSDPLine1();

private:
	MyVideoSubsession(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate);
	~MyVideoSubsession(void);

	virtual char const* getAuxSDPLine(RTPSink* pRTPSink, FramedSource* pInputSource);
	virtual FramedSource* createNewStreamSource(unsigned clientSessionId, unsigned& estBitrate);
	virtual RTPSink* createNewRTPSink(Groupsock* rtpGroupsock, unsigned char rtpPayloadTypeIfDynamic, FramedSource* inputSource);

	char m_bDoneFlag;
	RTPSink* m_pDummyRTPSink;
};

