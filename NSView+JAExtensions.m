//
//  NSView+JAExtensions.m
//
//  Created by Josh Abernathy on 8/18/10.
//  Copyright (c) 2010 Maybe Apps. All rights reserved.
//

#import "NSView+JAExtensions.h"
#import "NSObject+JAExtensions.h"
#import "JAViewController.h"
#import <objc/runtime.h>

@interface NSView ()
+ (void)loadSupportForLayoutSubviews;
+ (void)loadSupportForViewControllers;

- (void)custom_viewWillMoveToSuperview:(NSView *)newSuperview;
- (void)custom_viewDidMoveToSuperview;

- (void)custom_viewWillMoveToWindow:(NSWindow *)newWindow;
- (void)custom_viewDidMoveToWindow;

- (void)custom_setNextResponder:(NSResponder *)newNextResponder;

- (void)custom_setBounds:(NSRect)newBounds;
- (void)custom_setFrame:(NSRect)newFrame;
- (void)custom_viewWillDraw;
- (BOOL)needsLayout;
@end

static NSString * const JAViewExtensionsViewControllerKey = @"JAViewExtensionsViewControllerKey";
static NSString * const JAViewExtensionsNeedsLayoutKey = @"JAViewExtensionsNeedsLayoutKey";

static BOOL hasSwizzledViewControllerMethods = NO;


@implementation NSView (JAExtensions)

+ (void)initialize {
    if(self == [NSView class]) {
        [self loadSupportForLayoutSubviews];
    }
}


#pragma mark UIView -layoutSubviews support

+ (void)loadSupportForLayoutSubviews {
    [self swapMethod:@selector(setBounds:) with:@selector(custom_setBounds:)];
    [self swapMethod:@selector(setFrame:) with:@selector(custom_setFrame:)];
    [self swapMethod:@selector(viewWillDraw) with:@selector(custom_viewWillDraw)];
}

- (void)custom_setBounds:(NSRect)newBounds {
    [self custom_setBounds:newBounds];
    
    [self setNeedsLayout];
}

- (void)custom_setFrame:(NSRect)newFrame {
    [self custom_setFrame:newFrame];
    
    [self setNeedsLayout];
}

- (void)custom_viewWillDraw {
    [self layoutIfNeeded];
    
    [self custom_viewWillDraw];
}

- (void)layoutIfNeeded {
    if([self needsLayout]) {
        [self layoutSubviews];
    }
}

- (void)layoutSubviews {
    objc_setAssociatedObject(self, JAViewExtensionsNeedsLayoutKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setNeedsLayout {
    objc_setAssociatedObject(self, JAViewExtensionsNeedsLayoutKey, [NSNull null], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsDisplay:YES];
}

- (BOOL)needsLayout {
    return objc_getAssociatedObject(self, JAViewExtensionsNeedsLayoutKey) != nil;
}


#pragma mark NSViewController support

+ (void)loadSupportForViewControllers {
    @synchronized(self) {
        if(hasSwizzledViewControllerMethods) return;
        
        [self swapMethod:@selector(viewWillMoveToSuperview:) with:@selector(custom_viewWillMoveToSuperview:)];
        [self swapMethod:@selector(viewDidMoveToSuperview) with:@selector(custom_viewDidMoveToSuperview)];
        
        [self swapMethod:@selector(viewWillMoveToWindow:) with:@selector(custom_viewWillMoveToWindow:)];
        [self swapMethod:@selector(viewDidMoveToWindow) with:@selector(custom_viewDidMoveToWindow)];
        
        [self swapMethod:@selector(setNextResponder:) with:@selector(custom_setNextResponder:)];
        
        hasSwizzledViewControllerMethods = YES;
    }
}

- (void)setViewController:(NSViewController *)newViewController {
    // swizzle methods only after we make use of the viewController property
    [[self class] loadSupportForViewControllers];
    
    if(self.viewController != nil) {
        NSResponder *controllerNextResponder = [self.viewController nextResponder];
        [self custom_setNextResponder:controllerNextResponder];
        [self.viewController setNextResponder:nil];
    }
    
    objc_setAssociatedObject(self, JAViewExtensionsViewControllerKey, newViewController, OBJC_ASSOCIATION_ASSIGN);
    
    if(newViewController != nil) {
        NSResponder *ownNextResponder = [self nextResponder];
        [self custom_setNextResponder:self.viewController];
        [self.viewController setNextResponder:ownNextResponder];
    }
}

- (NSViewController *)viewController {
    return objc_getAssociatedObject(self, JAViewExtensionsViewControllerKey);
}

- (void)custom_viewWillMoveToSuperview:(NSView *)newSuperview {
    [self custom_viewWillMoveToSuperview:newSuperview];
    
    if([self.viewController isKindOfClass:[JAViewController class]]) {
        if(newSuperview == nil) {
            [(JAViewController *) self.viewController viewWillBeRemovedFromSuperview];
            
            if(self.superview != nil && self.window != nil) {
                [(JAViewController *) self.viewController viewWillDisappear];
            }
        } else {
            [(JAViewController *) self.viewController viewWillMoveToSuperview:newSuperview];
            
            if(self.window != nil) {
                [(JAViewController *) self.viewController viewWillAppear];
            }
        }
    }
}

- (void)custom_viewDidMoveToSuperview {
    [self custom_viewDidMoveToSuperview];
    
    if([self.viewController isKindOfClass:[JAViewController class]]) {
        if(self.superview == nil) {
            [(JAViewController *) self.viewController viewWasRemovedFromSuperview];
            
            if(self.window == nil) {
                [(JAViewController *) self.viewController viewDidDisappear];
            }
        } else {
            [(JAViewController *) self.viewController viewDidMoveToSuperview];
            
            if(self.window != nil) {
                [(JAViewController *) self.viewController viewDidAppear];
            }
        }
    }
}

- (void)custom_viewWillMoveToWindow:(NSWindow *)newWindow {
    [self custom_viewWillMoveToWindow:newWindow];
    
    if([self.viewController isKindOfClass:[JAViewController class]]) {
        if(newWindow == nil) {
            [(JAViewController *) self.viewController viewWillBeRemovedFromWindow];
            
            if(self.superview != nil && self.window != nil) {
                [(JAViewController *) self.viewController viewWillDisappear];
            }
        } else {
            [(JAViewController *) self.viewController viewWillMoveToWindow:newWindow];
            
            if(self.superview != nil) {
                [(JAViewController *) self.viewController viewWillAppear];
            }
        }
    }
}

- (void)custom_viewDidMoveToWindow {
    [self custom_viewDidMoveToWindow];
    
    if([self.viewController isKindOfClass:[JAViewController class]]) {
        if(self.window == nil) {
            [(JAViewController *) self.viewController viewWasRemovedFromWindow];
            
            if(self.superview == nil) {
                [(JAViewController *) self.viewController viewDidDisappear];
            }
        } else {
            [(JAViewController *) self.viewController viewDidMoveToWindow];
            
            if(self.superview != nil) {
                [(JAViewController *) self.viewController viewDidAppear];
            }
        }
    }
}

- (void)custom_setNextResponder:(NSResponder *)newNextResponder {
    if(self.viewController != nil) {
        [self.viewController setNextResponder:newNextResponder];
        return;
    }
    
    [self custom_setNextResponder:newNextResponder];
}

@end
