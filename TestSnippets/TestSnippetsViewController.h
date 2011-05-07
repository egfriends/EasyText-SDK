//
//  TestSnippetsViewController.h
//  TestSnippets
//
//  Created by Eric on 4/20/11.
//  Copyright 2011 EGFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EasyTextSniffer;

@interface TestSnippetsViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextView *textView;
	
	EasyTextSniffer *sniffer;
}

@end
