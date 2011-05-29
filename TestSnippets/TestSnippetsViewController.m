//
//  TestSnippetsViewController.m
//  TestSnippets
//
//  Created by Eric on 4/20/11.
//  Copyright 2011 EGFriends. All rights reserved.
//

#import "TestSnippetsViewController.h"

#import "EasyTextSniffer.h"

@implementation TestSnippetsViewController

- (IBAction)enableEasyText:(id)sender{
	[sniffer tryEnable];
	if(sniffer.enabled){
		[sender setTitle:@"disable EasyText" forState:UIControlStateNormal];
	}
	else
		[sender setTitle:@"enable EasyText" forState:UIControlStateNormal];
}

- (void)dealloc
{
	[sniffer release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// this statement should go into init, not here
	sniffer = [EasyTextSniffer new];

	// init a textView in self, and set self as delegate of sniffer, which hold a reference of the textView
	[sniffer sniffTextView:textView delegate:self];
	
	// indicates should ignore capital
	sniffer.caseInsensitive = YES;
	
	// indicates should be silent when translating code to text
	sniffer.noSound = NO;
	
	[textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[textView release]; textView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
