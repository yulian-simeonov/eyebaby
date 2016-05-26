
#include "MyVideoSubsession.h"

MyVideoSubsession::MyVideoSubsession(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate)
	: MyMediaSubsession(env, mediaSource, estBitrate)
{
}

MyVideoSubsession::~MyVideoSubsession(void)
{
}

MyVideoSubsession* MyVideoSubsession::createNew(UsageEnvironment& env, MyMediaSource& mediaSource, unsigned estBitrate)
{
	return new MyVideoSubsession( env, mediaSource, estBitrate );
}

FramedSource* MyVideoSubsession::createNewStreamSource(unsigned clientSessionId, unsigned& estBitrate)
{
	estBitrate = m_nEstimateBitrate;
	return H264VideoStreamDiscreteFramer::createNew( envir(), m_mediaSource.GetVSource() );
}

RTPSink* MyVideoSubsession::createNewRTPSink(Groupsock* rtpGroupsock, unsigned char rtpPayloadTypeIfDynamic, FramedSource* inputSource)
{
	return H264VideoRTPSink::createNew( envir(), rtpGroupsock, rtpPayloadTypeIfDynamic);
}

static void checkForAuxSDPLine(void* clientData) {
	MyVideoSubsession* pThis = (MyVideoSubsession*)clientData;
	pThis->checkForAuxSDPLine1();
}

void MyVideoSubsession::checkForAuxSDPLine1()
{
	if (m_pDummyRTPSink->auxSDPLine() != NULL)
		setDoneFlag();
	else
		nextTask() = envir().taskScheduler().scheduleDelayedTask( 100000, (TaskFunc*)checkForAuxSDPLine, this );
}

static void afterPlayingDummy(void* clientData)
{
	MyVideoSubsession* pThis = (MyVideoSubsession*)clientData;
	pThis->setDoneFlag();
}

char const* MyVideoSubsession::getAuxSDPLine(RTPSink* pRTPSink, FramedSource* pInputSource)
{
	m_pDummyRTPSink = pRTPSink;
	m_pDummyRTPSink->startPlaying( *pInputSource, afterPlayingDummy, this );
	checkForAuxSDPLine( this );

	m_bDoneFlag = 0;
	envir().taskScheduler().doEventLoop( &m_bDoneFlag );

	char const* auxSDPLine = m_pDummyRTPSink->auxSDPLine();
	return auxSDPLine;
}
