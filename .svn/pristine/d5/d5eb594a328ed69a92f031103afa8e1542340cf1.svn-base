#pragma once

#include "MyMediaSource.h"

class MyMediaSubsession : public OnDemandServerMediaSubsession
{
public:
	MyMediaSubsession(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate);
	~MyMediaSubsession(void);

protected:
	MyMediaSource& m_mediaSource;
	unsigned m_nEstimateBitrate;
};
