//
//  CameraServer.m
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "CameraServer.h"

uint32_t GetNALSize(uint8_t* buffer, uint32_t length)
{
    for (uint32_t i = 0; i < length - 4; i++ )
	{
		if ((buffer[i]==0 && buffer[i+1]==0 && buffer[i+2]==0 && buffer[i+3]==1) ||
			(buffer[i]==0 && buffer[i+1]==0 && buffer[i+2]==1))
			return i;
	}
    
	return length;
}

@implementation CameraServer

-(id)init
{
    if (self = [super init])
    {
        m_serverManager = [[RTSPServerManager alloc] init];
        _session = [[AVCaptureSession alloc] init];
        [self InitCodec];
        // Audio
        m_myQueue = dispatch_queue_create("MyQueue", NULL);
        AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error = nil;
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
        if (audioInput)
            [_session addInput:audioInput];
        AVCaptureAudioDataOutput* audioOutput = [[[AVCaptureAudioDataOutput alloc] init] autorelease];
        [audioOutput setSampleBufferDelegate:self queue:m_myQueue];
        [_session addOutput:audioOutput];
        
        // Video
        // create an output for YUV output with self as delegate
        m_videoOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
        [m_videoOutput setSampleBufferDelegate:self queue:m_myQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        m_videoOutput.videoSettings = setcapSettings;
        [_session addOutput:m_videoOutput];
        
        // start capture and a preview layer
        _session.sessionPreset = AVCaptureSessionPresetLow;
        _preview = [[AVCaptureVideoPreviewLayer layerWithSession:_session] retain];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

-(void)dealloc
{
    if (_session)
        [_session release];
    if (m_serverManager)
        [m_serverManager release];
    [self ReleaseCodec];
    [_preview release];
    [m_myQueue release];
    [super dealloc];
}

#pragma Video&Audio Capture
- (void) startup:(AVCaptureDevicePosition)cameraType
{
    while(true)
    {
        if ([m_serverManager Run])
            break;
        else
            sleep(2);
    }
        
    m_audioBufferSize = 0;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == cameraType)
        {
            if (dev)
                [dev release];
            dev = [device retain];
            break;
        }
    }
    
    videoInput = [[AVCaptureDeviceInput deviceInputWithDevice:dev error:nil] retain];
    [_session addInput:videoInput];
    [_session startRunning];
    NSLog(@"%@", [self getURL]);
}

- (void) shutdown
{
    NSLog(@"shutting down server");
    if (videoInput)
    {
        [_session removeInput:videoInput];
        [videoInput release];
    }
    if (_session)
    {
        if (_session.isRunning)
            [_session stopRunning];
    }
    if (m_serverManager)
    {
        if (m_serverManager->m_bRunning)
            [m_serverManager End];
    }
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // pass frame to encoder
    if (!CMSampleBufferDataIsReady(sampleBuffer) || !m_serverManager)
        return;
    if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]])
    {
        if (!m_vContext)
            return;
        
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        int width = CVPixelBufferGetWidth(pixelBuffer);
        int height = CVPixelBufferGetHeight(pixelBuffer);
        unsigned char *rawPixelBase = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        AVFrame *pSrcFrame = avcodec_alloc_frame();
        avpicture_fill((AVPicture*)pSrcFrame, rawPixelBase, AV_PIX_FMT_BGRA, width, height);
        
        AVFrame *pDstFrame = avcodec_alloc_frame();
        avpicture_fill((AVPicture*)pDstFrame, m_pYUBBuffer, AV_PIX_FMT_YUV420P, m_vContext->width, m_vContext->height);
        
        //perform the conversion
        sws_scale(m_vConvContext, pSrcFrame->data, pSrcFrame->linesize, 0, m_vContext->height, pDstFrame->data, pDstFrame->linesize);
        
        //Encode
        AVPacket* packet = new AVPacket();
        av_init_packet(packet);
        packet->size = 0;
        packet->data = NULL;
        int nSuccessed;
        if (avcodec_encode_video2(m_vContext, packet, pDstFrame, &nSuccessed) == 0 && nSuccessed == 1)
        {
            int length = packet->size;
            uint8_t* buffer = packet->data;
            while (length > 0)
            {
                if (buffer[0] == 0 && buffer[1] == 0 && buffer[2] == 0 && buffer[3] == 1)
                {
                    buffer += 4;
                    length -= 4;
                }
                else if (buffer[0] == 0 && buffer[1] == 0 && buffer[2] == 1)
                {
                    buffer += 3;
                    length -= 3;
                }
                
                uint32_t size = GetNALSize( buffer, length );
                AVPacket* nalPacket = new AVPacket();
                av_init_packet( nalPacket );
                nalPacket->size = size;
                nalPacket->data = (uint8_t*)malloc(size);
                memcpy(nalPacket->data, buffer, size);
                [m_serverManager AddVideo:nalPacket];
                free(nalPacket->data);
                nalPacket->data = NULL;
                av_free_packet( nalPacket );
                delete nalPacket;
                
                length -= size;
                buffer += size;
            }
        }
        av_free_packet(packet);
        delete packet;
        
        av_free(pSrcFrame);
        av_free(pDstFrame);
    }
    else
    {
        if (!m_aContext)
            return;
        
        CMItemCount numSamples = CMSampleBufferGetNumSamples(sampleBuffer);
        NSUInteger channelIndex = 0;
        CMBlockBufferRef audioBlockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        size_t audioBlockBufferOffset = (channelIndex * numSamples * sizeof(SInt16));
        size_t lengthAtOffset = 0;
        size_t totalLength = 0;
        SInt16 *samples = NULL;
        CMBlockBufferGetDataPointer(audioBlockBuffer, audioBlockBufferOffset, &lengthAtOffset, &totalLength, (char **)(&samples));
        
        if (m_audioBufferSize > m_aContext->frame_size * 10)
            return;
        
        memcpy(m_audioBuffer + m_audioBufferSize, samples,totalLength);
        m_audioBufferSize += totalLength;
        
        while(m_audioBufferSize > m_aContext->frame_size * 2)
        {
            int nSamples = m_aContext->frame_size;
            AVFrame* srcFrame = av_frame_alloc();
            srcFrame->nb_samples = nSamples;
            avcodec_fill_audio_frame( srcFrame, 1, AV_SAMPLE_FMT_S16, (const uint8_t*)m_audioBuffer, m_aContext->frame_size * 2, 1 );
            int out_buf_len = av_samples_get_buffer_size( NULL, AUDIO_CHANNELS, nSamples, m_aContext->sample_fmt, 1 );
            
            uint8_t* outBuffer = (uint8_t*)malloc(out_buf_len);
            AVFrame* dstFrame = av_frame_alloc();
            dstFrame->nb_samples = nSamples;
            avcodec_fill_audio_frame( dstFrame, AUDIO_CHANNELS, m_aContext->sample_fmt, (const uint8_t*)outBuffer, out_buf_len, 1 );
            swr_convert( m_aConvContext, (uint8_t**)&dstFrame->data, nSamples, (const uint8_t**)&srcFrame->data, nSamples );
            
            AVPacket* packet = new AVPacket;
            av_init_packet( packet );
            packet->size = 0;
            packet->data = NULL;
            int nSucceded;
            if (avcodec_encode_audio2( m_aContext, packet, dstFrame, &nSucceded) == 0 && nSucceded == 1)
                [m_serverManager AddAudio:packet];
            av_free_packet( packet );
            delete packet;
            
            av_frame_free(&srcFrame);
            av_frame_free(&dstFrame);
            delete srcFrame;
            delete dstFrame;
            free(outBuffer);
            memmove(m_audioBuffer, m_audioBuffer + m_aContext->frame_size * 2, m_audioBufferSize - m_aContext->frame_size * 2);
            m_audioBufferSize -= m_aContext->frame_size * 2;
        }
    }
}

-(void)InitCodec
{
    m_captureWidth = 192;
    m_captureHeight = 144;
    
    av_register_all();
    avcodec_register_all();
    
    // Video codec
    AVCodec* vCodec =avcodec_find_encoder(CODEC_ID_H264);
    
    if (!vCodec) {
        fprintf(stderr, "codec not found\n");
        exit(1);
    }
    
    /// codec context
    m_vContext= avcodec_alloc_context3(vCodec);
    avcodec_get_context_defaults3(m_vContext, vCodec);
    
    m_vContext->pix_fmt = PIX_FMT_YUV420P;
    m_vContext->time_base.num = 1;
    m_vContext->time_base.den = 30;
    m_vContext->width = 480;
    m_vContext->height = 320;
    m_vContext->bit_rate = VIDEO_BITRATE;
    m_vContext->bit_rate_tolerance = 0;
    m_vContext->rc_max_rate = VIDEO_BITRATE;
    m_vContext->rc_min_rate = VIDEO_BITRATE;
    m_vContext->rc_buffer_size = 1835008;
    m_vContext->gop_size = 40;
    m_vContext->max_b_frames = 0;
    m_vContext->delay = 0;
    m_vContext->b_frame_strategy = 1;
    m_vContext->coder_type = 1;
    m_vContext->me_cmp = FF_CMP_CHROMA;
    m_vContext->me_range = 16;
    m_vContext->qmin = 10;
    m_vContext->qmax = 30;
    m_vContext->scenechange_threshold = 40;
    m_vContext->flags |= CODEC_FLAG_LOOP_FILTER;
    m_vContext->me_method = ME_HEX;
    m_vContext->me_subpel_quality = 5;
    m_vContext->i_quant_factor = 0.71f;
    m_vContext->qcompress = 0.6f;
    m_vContext->max_qdiff = 4;

    AVDictionary* vOptions = NULL;
    av_dict_set( &vOptions, "tune", "zerolatency", 0 );
    if (avcodec_open2(m_vContext, vCodec, &vOptions) < 0) {
        fprintf(stderr, "could not open codec\n");
        exit(1);
    }
    
    AVCodec* vCodec1 =avcodec_find_encoder(CODEC_ID_H264);
    if (!vCodec1) {
        fprintf(stderr, "codec not found\n");
        exit(1);
    }
    
    m_pYUBBuffer = new u_int8_t[m_vContext->width * m_vContext->height * 3];
    m_vConvContext = sws_getContext(m_captureWidth, m_captureHeight,
                                    AV_PIX_FMT_BGRA,
                                    m_vContext->width, m_vContext->height,
                                    AV_PIX_FMT_YUV420P,
                                    SWS_FAST_BILINEAR, NULL, NULL, NULL);
    
    // Audio Codec
	m_aConvContext = NULL;
	m_aContext = NULL;
    
	do
	{
		AVCodec* pACodec = avcodec_find_encoder( AV_CODEC_ID_AAC );
		if (pACodec == NULL)
			break;
        
		m_aContext = avcodec_alloc_context3( pACodec );
		if (m_aContext == NULL)
			break;
        
		m_aContext->sample_rate = AUDIO_SAMPLERATE;
		m_aContext->channels = AUDIO_CHANNELS;
		m_aContext->sample_fmt = pACodec->sample_fmts[0];
		m_aContext->bit_rate = AUDIO_BITRATE;
        
        AVDictionary* aOptions = NULL;
        av_dict_set( &aOptions, "strict", "experimental", 0 );
		if (avcodec_open2( m_aContext, pACodec, &aOptions ) < 0)
			break;
        
		m_aConvContext = swr_alloc();
		swr_alloc_set_opts(m_aConvContext,
                                        AV_CH_LAYOUT_MONO,
                                        m_aContext->sample_fmt,
                                        m_aContext->sample_rate,
                                        AV_CH_LAYOUT_MONO,
                                        AV_SAMPLE_FMT_S16,
                                        44100,
                                        0, NULL );
		if (m_aConvContext == NULL)
			break;
        
		if (swr_init( m_aConvContext ) < 0)
			break;
        
	} while (false);
    
    m_audioBuffer = new uint8_t[m_aContext->frame_size * 10];
    m_audioBufferSize = 0;
}

-(void)ReleaseCodec
{
    avcodec_close(m_vContext);
    av_free(m_vContext);
    avcodec_close(m_aContext);
    av_free(m_aContext);
    delete[] m_audioBuffer;
}

- (NSString*) getURL
{
    if (m_serverManager)
        return [m_serverManager GetServerUrl];
    else
        return nil;
}

- (AVCaptureVideoPreviewLayer*) getPreviewLayer
{
    return _preview;
}
@end
