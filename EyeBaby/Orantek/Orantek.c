//
//  Orantek.cpp
//

#include "Orantek.h"
#include <string.h>

//
// Orantek_GetString()
// ===================
//
const char* Orantek_GetString(
                              const char*    pData,
                              uint16_t*      pnType,
                              uint16_t*      pnLength,
                              const char**   ppBase)
{
    // Get the type code...
    *pnType = ntohs(*((const uint16_t*) pData));
    
    // Get the string length...
    pData += sizeof(uint16_t);
    *pnLength = ntohs(*((const uint16_t*) pData));
    
    // Return the base of the string...
    pData += sizeof(uint16_t);
    *ppBase = pData;
    
    // Skip to next string...
    pData += *pnLength;
    
    // Done...
    return pData;      
}

//------------------------------------------------------------------------------

//
// OrantekWifiModes
// ================
//
const struct ORANTEK_SYMBOL_TABLE OrantekWifiModes[] =
{
    {OT_WIFI_MODE_ADHOC,            "ADHOC",            OT_STR_WIFI_MODE_ADHOC},
    {OT_WIFI_MODE_INFRASTRUCTURE,   "INFRA",            OT_STR_WIFI_MODE_INFRASTRUCTURE},
    {OT_WIFI_MODE_INFRASTRUCTURE,   "INFRASTRUCTURE",   OT_STR_WIFI_MODE_INFRASTRUCTURE},
    
    {0, NULL, NULL}
};

//
// OrantekWifiSecurity
// ===================
//
const struct ORANTEK_SYMBOL_TABLE OrantekWifiSecurity[] =
{
    {OT_WIFI_SECURITY_OFF,          "OFF",              OT_STR_WIFI_SECURITY_OFF},
    {OT_WIFI_SECURITY_WEP64,        "WEP64",            OT_STR_WIFI_SECURITY_WEP64},
    {OT_WIFI_SECURITY_WEP128,       "WEP128",           OT_STR_WIFI_SECURITY_WEP128},
    {OT_WIFI_SECURITY_WPA_PSK,      "WPA-PSK",          OT_STR_WIFI_SECURITY_WPA_PSK},
    {OT_WIFI_SECURITY_WPA2_PSK,     "WPA2-PSK",         OT_STR_WIFI_SECURITY_WPA2_PSK},
    
    {0, NULL, NULL}
};

//
// OrantekWifiEncryption
// =====================
//
const struct ORANTEK_SYMBOL_TABLE OrantekWifiEncryption[] =
{
    {OT_WIFI_ENCRYPTION_TKIP,       "TKIP",             OT_STR_WIFI_ENCRYPTION_TKIP},
    {OT_WIFI_ENCRYPTION_AES,        "AES",              OT_STR_WIFI_ENCRYPTION_AES},
    {OT_WIFI_ENCRYPTION_TKIP,       "TKIP+AES",         OT_STR_WIFI_ENCRYPTION_TKIP},
    {OT_WIFI_ENCRYPTION_NONE,       "NONE",             OT_STR_WIFI_ENCRYPTION_NONE},
    
    {0, NULL, NULL}
};
    
//
// OrantekWifiAuthType
// ===================
//
const struct ORANTEK_SYMBOL_TABLE OrantekWifiAuthType[] =
{
    {OT_WIFI_AUTHTYPE_AUTO,         "AUTO",             OT_STR_WIFI_AUTHTYPE_AUTO},
    {OT_WIFI_AUTHTYPE_OPEN,         "OPEN",             OT_STR_WIFI_AUTHTYPE_OPEN},
    {OT_WIFI_AUTHTYPE_SHARED,       "SHARED",           OT_STR_WIFI_AUTHTYPE_SHARED},
    
    {0, NULL, NULL}    
};

//
// OrantekWifiKeyType
// ==================
//
const struct ORANTEK_SYMBOL_TABLE OrantekWifiKeyType[] =
{
    {OT_WIFI_KEYTYPE_ASCII,         "ASCII",        OT_STR_WIFI_KEYTYPE_ASCII},
    {OT_WIFI_KEYTYPE_HEX,           "HEX",          OT_STR_WIFI_KEYTYPE_HEX},
    
    {0, NULL, NULL}    
};

//
// Orantek_IdentifierForCodeName()
// ===============================
//
int Orantek_IdentifierForCodeName(const struct ORANTEK_SYMBOL_TABLE* pTable, const char* pStr)
{
    for (; pTable->codeName != NULL; ++pTable)
    {
        if (strcasecmp(pTable->codeName, pStr) == 0)
        {
            return pTable->identifier; 
        }
    }
    
    return 0;
}

//
// Orantek_CodeNameForIdentifier()
// ===============================
//
const char* Orantek_CodeNameForIdentifier(const struct ORANTEK_SYMBOL_TABLE* pTable, int identifier)
{
    for (; pTable->codeName != NULL; ++pTable)
    {
        if (pTable->identifier == identifier)
        {
            return pTable->codeName; 
        }
    }
    
    return "";     
}

//
// Orantek_DisplayNameForIdentifier()
// ==================================
//
const char* Orantek_DisplayNameForIdentifier(const struct ORANTEK_SYMBOL_TABLE* pTable, int identifier)
{
    for (; pTable->codeName != NULL; ++pTable)
    {
        if (pTable->identifier == identifier)
        {
            return pTable->displayName; 
        }
    }
    
    return "";    
}

//
// Orantek_IsValidSecurity()
// =========================
// Returns 1 if the security mode is supported. Otherwise returns 0
//
int Orantek_IsValidSecurity(int security)
{
    switch (security)
    {
        case OT_WIFI_SECURITY_WPA_PSK:
        case OT_WIFI_SECURITY_WPA2_PSK:
            return 1;
            
        default:
            return 0;
    }
}

//
// Orantek_IsValidEncryption()
// ===========================
// Returns 1 if the encryption is supported. Otherwise returns 0.
//
int Orantek_IsValidEncryption(int encryption)
{
    switch (encryption)
    {
        case OT_WIFI_ENCRYPTION_TKIP:
        case OT_WIFI_ENCRYPTION_AES:
#ifndef NO_DEPRECATED
        case OT_WIFI_ENCRYPTION_TKIP_AES:
#endif
            return 1;
            
        default:
            return 0;
    }
}

const struct ORANTEK_STREAM_INFO OrantekStreams[] =
{
    {
        "mpeg4",
        "MPEG4",
        "rtsp",
        "live_mpeg4.sdp",
        "live_mpeg4_1.sdp",
        "live_mpeg4_1.sdp", // Stream 3 not available
        NULL
    },
 
    {
        "h264",
        "H.264",
        "rtsp",
        "live_h264.sdp",
        "live_h264_1.sdp",
        "live_h264_3gpp.sdp",
        NULL
    },
    
    {
        "3gpp",
        "Mobile 3GPP",
        "rtsp",
        "live_3gpp.sdp",
        "live_3gpp.sdp", // Stream 2 not available
        "live_3gpp.sdp", // Stream 3 not available
        NULL
    },
    
    {
        "mjpeg",
        "MJPEG",
        "http",
        "stream.jpg",
        "stream.jpg", // Stream 2 not available
        "stream.jpg", // Stream 3 not available
        "mjpeg"
    },
    
    {
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    }  
};

const struct ORANTEK_STREAM_INFO* Orantek_GetStreamInfoForName(const char* name)
{
    const struct ORANTEK_STREAM_INFO* p;
    
    for (p = OrantekStreams; p->protocol != NULL; ++p)
    {
        if (p->codec_name != NULL)
        {
            if (!strcmp(name, p->codec_name)) return p;
        }
    }
    
    return NULL;
}

//
// Orantek_GetStreamInfoForIndex()
// ===============================
//
const struct ORANTEK_STREAM_INFO* Orantek_GetStreamInfoForIndex(int nIndex)
{
    return &OrantekStreams[nIndex];
}

//
// Orantek_GetNumStreamTypes()
// ===========================
//
int Orantek_GetNumStreamTypes(void)
{
    const struct ORANTEK_STREAM_INFO* p;
    int i;
    
    for (p = OrantekStreams, i = 0; p->protocol != NULL; ++p, ++i);
    
    return i; 
}

//
// Orantek_CreateStreamURL()
// =========================
//
void Orantek_CreateStreamURI(
                             const struct ORANTEK_STREAM_INFO* pStreamInfo,
                             char* buffer,
                             size_t len,
                             const char* username,  /* URL encode first!!! */
                             const char* password,  /* URL encode first!!! */
                             const char* ip_address,
                             int nStream)
{
    const char* pStream = NULL;
    
    // Choose stream...
    if (nStream < 0) nStream = 0;
    if (nStream > 2) nStream = 2;
    switch (nStream)
    {
        case 0: pStream = pStreamInfo->stream1; break;
        case 1: pStream = pStreamInfo->stream2; break;
        case 2: pStream = pStreamInfo->stream3; break;
    }
    
    // Generate the URI...
    snprintf(
             buffer,
             len,
             "%s://%s:%s@%s/%s",
             pStreamInfo->protocol,
             username,
             password,
             ip_address,
             pStream);
}
