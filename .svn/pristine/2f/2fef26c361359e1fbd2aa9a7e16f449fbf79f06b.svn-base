
#include "MyAudioSubsession.h"
#include "MyMP3AudioFilter.h"
#include "MyAudioSource.h"

MyAudioSubsession::MyAudioSubsession(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate)
	: MyMediaSubsession(env, mediaSource, estBitrate)
{
    
}

MyAudioSubsession::~MyAudioSubsession(void)
{
    
}

MyAudioSubsession* MyAudioSubsession::createNew(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate)
{
	return new MyAudioSubsession( env, mediaSource, estBitrate );
}

FramedSource* MyAudioSubsession::createNewStreamSource(unsigned clientSessionId, unsigned& estBitrate)
{
	estBitrate = m_nEstimateBitrate;
//    return EndianSwap16::createNew(envir(), m_mediaSource.GetASource());
    return m_mediaSource.GetASource();
}

RTPSink* MyAudioSubsession::createNewRTPSink(Groupsock* rtpGroupsock, unsigned char rtpPayloadTypeIfDynamic, FramedSource* inputSource)
{
//    return SimpleRTPSink::createNew(envir(), rtpGroupsock, 11, 44100, "audio", "L16", 1);
    return MPEG4GenericRTPSink::createNew( envir(), rtpGroupsock, rtpPayloadTypeIfDynamic, 44100, "audio", "AAC-hbr", "1208", 1 );
}

