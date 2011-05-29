//
//  EasyTextSniffer.h
//  EasyText
//
//  Created by Eric on 4/20/11.
//  Copyright 2011 EGFriends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface EasyTextSniffer : NSObject<UITextViewDelegate, UITextFieldDelegate>{
	UITextView *_textView;
	UITextField *_textField;
	id _delegate;
	BOOL caseInsensitive, noSound;
	BOOL enabled;
	SystemSoundID _bell;
}

@property(nonatomic, assign) BOOL caseInsensitive, noSound;
@property(readonly) BOOL enabled;

// sniffer will not retain either textview or delegate
- (void)sniffTextView:(UITextView*)tv delegate:(NSObject<UITextViewDelegate>*)dlg;
- (void)sniffTextField:(UITextField*)tf delegate:(NSObject<UITextFieldDelegate>*)dlg;
- (void)stopSniff;

- (void)tryEnable;
- (void)disable;

@end