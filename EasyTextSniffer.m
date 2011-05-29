//
//  EasyTextSniffer.m
//  EasyText
//
//  Created by Eric on 4/20/11.
//  Copyright 2011 EGFriends. All rights reserved.
//

#import "EasyTextSniffer.h"
#include <stdio.h>
#include <time.h>

static NSString *_StoreName = @"com.egfriends.SnippetsUTI";

static NSArray* _snippets(){
	UIPasteboard *_pb = [UIPasteboard pasteboardWithName:_StoreName create:NO];
	NSMutableArray *array = [NSMutableArray array];
	NSArray *objArray = [NSKeyedUnarchiver unarchiveObjectWithData:[_pb dataForPasteboardType:_StoreName]];
	for(id obj in objArray){
		NSDictionary *dic = [obj dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"_code", @"_text", nil]];
		[array addObject:dic];
	}
	return array;
}

static NSString *_ETLocalizedString(NSString *key, NSString *defaultValue){
	return [[NSBundle mainBundle] localizedStringForKey:key value:defaultValue table:nil];
}

@implementation EasyTextSniffer

@synthesize caseInsensitive, noSound;
@synthesize enabled;

- (void)sniffTextView:(UITextView*)tv delegate:(NSObject<UITextViewDelegate>*)dlg{
	_textView = tv;
	_textView.delegate = self;
	_delegate = dlg;
}

- (void)sniffTextField:(UITextField *)tf delegate:(NSObject<UITextFieldDelegate> *)dlg{
	_textField = tf;
	_textField.delegate = self;
	_delegate = dlg;
}

- (void)stopSniff{
	_textView.delegate = _delegate;
	_textField.delegate = _delegate;
	_delegate = nil;
}

- (void)tryEnable{
	UIPasteboard *_pb = [UIPasteboard pasteboardWithName:_StoreName create:NO];
	if(nil == _pb){
		enabled = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_ETLocalizedString(@"ET_NOTFOUND", @"EasyText not found")
														message:_ETLocalizedString(@"ET_NOTFOUND_MSG", @"This feature need EasyText, it's a free app")
													   delegate:self
											  cancelButtonTitle:_ETLocalizedString(@"ET_CANCEL", @"No")
											  otherButtonTitles:_ETLocalizedString(@"ET_OK", @"Ok"), nil];
		[alert show];
		[alert release];
	}
	else
		enabled = YES;
}

- (void)disable{
	enabled = NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if(buttonIndex != [alertView cancelButtonIndex]){
		static NSString* const ETAppURL = @"http://itunes.apple.com/us/app/id433107906?mt=8";
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:ETAppURL]];
	}
}

- (void)dealloc{
	[self stopSniff];
	AudioServicesDisposeSystemSoundID(_bell);
	_bell = 0;
	[super dealloc];
}

static NSString* _dateStringForFormat(NSString*fmt){
	if([fmt length] > 100)
		return fmt;
	
	char str[255];
	time_t lt = time(NULL);
	struct tm *ptr = localtime(&lt);
	strftime(str, 255, [fmt UTF8String], ptr);
	return [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
}

#pragma mark -- text view delegates --
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text{
	BOOL b = YES;
	if(enabled){
		NSString *ntxt = [textView.text stringByReplacingCharactersInRange:range withString:text];
		int options = NSBackwardsSearch;
		if(caseInsensitive)
			options |= NSCaseInsensitiveSearch;
		NSArray *array = _snippets();
		for(NSDictionary *dic in array){
			NSRange nrange = [ntxt rangeOfString:[dic valueForKey:@"_code"] options:options];
			if (nrange.location < [ntxt length]) {
				NSString *_t = [dic valueForKey:@"_text"];
				if([_t rangeOfString:@"%"].location != NSNotFound)
					_t = _dateStringForFormat(_t);
				textView.text = [ntxt stringByReplacingCharactersInRange:nrange withString:_t];
				if(!noSound){
					if(_bell == 0){
						AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sniff" ofType:@"wav"]], &_bell);
					}
					AudioServicesPlaySystemSound(_bell);
				}
				b = NO;
				break;
			}	
		}
	}
	
	if(b){
		if([_delegate respondsToSelector:_cmd])
			b = [_delegate textView:_textView shouldChangeTextInRange:range replacementText:text];
	}
	return b;
}

- (void)textViewDidBeginEditing:(UITextView*)textView{
	if([_delegate respondsToSelector:_cmd])
		[_delegate textViewDidBeginEditing:_textView];
}

- (void)textViewDidChange:(UITextView *)textView{
	if([_delegate respondsToSelector:_cmd])
		[_delegate textViewDidChange:_textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
	if([_delegate respondsToSelector:_cmd])
		[_delegate textViewDidChangeSelection:_textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
	if([_delegate respondsToSelector:_cmd])
		[_delegate textViewDidEndEditing:_textView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
	BOOL b = YES;
	if([_delegate respondsToSelector:_cmd])
		b = [_delegate textViewShouldBeginEditing:_textView];
	return b;
}

- (BOOL)textViewShouldEndEditing:(UITextView*)textView{
	BOOL b = YES;
	if([_delegate respondsToSelector:_cmd])
		b = [_delegate textViewShouldEndEditing:_textView];
	return b;
}

#pragma mark -- text field delegates --

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{
	BOOL b = YES;
	if(enabled){
		NSString *ntxt = [textField.text stringByReplacingCharactersInRange:range withString:string];
		int options = NSBackwardsSearch;
		if(caseInsensitive)
			options |= NSCaseInsensitiveSearch;
		NSArray *array = _snippets();
		for(NSDictionary *dic in array){
			NSRange nrange = [ntxt rangeOfString:[dic valueForKey:@"_code"] options:options];
			if(nrange.location < [ntxt length]){
				NSString *_t = [dic valueForKey:@"_text"];
				if([_t rangeOfString:@"%"].location != NSNotFound)
					_t = _dateStringForFormat(_t);
				textField.text = [ntxt stringByReplacingCharactersInRange:nrange withString:_t];
				if(!noSound){
					if(_bell == 0){
						AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sniff" ofType:@"wav"]], &_bell);
					}
					AudioServicesPlaySystemSound(_bell);
				}
				b = NO;
				break;
			}
		}
	}
	if(b){
		if([_delegate respondsToSelector:_cmd])
			b = [_delegate textField:_textField shouldChangeCharactersInRange:range replacementString:string];
	}
	return b;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	if([_delegate respondsToSelector:_cmd])
		[_delegate textFieldDidBeginEditing:_textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	if([_delegate respondsToSelector:_cmd])
		[_delegate textFieldDidEndEditing:_textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	BOOL b = YES;
	if([_delegate respondsToSelector:_cmd])
		[_delegate textFieldShouldBeginEditing:_textField];
	return b;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
	BOOL b = YES;
	if([_delegate respondsToSelector:_cmd])
		[_delegate textFieldShouldClear:_textField];
	return b;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
	BOOL b = YES;
	if([_delegate respondsToSelector:_cmd])
		[_delegate textFieldShouldEndEditing:_textField];
	return b;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	BOOL b = YES;
	if([_delegate respondsToSelector:_cmd])
		[_delegate textFieldShouldReturn:_textField];
	return b;
}

@end
