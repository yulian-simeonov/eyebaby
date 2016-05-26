#pragma once
#include "RTSPServerConfig.h"
#include "liveMedia.hh"
#include "UsageEnvironment.hh"

class MyMediaSource : public Medium
{
public:
	static MyMediaSource* createNew(UsageEnvironment& env);

	FramedSource* GetASource();
	FramedSource* GetVSource();

	void AddVideo(AVPacket* packet);
	void AddAudio(AVPacket* packet);
private:
	MyMediaSource(UsageEnvironment& env);
	~MyMediaSource(void);

	friend class MyVideoSource;
	friend class MyAudioSource;
public:
	static FramedSource* m_pVSource;
	static FramedSource* m_pASource;
};
