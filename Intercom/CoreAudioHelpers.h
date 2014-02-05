//
//  CoreAudioHelpers.h
//  Intercom
//
//  Created by John La Barge on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Intercom_CoreAudioHelpers_h
#define Intercom_CoreAudioHelpers_h
#include <stdio.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>
#include <UIKit/UIKit.h>
AudioStreamBasicDescription * get8K1ChPCMAudioFormat();
AudioStreamBasicDescription * get44K2ChPCMAudioFormat();
UInt32 outBufferSize(AudioStreamBasicDescription* format, int seconds); 
void copyAQBuffer (AudioQueueBufferRef from, AudioQueueBufferRef to);
void logOsStatus(NSString * prefix, OSStatus status);
#endif
