//
//  TestSnippetsAppDelegate.h
//  TestSnippets
//
//  Created by Eric on 4/20/11.
//  Copyright 2011 EGFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestSnippetsViewController;

@interface TestSnippetsAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TestSnippetsViewController *viewController;

@end
