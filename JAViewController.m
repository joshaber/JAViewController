//
//  JAViewController.m
//
//  Created by Josh Abernathy on 8/17/10.
//  Copyright (c) 2010 Maybe Apps. All rights reserved.
//

#import "JAViewController.h"
#import "NSView+JAExtensions.h"


@implementation JAViewController

+ (id)viewController {
    return [[[self alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil] autorelease];
}

- (void)loadView {
    [super loadView];
        
    [self viewDidLoad];
}

- (void)setView:(NSView *)view {
    [super setView:view];
    
    self.view.viewController = self;
}

- (void)viewDidLoad {
    
}

- (void)viewWillAppear {
    [self.view setNeedsLayout];
}

- (void)viewDidAppear {

}

- (void)viewWillDisappear {
    
}

- (void)viewDidDisappear {
    
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    
}

- (void)viewDidMoveToSuperview {

}

- (void)viewWillBeRemovedFromSuperview {
    
}

- (void)viewWasRemovedFromSuperview {
    
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    
}

- (void)viewDidMoveToWindow {

}

- (void)viewWillBeRemovedFromWindow {
    
}

- (void)viewWasRemovedFromWindow {
    
}

@end
