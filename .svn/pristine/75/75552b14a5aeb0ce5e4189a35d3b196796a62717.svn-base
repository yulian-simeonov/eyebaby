#pragma once
#include "RTSPServerConfig.h"
#include "liveMedia.hh"
#include "UsageEnvironment.hh"

class MyMP3AudioFilter : public FramedFilter
{
public:
	static MyMP3AudioFilter* createNew(UsageEnvironment& env, FramedSource* audioSource);

private:
	MyMP3AudioFilter(UsageEnvironment& env, FramedSource* audioSource);
	~MyMP3AudioFilter(void);
	
	virtual void doGetNextFrame();

	static void afterGettingFrame(void* clientData, unsigned frameSize,
		unsigned numTruncatedBytes,
		struct timeval presentationTime,
		unsigned durationInMicroseconds);

	void afterGettingFrame1(unsigned frameSize,
		unsigned numTruncatedBytes,
		struct timeval presentationTime,
		unsigned durationInMicroseconds);

	char const* MIMEtype() const;

	bool m_fInit;
	FramedSource* m_pPCMSource;

	SwrContext* m_pConvContext;
	AVCodecContext* m_pCodecContext;

	unsigned char* m_pBuffer;
	unsigned int m_nLength;
};
