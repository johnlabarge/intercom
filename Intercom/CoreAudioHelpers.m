//
//  CoreAudioHelpers.c
//  Intercom
//
//  Created by John La Barge on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "CoreAudioHelpers.h"

AudioStreamBasicDescription * get44K2ChPCMAudioFormat() { 
    static AudioStreamBasicDescription * format;
    if (format == NULL) {
        format = malloc(sizeof(AudioStreamBasicDescription));
        format->mFormatID = kAudioFormatLinearPCM;        // 2
        format->mSampleRate = 44100.0;                    // 3
        format->mChannelsPerFrame = 2;                    // 4
        format->mBitsPerChannel = 16;                     // 5
        format->mBytesPerPacket =                         // 6
        format->mBytesPerFrame =
        format->mChannelsPerFrame * sizeof (SInt16);
        format->mFramesPerPacket = 1;                     // 7
        
        format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian
        | kLinearPCMFormatFlagIsSignedInteger
        | kLinearPCMFormatFlagIsPacked;
        
    }
    return format;
}

AudioStreamBasicDescription * get8K1ChPCMAudioFormat() { 
    static AudioStreamBasicDescription * format;
    if (format == NULL) {
        format = malloc(sizeof(AudioStreamBasicDescription));
        format->mFormatID = kAudioFormatLinearPCM;        // 2
        format->mSampleRate = 8000.0;                    // 4
        format->mBitsPerChannel = 16;                     // 5
        format->mBytesPerPacket =  2;                        // 6
        format->mBytesPerFrame = 2;
        format->mChannelsPerFrame =1;
        format->mFramesPerPacket = 1;
        format->mReserved=0;
        
        format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian
        | kLinearPCMFormatFlagIsSignedInteger
        | kLinearPCMFormatFlagIsPacked;
        
    }
    return format;
}

UInt32 outBufferSize(AudioStreamBasicDescription* format, int seconds) { 
    /*static const int maxBufferSize = 0x50000;
    Float64 numBytesForTime =
    format->mSampleRate *2 * seconds; 
    return (numBytesForTime < maxBufferSize ?
            numBytesForTime : maxBufferSize);              
    */
    return 12000; 
}


void copyAQBuffer (AudioQueueBufferRef from, AudioQueueBufferRef to) { 
    to->mAudioDataByteSize      = from->mAudioDataByteSize;
    to->mPacketDescriptionCount = from->mPacketDescriptionCount;
    to->mUserData               = from ->mUserData;
    
    memcpy(to->mPacketDescriptions,
           from->mPacketDescriptions, 
           sizeof(from->mPacketDescriptionCount));
    memcpy(to->mAudioData,
           from->mAudioData, 
           from->mAudioDataByteSize);

  
}

void logOsStatus(NSString * prefix, OSStatus status)
{
    char statusString[5]; 
    memcpy(&statusString[0], &status, 4);
    statusString[4] = 0;
    NSLog(@"%@ os status code: %ld, string: %s", prefix, status, statusString);
}