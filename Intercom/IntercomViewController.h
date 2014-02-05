//
//  ViewController.h
//  Intercom
//
//  Created by John La Barge on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import "CoreAudioHelpers.h"

@interface IntercomViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,AVAudioSessionDelegate>
{
    UIPickerView * _destinationPicker;
    IBOutlet UIButton * _talkButtonn;
    NSArray * _destinations;
    UIView * _airplayContainer; 
    AVAudioSession * _audioSession;
    AVAudioPlayer * _audioPlayer;
    AudioQueueRef _outQ;
    AudioQueueRef _inQ;
    BOOL _outReady;
    

}

@property (strong, nonatomic) IBOutlet UIPickerView *destinationPicker; 
@property (strong, nonatomic) IBOutlet UIButton *talkButton;
@property (readonly, nonatomic) NSArray *destinations;
@property (strong, nonatomic) IBOutlet UIView *airplayContainer;
@property (strong, nonatomic) AVAudioSession * audio;
@property (strong, nonatomic) AVAudioPlayer * audioPlayer;
@property (assign, nonatomic) AudioQueueRef outQ;
@property (assign, nonatomic) AudioQueueRef inQ;
@property (assign, nonatomic) AudioQueueBufferRef currentInBuffer;
@property (assign, nonatomic) BOOL outReady; 
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSString*)pickerView:(UIPickerView *) picker titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (IBAction)startSending:(id)sender;
- (IBAction)stopSending:(id)sennder;

@end




