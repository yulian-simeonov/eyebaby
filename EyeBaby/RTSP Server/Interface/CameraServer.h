//
//  CameraServer.h
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVAssetWriter.h"
#import "AVFoundation/AVAssetWriterInput.h"
#import "AVFoundation/AVVideoSettings.h"
#import "AVFoundation/AVAudioSettings.h"
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

#import "JSQueue.h"
#import "RTSPServerManager.h"
#include "Mutex.h"

@interface CameraServer : NSObject<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureDeviceInput* videoInput;
    // Video Codec
    AVCodecContext *m_vContext;
    u_int8_t* m_pYUBBuffer;
    SwsContext* m_vConvContext;

    AVCodecContext* m_aContext;
    SwrContext* m_aConvContext;
    int m_captureWidth;
    int m_captureHeight;
    // Audio Codec
    uint8_t* m_audioBuffer;
    unsigned int m_audioBufferSize;
    dispatch_queue_t m_myQueue;
    AVCaptureVideoDataOutput* m_videoOutput;
@public
    RTSPServerManager* m_serverManager;
    AVCaptureSession* _session;
    AVCaptureDevice* dev;
    AVCaptureVideoPreviewLayer* _preview;
}
@property (nonatomic, assign) NSString* path;

- (void) startup:(AVCaptureDevicePosition)cameraType;
- (void) shutdown;
- (NSString*) getURL;
- (AVCaptureVideoPreviewLayer*) getPreviewLayer;
uint32_t GetNALSize(uint8_t* buffer, uint32_t length);
@end
