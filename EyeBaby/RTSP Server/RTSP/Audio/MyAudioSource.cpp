
#include "MyAudioSource.h"
#include "MyMediaSource.h"
#include "GroupsockHelper.hh"
#include "UsageEnvironment.hh"

EventTriggerId MyAudioSource::m_eventTriggerID = 0;

MyAudioSource* MyAudioSource::createNew(UsageEnvironment& env, MyMediaSource& mediaSource)
{
	return new MyAudioSource( env, mediaSource );
}

MyAudioSource::MyAudioSource(UsageEnvironment& env, MyMediaSource& mediaSource)
	: FramedSource( env ), m_mediaSource( mediaSource )
{
    m_mutex.Init();
    if (m_eventTriggerID == 0)
		m_eventTriggerID = envir().taskScheduler().createEventTrigger(deliverFrame0);
    memset(m_readyBuffer, 0x0, ReadyBufferSize);
    m_dataSizeInBuffer = 0;
}

MyAudioSource::~MyAudioSource(void)
{
	m_mediaSource.m_pASource = NULL;
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

void MyAudioSource::deliverFrame0(void* clientData)
{
	((MyAudioSource*)clientData)->deliverFrame();
}

void MyAudioSource::audioReadyPoller(void* clientData) {
    MyAudioSource* inputDevice = (MyAudioSource*)clientData;
    inputDevice->doGetNextFrame();
}

void MyAudioSource::doGetNextFrame()
{
    deliverFrame();
}

void MyAudioSource::Add(AVPacket* packet)
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
    
    envir().taskScheduler().triggerEvent( MyAudioSource::m_eventTriggerID, this );
}

void MyAudioSource::deliverFrame()
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
