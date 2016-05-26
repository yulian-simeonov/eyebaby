//
//  ffmpeg_utils.c
//

#include "ffmpeg_utils.h"

const char* FFMPEG_GetErrorName(int nCode)
{
    switch (nCode)
    {
        case AVERROR_BSF_NOT_FOUND: return "AVERROR_BSF_NOT_FOUND";
        case AVERROR_BUG: return "AVERROR_BUG";
        case AVERROR_DECODER_NOT_FOUND: return "AVERROR_DECODER_NOT_FOUND";
        case AVERROR_DEMUXER_NOT_FOUND: return "AVERROR_DEMUXER_NOT_FOUND";
        case AVERROR_ENCODER_NOT_FOUND: return "AVERROR_ENCODER_NOT_FOUND";
        case AVERROR_EOF: return "AVERROR_EOF";
        case AVERROR_EXIT: return "AVERROR_EXIT";
        case AVERROR_FILTER_NOT_FOUND: return "AVERROR_FILTER_NOT_FOUND";
        case AVERROR_INVALIDDATA: return "AVERROR_INVALIDDATA";
        case AVERROR_MUXER_NOT_FOUND: return "AVERROR_MUXER_NOT_FOUND";
        case AVERROR_OPTION_NOT_FOUND: return "AVERROR_OPTION_NOT_FOUND";
        case AVERROR_PATCHWELCOME: return "AVERROR_PATCHWELCOME";
        case AVERROR_PROTOCOL_NOT_FOUND: return "AVERROR_PROTOCOL_NOT_FOUND"; 
        case AVERROR_STREAM_NOT_FOUND: return "AVERROR_STREAM_NOT_FOUND";
        case AVERROR_BUG2: return "AVERROR_BUG2";
        case AVERROR_UNKNOWN: return "AVERROR_UNKNOWN";
        default: return "Unknown";
    }
}

//
// FFMPEG_PacketAlloc()
// ====================
//
AVPacket* FFMPEG_PacketAlloc(void)
{
    AVPacket* pPacket;
    
    pPacket = (AVPacket*) av_mallocz(sizeof(AVPacket));
    
    return pPacket;
}

//
// FFMPEG_PacketFree()
// ===================
//
void FFMPEG_PacketFree(AVPacket* pPacket)
{
    av_free_packet(pPacket);
    av_free(pPacket);
}
