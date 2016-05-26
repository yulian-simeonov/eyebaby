//
//  Orantek.h
//

#ifndef Orantek_h
#define Orantek_h

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>

//------------------------------------------------------------------------------

// String length maxima...
#define ORANTEK_WPA_PASSWORD_MAX        64
#define ORANTEK_IDENTITY_NAME_MAX       30
#define ORANTEK_IDENTITY_CONTACT_MAX    50
#define ORANTEK_IDENTITY_LOCATION_MAX   50

//------------------------------------------------------------------------------

#define ORANTEK_PORT_SEARCH         33360

#define ORANTEK_MAGIC               0x01010000
#define ORANTEK_PKTYPE_SEARCH       0x0001
#define ORANTEK_PKTYPE_RESPONSE     0x0081

#define ORANTEK_STR_CAMERA_MODEL    0x0085
#define ORANTEK_STR_MAC_ADDRESS     0x0087
#define ORANTEK_STR_LOCATION        0x0088
#define ORANTEK_STR_NAME            0x0089
#define ORANTEK_STR_IP_ADDRESS      0x0101
#define ORANTEK_STR_PORT            0x008A

//
// ORANTEK_HEADER
// ==============
// UDP datagram header.
//
struct ORANTEK_HEADER
{
    uint32_t    magic;
    uint16_t    type;
    uint16_t    size;
    char        mac_address[6];
    char        reserved[18];     // Not sure what this is supposed to be other than padding.
};

//------------------------------------------------------------------------------

//
// ORANTEK_SYMBOL_TABLE
// ====================
//
struct ORANTEK_SYMBOL_TABLE
{
    int             identifier;
    const char*     codeName;
    const char*     displayName;
};

//
// ORANTEK_STREAM_INFO
// ===================
//
struct ORANTEK_STREAM_INFO
{
    const char*     codec_name;
    const char*     title;
    const char*     protocol;
    const char*     stream1;
    const char*     stream2;
    const char*     stream3;
    const char*     force_format;
};

//------------------------------------------------------------------------------

enum
{
    OT_WIFI_MODE_ADHOC,
    OT_WIFI_MODE_INFRASTRUCTURE
};

enum
{
    OT_WIFI_SECURITY_OFF,
    OT_WIFI_SECURITY_WEP64,
    OT_WIFI_SECURITY_WEP128,
    OT_WIFI_SECURITY_WPA_PSK,
    OT_WIFI_SECURITY_WPA2_PSK
};

enum
{
    OT_WIFI_ENCRYPTION_NONE,
    OT_WIFI_ENCRYPTION_TKIP,
#ifndef NO_DEPRECATED
    OT_WIFI_ENCRYPTION_TKIP_AES,
#endif
    OT_WIFI_ENCRYPTION_AES
};

enum
{
    OT_WIFI_AUTHTYPE_AUTO,
    OT_WIFI_AUTHTYPE_OPEN,
    OT_WIFI_AUTHTYPE_SHARED
};

enum
{
    OT_WIFI_KEYTYPE_ASCII,
    OT_WIFI_KEYTYPE_HEX
};

#define OT_STR_WIFI_MODE_ADHOC              "Ad Hoc"
#define OT_STR_WIFI_MODE_INFRASTRUCTURE     "Infrastructure"

#define OT_STR_WIFI_SECURITY_OFF            "Off"
#define OT_STR_WIFI_SECURITY_WEP64          "WEP 64-bit"
#define OT_STR_WIFI_SECURITY_WEP128         "WEP 128-bit"
#define OT_STR_WIFI_SECURITY_WPA_PSK        "WPA-PSK"
#define OT_STR_WIFI_SECURITY_WPA2_PSK       "WPA2-PSK"

#define OT_STR_WIFI_ENCRYPTION_TKIP         "TKIP"
#define OT_STR_WIFI_ENCRYPTION_AES          "AES"
#ifndef NO_DEPRECATED
#define OT_STR_WIFI_ENCRYPTION_TKIP_AES     "TKIP+AES"
#endif
#define OT_STR_WIFI_ENCRYPTION_NONE         "None"

#define OT_STR_WIFI_AUTHTYPE_AUTO           "Auto"
#define OT_STR_WIFI_AUTHTYPE_OPEN           "Open System"
#define OT_STR_WIFI_AUTHTYPE_SHARED         "Shared Key"

#define OT_STR_WIFI_KEYTYPE_ASCII           "ASCII"
#define OT_STR_WIFI_KEYTYPE_HEX             "Hexadecimal"

//------------------------------------------------------------------------------

#ifdef __cplusplus
extern "C" {
#endif
        
    const char* Orantek_GetString(const char*,uint16_t*,uint16_t*,const char**);
    
    extern const struct ORANTEK_SYMBOL_TABLE OrantekWifiModes[];
    extern const struct ORANTEK_SYMBOL_TABLE OrantekWifiSecurity[];
    extern const struct ORANTEK_SYMBOL_TABLE OrantekWifiEncryption[];
    extern const struct ORANTEK_SYMBOL_TABLE OrantekWifiAuthType[];
    extern const struct ORANTEK_SYMBOL_TABLE OrantekWifiKeyType[];

    int Orantek_IdentifierForCodeName(const struct ORANTEK_SYMBOL_TABLE* pTable, const char* pStr);
    const char* Orantek_CodeNameForIdentifier(const struct ORANTEK_SYMBOL_TABLE* pTable, int identifier);
    const char* Orantek_DisplayNameForIdentifier(const struct ORANTEK_SYMBOL_TABLE* pTable, int identifier);
    
    int Orantek_IsValidSecurity(int);
    int Orantek_IsValidEncryption(int);
    
    const struct ORANTEK_STREAM_INFO* Orantek_GetStreamInfoForName(const char*);
    const struct ORANTEK_STREAM_INFO* Orantek_GetStreamInfoForIndex(int);
    int Orantek_GetNumStreamTypes(void);
    
    
    void Orantek_CreateStreamURI(
                                 const struct ORANTEK_STREAM_INFO* pStreamInfo,
                                 char* buffer,
                                 size_t len,
                                 const char* username,  /* URL encode first!!! */
                                 const char* password,  /* URL encode first!!! */
                                 const char* ip_address,
                                 int nStream);
#ifdef __cplusplus
}
#endif
    
#endif
