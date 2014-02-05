//
//  ViewController.m
//  Intercom
//
//  Created by John La Barge on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IntercomViewController.h"
UInt32 Int32Size = 32;
void GenericOutputCallback (
                            void                 *inUserData,
                            AudioQueueRef        inAQ,
                            AudioQueueBufferRef  inBuffer
                            );

static void GenericInputCallback (
                           void                                *inUserData,
                           AudioQueueRef                       inAQ,
                           AudioQueueBufferRef                 inBuffer,
                           const AudioTimeStamp                *inStartTime,
                           UInt32                              inNumberPacketDescriptions,
                           const AudioStreamPacketDescription  *inPacketDescs
                           );

void makeSilent(AudioQueueBufferRef buffer); 


@interface IntercomViewController ()
{
    MPVolumeView *_volumeView;
    AudioQueueBufferRef _inBuffers[100];
    AudioQueueBufferRef _outBuffers[100];
    int _numBuffers;
    AudioQueueBufferRef _currentInBuffer;
    int _currentOutputBufferIndex;
    AudioStreamBasicDescription * _audioFormat;
}
- (BOOL) playBackQueueIsRunning;
- (void) primePlayBack:(AudioQueueBufferRef)buffer;
@end


@implementation IntercomViewController 

@synthesize destinations=_destinations;
@synthesize destinationPicker=_destinationPicker;
@synthesize talkButton=_talkButton;
@synthesize airplayContainer=_airplayContainer;
@synthesize audio=_audioSession;
@synthesize audioPlayer = _audioPlayer;
@synthesize inQ=_inQ;
@synthesize outQ=_outQ;
@synthesize currentInBuffer=_currentInBuffer;

- (void)viewDidLoad
{
    
    [super viewDidLoad]; 
 //   [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    self.airplayContainer.backgroundColor = [UIColor clearColor];
  /*  _volumeView = [ [MPVolumeView alloc] initWithFrame:[_airplayContainer bounds]];
    [_volumeView setShowsVolumeSlider:YES];
    [_volumeView sizeToFit];
    [self.airplayContainer addSubview:_volumeView];
    _audioSession= [AVAudioSession sharedInstance];
    */[self.audio setDelegate:self];
    _numBuffers = 4;
    _currentOutputBufferIndex =0; 
    _audioFormat = get8K1ChPCMAudioFormat();
    OSStatus status = AudioQueueNewInput (
                                          _audioFormat,
                                          GenericInputCallback,
                                          (__bridge void *) self,
                                          NULL,
                                          NULL,
                                          0,
                                          &_inQ
                                          );
    logOsStatus(@"new input:", status);
    
   /*AudioQueueAddPropertyListener (inAQ,AudioQueuePropertyID inID, AudioQueuePropertyListenerProc inProc,
                                  (__bridge void *) self);
    */
    
    
                                            
   
    status = AudioQueueNewOutput (
                                  _audioFormat,
                                  GenericOutputCallback,
                                  (__bridge void *) self,
                                  NULL,
                                  NULL,
                                  0,
                                  &_outQ
                                  );
    
                logOsStatus(@" New Output:",status);
    
   
    
            
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(BOOL) playBackQueueIsRunning 
{
    UInt32 state;
    AudioQueueGetProperty(self.outQ, kAudioQueueProperty_IsRunning, &state, &Int32Size);
    return state != 0;
}
    



- (IBAction) startSending:(id)sender
{
    
    NSError *theError= nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&theError];
 // 1
    
    if (theError) { 
        NSLog(@" Error initializing Audio Session: %@",[theError localizedDescription]);
    }
  
    
    for (int i=0; i < _numBuffers; i++) { 
        
        AudioQueueAllocateBuffer (                      
                                  _inQ,                             
                                  outBufferSize(_audioFormat,1),                              
                                  &_inBuffers[i]                          
                                  ); 
        
        AudioQueueEnqueueBuffer (                        
                                 _inQ,                             
                                 (_inBuffers[i]),                          
                                 0,                                           
                                 NULL                                         
                                 );
    }
    
    for (int i = 0; i < _numBuffers; ++i) {
        AudioQueueAllocateBuffer(_outQ, outBufferSize(_audioFormat,1),  &_outBuffers[i]);
        
    } 
    
    for (int i=0; i < _numBuffers; ++i) {  
        makeSilent(_outBuffers[i]);
        AudioQueueEnqueueBuffer(_outQ,_outBuffers[i],0,NULL);
    }
    
    Float32 gain = 1.0;                                       // 1
    // Optionally, allow user to override gain setting here
    AudioQueueSetParameter (                                  // 2
                            self.outQ,                                        // 3
                            kAudioQueueParam_Volume,                              // 4
                            gain                                                  // 5
                            );

    
    OSStatus recStatus = AudioQueueStart(self.inQ, NULL);
    OSStatus playStatus = AudioQueueStart(self.outQ,NULL);
    
    
    
    UInt32 recording;
    UInt32 recordData = sizeof(recording);
    AudioQueueGetProperty(
                          self.inQ,
                          kAudioQueueProperty_IsRunning,
                          &recording,&recordData );
   
    
    NSLog(@"status after start=%d recording=%d\n playStatus=%d",recStatus, recording, playStatus);
}
- (IBAction)stopSending:(id)sender 
{   
    AudioQueueStop(_inQ,true);
    AudioQueueStop(_outQ, true);
    _currentOutputBufferIndex=0;
    _currentInBuffer = nil;

}
    
    
/*
 * Picker support
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.destinations.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView 
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"selected something");
}

- (NSString*)pickerView:(UIPickerView *) picker titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.destinations objectAtIndex:row];
}
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
    NSLog(@"Input is available...");
}
-(void) primePlayBack:(AudioQueueBufferRef)buffer
{
    NSLog(@"Priming playback...");
    copyAQBuffer(buffer,_outBuffers[_currentOutputBufferIndex]); 
    
    OSStatus status = AudioQueueEnqueueBuffer (                      
                             self.outQ,                         
                             _outBuffers[_currentOutputBufferIndex],                                  
                             0,                  
                             0);
    logOsStatus(@"\n\n#engueue output buffer:",status);
    _currentOutputBufferIndex++;
    if (_currentOutputBufferIndex == (_numBuffers-1)) {
        NSLog(@"Starting playback queue");
        AudioQueueStart(self.outQ, NULL);
    }     
      
}
@end

void GenericOutputCallback (
                                 void                 *inUserData,
                                 AudioQueueRef        inAQ,
                                 AudioQueueBufferRef  inBuffer
                                 ) 
{
    NSLog(@"outputqueue callback sending output...");
    IntercomViewController * intercomVC = (__bridge IntercomViewController *) inUserData;
    if (intercomVC.currentInBuffer != nil) { 
        
        copyAQBuffer(intercomVC.currentInBuffer,inBuffer);
        NSLog(@"enqueing current buffer size :%ld", inBuffer->mAudioDataByteSize);
        AudioQueueEnqueueBuffer(intercomVC.inQ, intercomVC.currentInBuffer, 0, NULL);
        intercomVC.currentInBuffer = nil;


    } else { 
        makeSilent(inBuffer);
        
        NSLog(@"nothing in currentInBuffer...");
    }
    
    OSStatus status = AudioQueueEnqueueBuffer (                      
                                               intercomVC.outQ,                        
                                               inBuffer,                               
                                               0,                  
                                               0);
    logOsStatus(@"\n\n#Enqueue Output Buffer :", status);
    
    
    
}
void makeSilent(AudioQueueBufferRef buffer) 
{
    NSLog(@" out buffer capacity=%ld",buffer->mAudioDataBytesCapacity);
    for (int i=0; i < buffer->mAudioDataBytesCapacity; i++) {
        buffer->mAudioDataByteSize = buffer->mAudioDataBytesCapacity;
        UInt8 * samples = (UInt8 *) buffer->mAudioData;
        samples[i]=0;
    }
}
static void GenericInputCallback (
                                void                                *inUserData,
                                AudioQueueRef                       inAQ,
                                AudioQueueBufferRef                 inBuffer,
                                const AudioTimeStamp                *inStartTime,
                                UInt32                              inNumberPacketDescriptions,
                                const AudioStreamPacketDescription  *inPacketDescs
                                )
{
    
    IntercomViewController * intercomController = (__bridge IntercomViewController *) inUserData; 
    NSLog(@"%ld bytes of sound input received..", inBuffer->mAudioDataByteSize);
     intercomController.currentInBuffer = inBuffer;

    if ( [intercomController playBackQueueIsRunning] ) {
        NSLog(@"Playback Queue Already running... updating current input buffer..");
        if (intercomController.currentInBuffer == inBuffer) { 
            NSLog(@"OUTPUT BUFFER OVERRUN!!!"); 
        }
        NSLog(@"Setting current inBuffe...");
       

    }    
 
        
  /*  else { // if the output queue isn't started we need to just fill one of it's buffers until we're out
        NSLog(@"Playback Queue not running, sending buffer to prime playback."); 
        [intercomController primePlayBack:inBuffer];
    }*/

}








