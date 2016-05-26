
#include "MyMediaSource.h"
#include "MyVideoSource.h"
#include "MyAudioSource.h"

FramedSource* MyMediaSource::m_pVSource = NULL;
FramedSource* MyMediaSource::m_pASource = NULL;

MyMediaSource* MyMediaSource::createNew(UsageEnvironment& env)
{
	return new MyMediaSource( env );
}

MyMediaSource::MyMediaSource(UsageEnvironment& env)
	: Medium( env )
{
}

MyMediaSource::~MyMediaSource(void)
{
}

FramedSource* MyMediaSource::GetVSource()
{
	if (m_pVSource == NULL)
		m_pVSource = (FramedSource*)MyVideoSource::createNew( envir(), *this );

	return m_pVSource;
}

FramedSource* MyMediaSource::GetASource()
{
	if (m_pASource == NULL)
		m_pASource = (FramedSource*)MyAudioSource::createNew( envir(), *this );

	return m_pASource;
}

void MyMediaSource::AddVideo(AVPacket* packet)
{
	if (m_pVSource != NULL && packet != NULL)
		((MyVideoSource*)m_pVSource)->Add( packet );
}

void MyMediaSource::AddAudio(AVPacket* packet)
{
	if (m_pASource != NULL && packet != NULL)
		((MyAudioSource*)m_pASource)->Add( packet );
}