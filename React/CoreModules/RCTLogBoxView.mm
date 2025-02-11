/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTLogBoxView.h"

#import <React/RCTLog.h>
#import <React/RCTSurface.h>

#if !TARGET_OS_OSX // TODO(macOS GH#774)

@implementation RCTLogBoxWindow { // TODO(macOS GH#774) Renamed from _view to _window
  RCTSurface *_surface;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.windowLevel = UIWindowLevelStatusBar - 1;
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)createRootViewController:(UIView *)view
{
  UIViewController *_rootViewController = [UIViewController new];
  _rootViewController.view = view;
  _rootViewController.view.backgroundColor = [UIColor clearColor];
  _rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  self.rootViewController = _rootViewController;
}

- (instancetype)initWithFrame:(CGRect)frame bridge:(RCTBridge *)bridge
{
  if ((self = [super initWithFrame:frame])) {
    self.windowLevel = UIWindowLevelStatusBar - 1;
    self.backgroundColor = [UIColor clearColor];

    _surface = [[RCTSurface alloc] initWithBridge:bridge moduleName:@"LogBox" initialProperties:@{}];

    [_surface start];
    [_surface setSize:frame.size];

    if (![_surface synchronouslyWaitForStage:RCTSurfaceStageSurfaceDidInitialMounting timeout:1]) {
      RCTLogInfo(@"Failed to mount LogBox within 1s");
    }

    [self createRootViewController:(UIView *)_surface.view];
  }
  return self;
}

- (void)dealloc
{
  [RCTSharedApplication().delegate.window makeKeyWindow];
}

- (void)show
{
  [self becomeFirstResponder];
  [self makeKeyAndVisible];
}

@end

#else // [TODO(macOS GH#774)

@implementation RCTLogBoxWindow { // TODO(macOS GH#774) Renamed from _view to _window
  RCTSurface *_surface;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  NSRect bounds = NSMakeRect(0, 0, 600, 800);
  if ((self = [self initWithContentRect:bounds
                              styleMask:NSWindowStyleMaskTitled
                                backing:NSBackingStoreBuffered
                                  defer:YES])) {
    _surface = [[RCTSurface alloc] initWithBridge:bridge moduleName:@"LogBox" initialProperties:@{}];

    [_surface start];
    [_surface setSize:bounds.size];

    if (![_surface synchronouslyWaitForStage:RCTSurfaceStageSurfaceDidInitialMounting timeout:1]) {
      RCTLogInfo(@"Failed to mount LogBox within 1s");
    }

    self.contentView = (NSView *)_surface.view;
    self.contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  }
  return self;
}

- (void)hide
{
  if (NSApp.modalWindow == self) {
    [NSApp stopModal];
  }
  [self orderOut:nil];
}

- (void)show
{
  if (!RCTRunningInTestEnvironment()) {
    // Run the modal loop outside of the dispatch queue because it is not reentrant.
    [self performSelectorOnMainThread:@selector(_showModal) withObject:nil waitUntilDone:NO];
  }
  else {
    [NSApp activateIgnoringOtherApps:YES];
    [self makeKeyAndOrderFront:nil];
  }
}

- (void)_showModal
{
  NSModalSession session = [NSApp beginModalSessionForWindow:self];

  while ([NSApp runModalSession:session] == NSModalResponseContinue) {
    // Spin the runloop so that the main dispatch queue is processed.
    [[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];
  }

  [NSApp endModalSession:session];
}

@end

#endif // ]TODO(macOS GH#774)
