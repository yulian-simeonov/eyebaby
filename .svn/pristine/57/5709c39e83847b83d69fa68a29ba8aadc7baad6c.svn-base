//
//  MyAudioFramedSource.cpp
//  EyeBaby
//
//  Created by     on 11/26/13.
//
//

#include "MyAudioFramedSource.h"

//MyAudioFramedSource::MyAudioFramedSource(UsageEnvironment& env, int inputPortNumber,
//                                 unsigned char bitsPerSample,
//                                 unsigned char numChannels,
//                                 unsigned samplingFrequency,
//                                 unsigned granularityInMS)
//: AudioInputDevice(env, bitsPerSample, numChannels, samplingFrequency, granularityInMS)
//{
//    
//}

MyAudioFramedSource* MyAudioFramedSource::createNew(UsageEnvironment& env, MyMediaSource& mediaSource)
{
	return new MyAudioFramedSource( env, mediaSource );
}

MyAudioFramedSource::MyAudioFramedSource(UsageEnvironment& env, MyMediaSource& mediaSource)
: FramedSource( env ), m_mediaSource( mediaSource )
{
    
}

MyAudioFramedSource::~MyAudioFramedSource()
{
    
}

void MyAudioFramedSource::doGetNextFrame()
{
    audioReadyPoller1();
}

void MyAudioFramedSource::doStopGettingFrames() {
    // Turn off the audio poller:
    envir().taskScheduler().unscheduleDelayedTask(nextTask());
    nextTask() = NULL;
}

void MyAudioFramedSource::audioReadyPoller(void* clientData) {
    MyAudioFramedSource* inputDevice = (MyAudioFramedSource*)clientData;
    inputDevice->audioReadyPoller1();
}

void MyAudioFramedSource::audioReadyPoller1() {
    
}

void MyAudioFramedSource::onceAudioIsReady() {

    
    // Call our own 'after getting' function.  Because we sometimes get here
    // after returning from a delay, we can call this directly, without risking
    // infinite recursion
    afterGetting(this);
}