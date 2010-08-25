//
//  BetterViewControllerAppDelegate.m
//  BetterViewController
//
//  Created by Josh Abernathy on 8/22/10.
//  Copyright 2010 Maybe Apps. All rights reserved.
//

#import "BetterViewControllerAppDelegate.h"
#import "BVCMainViewController.h"

@interface BetterViewControllerAppDelegate ()
@property (nonatomic, retain) BVCMainViewController *mainViewController;
@end


@implementation BetterViewControllerAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    LOG();
    self.mainViewController = [BVCMainViewController viewController];
    [self.window.contentView addSubview:self.mainViewController.view];
    self.mainViewController.view.frame = [self.window.contentView bounds];
    LOG();
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    LOG();
    [self.window makeKeyAndOrderFront:nil];
    LOG();
}

@synthesize window;
@synthesize mainViewController;

@end
