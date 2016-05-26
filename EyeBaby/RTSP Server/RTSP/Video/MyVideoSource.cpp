
#include "MyVideoSource.h"
#include "MyMediaSource.h"
#include "GroupsockHelper.hh"

EventTriggerId MyVideoSource::m_eventTriggerID = 0;
MyVideoSource* MyVideoSource::createNew(UsageEnvironment& env, MyMediaSource& mediaSource)
{
	return new MyVideoSource( env, mediaSource );
}

MyVideoSource::MyVideoSource(UsageEnvironment& env, MyMediaSource& mediaSource)
	: FramedSource( env ), m_mediaSource( mediaSource )
{
    m_mutex.Init();
	OutPacketBuffer::maxSize = VIDEO_BITRATE + AUDIO_BITRATE;
    if (m_eventTriggerID == 0)
		m_eventTriggerID = envir().taskScheduler().createEventTrigger(deliverFrame0);
}

MyVideoSource::~MyVideoSource(void)
{
	m_mediaSource.m_pVSource = NULL;
    m_mutex.Dest();
    envir().taskScheduler().deleteEventTrigger( m_eventTriggerID );
	m_eventTriggerID = 0;
    
	while (!m_packetArray.empty())
	{
		AVPacket* packet = (AVPacket*)m_packetArray[0];
        free(packet->data);
        delete packet;
		m_packetArray.erase(m_packetArray.begin());
	}
}

void MyVideoSource::audioReadyPoller(void* clientData) {
    MyVideoSource* inputDevice = (MyVideoSource*)clientData;
    inputDevice->doGetNextFrame();
}

void MyVideoSource::doGetNextFrame()
{
    deliverFrame();
}

void MyVideoSource::Add(AVPacket* packet)
{
	if (packet == NULL)	return;
    
    m_mutex.Lock();
	AVPacket* newPacket = new AVPacket;
    av_init_packet(newPacket);
    newPacket->data = (uint8_t*)malloc(packet->size);
    memcpy(newPacket->data, packet->data, packet->size);
    newPacket->size = packet->size;
	m_packetArray.push_back(newPacket);
	m_mutex.Unlock();
    
    envir().taskScheduler().triggerEvent( MyVideoSource::m_eventTriggerID, this );
}

void MyVideoSource::deliverFrame0(void* clientData)
{
	((MyVideoSource*)clientData)->deliverFrame();
}

void MyVideoSource::deliverFrame()
{
	if (!isCurrentlyAwaitingData())
		return;
    if (m_packetArray.empty())
        return;
    
    m_mutex.Lock();
    AVPacket* packet = (AVPacket*)m_packetArray[0];
	if (packet->size > fMaxSize)
	{
        fFrameSize = fMaxSize;
        fNumTruncatedBytes = packet->size - fMaxSize;
	}
	else
	{
		fFrameSize = packet->size;
 		fNumTruncatedBytes = 0;
	}
	memcpy(fTo, packet->data, fFrameSize);
    gettimeofday(&fPresentationTime, NULL);    
    m_packetArray.erase(m_packetArray.begin());
    free(packet->data);
    delete packet;
    m_mutex.Unlock();
    
	FramedSource::afterGetting(this);
}
