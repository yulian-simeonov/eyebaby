
#include "MyMP3AudioFilter.h"

MyMP3AudioFilter* MyMP3AudioFilter::createNew(UsageEnvironment& env, FramedSource* audioSource)
{
	return new MyMP3AudioFilter( env, audioSource );
}

MyMP3AudioFilter::MyMP3AudioFilter(UsageEnvironment& env, FramedSource* audioSource)
	: FramedFilter( env, audioSource )
{
	m_pPCMSource = audioSource;
	m_fInit = false;

	m_pBuffer = NULL;
	m_nLength = 0;

	m_fInit = false;

	m_pConvContext = NULL;
	m_pCodecContext = NULL;

	do 
	{
		AVCodec* pACodec = avcodec_find_encoder( AV_CODEC_ID_MP2 );
		if (pACodec == NULL)
			break;

		m_pCodecContext = avcodec_alloc_context3( pACodec );
		if (m_pCodecContext == NULL)
			break;

		m_pCodecContext->sample_rate = AUDIO_SAMPLERATE;
		m_pCodecContext->channels = AUDIO_CHANNELS;
		m_pCodecContext->sample_fmt = pACodec->sample_fmts[0];
		m_pCodecContext->bit_rate = AUDIO_BITRATE;

		if (avcodec_open2( m_pCodecContext, pACodec, NULL ) < 0)
			break;

		m_pConvContext = swr_alloc();
		m_pConvContext = swr_alloc_set_opts( m_pConvContext,
			AV_CH_LAYOUT_STEREO,
			m_pCodecContext->sample_fmt,
			AUDIO_SAMPLERATE,
			AV_CH_LAYOUT_MONO,
			AV_SAMPLE_FMT_S16,
			44100,
			0, NULL );
		if (m_pConvContext == NULL)
			break;

		if (swr_init( m_pConvContext ) < 0)
			break;

		m_fInit = true;
	} while (false);
}

MyMP3AudioFilter::~MyMP3AudioFilter(void)
{
	if (m_pConvContext != NULL)
	{
		swr_free( &m_pConvContext );
		m_pConvContext = NULL;
	}

	if (m_pCodecContext != NULL)
	{
		avcodec_close( m_pCodecContext );
		av_free( m_pCodecContext );
		m_pCodecContext = NULL;
	}

	if (m_pBuffer != NULL)
	{
		delete[] m_pBuffer;
		m_pBuffer = NULL;
	}

	m_fInit = false;
}

void MyMP3AudioFilter::doGetNextFrame()
{
	unsigned int bytes_to_read = m_pCodecContext->frame_size * 4;

	if (bytes_to_read > m_nLength) {
		delete[] m_pBuffer; 
		m_pBuffer = new unsigned char[bytes_to_read];
		m_nLength = bytes_to_read;
	}

	// be sure to give a clean buffer where to store the
	memset( m_pBuffer, 0, m_nLength );

	// Arrange to read samples into the input buffer:
	m_pPCMSource->getNextFrame( m_pBuffer,
		bytes_to_read,
		afterGettingFrame,
		this,
		FramedSource::handleClosure, 
		this );
}

void MyMP3AudioFilter::afterGettingFrame(void* clientData,
	unsigned frameSize,
	unsigned numTruncatedBytes,
	struct timeval presentationTime,
	unsigned durationInMicroseconds) 
{
	MyMP3AudioFilter* pThis = (MyMP3AudioFilter*)clientData;
	pThis->afterGettingFrame1( frameSize,
		numTruncatedBytes,
		presentationTime,
		durationInMicroseconds );
}

void MyMP3AudioFilter::afterGettingFrame1(unsigned frameSize,
	unsigned numTruncatedBytes,
	struct timeval presentationTime,
	unsigned durationInMicroseconds)
{
	// encode the buffer
	int nSamples = m_pCodecContext->frame_size;

	AVFrame* srcFrame = av_frame_alloc();
	srcFrame->nb_samples = nSamples;
	avcodec_fill_audio_frame( srcFrame, 1, AV_SAMPLE_FMT_S16, (const uint8_t*)m_pBuffer, m_nLength, 1 );

	int out_buf_len = av_samples_get_buffer_size( NULL, AUDIO_CHANNELS, nSamples, m_pCodecContext->sample_fmt, 1 );
	char* out_buf = new char[out_buf_len];

	AVFrame* dstFrame = av_frame_alloc();
	dstFrame->nb_samples = nSamples;
	avcodec_fill_audio_frame( dstFrame, AUDIO_CHANNELS, m_pCodecContext->sample_fmt, (const uint8_t*)out_buf, out_buf_len, 1 );
	swr_convert( m_pConvContext, (uint8_t**)&dstFrame->data, nSamples, (const uint8_t**)&srcFrame->data, nSamples );

	AVPacket* packet = new AVPacket;
	av_init_packet( packet );
	packet->size = 0;
	packet->data = NULL;
	int nSucceded;
	if (avcodec_encode_audio2( m_pCodecContext, packet, dstFrame, &nSucceded) == 0 && nSucceded == 1)
	{
		fFrameSize = packet->size;
		memcpy( fTo, packet->data, packet->size );
	}
	else
	{
		frameSize = 0;
	}

	av_free_packet( packet );
	delete packet;

	av_frame_free( &srcFrame );
	av_frame_free( &dstFrame );

	// Complete delivery to the client:
	fNumTruncatedBytes = numTruncatedBytes;
	fPresentationTime = presentationTime;
	fDurationInMicroseconds = durationInMicroseconds;
	afterGetting( (FramedSource*)this );
}

char const* MyMP3AudioFilter::MIMEtype() const
{
	return "audio/MPEG";
}
