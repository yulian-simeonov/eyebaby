//
//  main.mm
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#include "alutils.h"
#include "VideoStream.h"
#include "Config.h"

int main(int argc, char *argv[])
{    
    ALCdevice* pDevice;
    ALCcontext* pContext;
    int nResult;
    
    // Initialize OpenAL device...
    pDevice = alcOpenDevice(NULL);
    if (pDevice == NULL)
    {
        TRACE(@"Failed to initialize OpenAL device.");
        return 1;
    }
    
    // Create OpenAL context...
    pContext = alcCreateContext(pDevice, NULL);
    alcMakeContextCurrent(pContext);
    
    // Initialize FFMPEG library...
    avformat_network_init();
    av_register_all();
#ifdef DEBUG
    av_log_set_level(AV_LOG_DEBUG);
#else
    av_log_set_level(AV_LOG_QUIET);
#endif
    
    // Run application main loop...
    @autoreleasepool {
        nResult = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
    // Terminate FFMPEG library...
    avformat_network_deinit();
    
    // Terminate OpenAL...
    alcMakeContextCurrent(NULL);
    alcDestroyContext(pContext);
    alcCloseDevice(pDevice);
    
    // Done...
    TRACE(@"Application terminated normally.");
    return nResult;
}
