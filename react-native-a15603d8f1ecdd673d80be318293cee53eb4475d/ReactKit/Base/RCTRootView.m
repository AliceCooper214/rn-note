// Copyright 2004-present Facebook. All Rights Reserved.

#import "RCTRootView.h"

#import "RCTBridge.h"
#import "RCTContextExecutor.h"
#import "RCTJavaScriptAppEngine.h"
#import "RCTJavaScriptEventDispatcher.h"
#import "RCTModuleIDs.h"
#import "RCTRedBox.h"
#import "RCTShadowView.h"
#import "RCTSparseArray.h"
#import "RCTTouchHandler.h"
#import "RCTUIManager.h"
#import "RCTUtils.h"
#import "RCTViewManager.h"
#import "UIView+ReactKit.h"
#import "RCTKeyCommands.h"

NSString *const RCTRootViewReloadNotification = @"RCTRootViewReloadNotification";

@implementation RCTRootView
{
  // 用于通讯的队列
  dispatch_queue_t _shadowQueue;
  // 通讯桥
  RCTBridge *_bridge;
  // JS引擎，底层是 JSCore
  RCTJavaScriptAppEngine *_appEngine;
  // 触控事件句柄
  RCTTouchHandler *_touchHandler;
}

+ (void)initialize
{

#if DEBUG

  // Register Cmd-R as a global refresh key
  [[RCTKeyCommands sharedInstance] registerKeyCommandWithInput:@"r"
                                                 modifierFlags:UIKeyModifierCommand
                                                        action:^(UIKeyCommand *command) {
                                                          [self reloadAll];
                                                        }];

#endif
  
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (!self) return nil;

  [self setUp];

  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (!self) return nil;

  [self setUp];

  return self;
}

- (void)setUp
{
  // TODO: does it make sense to do this here? What if there's more than one host view?
  _shadowQueue = dispatch_queue_create("com.facebook.ReactKit.ShadowQueue", DISPATCH_QUEUE_SERIAL);

  // Every root view that is created must have a unique react tag.
  // Numbering of these tags goes from 1, 11, 21, 31, etc
  static NSInteger rootViewTag = 1;
  self.reactTag = @(rootViewTag);
  rootViewTag += 10;

  // Add reload observer
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reload)
                                               name:RCTRootViewReloadNotification
                                             object:nil];
  self.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bundleFinishedLoading:(NSError *)error
{
  if (error != nil) {
    [[RCTRedBox sharedInstance] showErrorMessage:error.localizedDescription withDetails:error.localizedFailureReason];
  } else {
    
    [_bridge.uiManager registerRootView:self];

    NSString *moduleName = _moduleName ?: @"";
    NSDictionary *appParameters = @{
      @"rootTag": self.reactTag ?: @0,
      @"initialProps": self.initialProperties ?: @{},
    };
    [_appEngine.bridge enqueueJSCall:RCTModuleIDBundler
                            methodID:RCTBundlerRunApplication
                                args:@[moduleName, appParameters]];
  }
}

// 加载 Bundle 代码
- (void)loadBundle
{
  // Clear view
  [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  if (!_scriptURL) {
    return;
  }
  
  __weak typeof(self) weakSelf = self;
  RCTJavaScriptCompleteBlock callback = ^(NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf bundleFinishedLoading:error];
    });
  };

  [_executor invalidate];
  [_appEngine invalidate];
  [_bridge invalidate];

  // executor：生成一个新的用于执行 JS 线程
  _executor = [[RCTContextExecutor alloc] init];
  // bridge：处理 JS 和 Native 之间的相互通讯。
  //  Native RCTXXX <=> native moduleIDs <==bridge==> message <=> js function
  _bridge = [[RCTBridge alloc] initWithJavaScriptExecutor:_executor
                                              shadowQueue:_shadowQueue
                                  javaScriptModulesConfig:[RCTModuleIDs config]];

  // appEngine: JavaScriptCore
  _appEngine = [[RCTJavaScriptAppEngine alloc] initWithBridge:_bridge];
  // touchHandler: 绑定原生手势事件 + 用户触发时通过 bridge 通知 JS
  _touchHandler = [[RCTTouchHandler alloc] initWithEventDispatcher:_bridge.eventDispatcher rootView:self];

  // 使用JS引擎，执行 scriptURL 代码，初始化所有的 Bundle 代码
  [_appEngine loadBundleAtURL:_scriptURL useCache:NO onComplete:callback];
}

// scriptURL 属性的 set 方法
- (void)setScriptURL:(NSURL *)scriptURL
{
  if ([_scriptURL isEqual:scriptURL]) {
    return;
  }

  _scriptURL = scriptURL;
  // 调用 loadBundle 方法
  [self loadBundle];
}

- (void)setExecutor:(id<RCTJavaScriptExecutor>)executor
{
  RCTAssert(!_bridge, @"You may only change the Javascript Executor prior to loading a script bundle.");
  _executor = executor;
}

- (BOOL)isReactRootView
{
  return YES;
}

- (void)reload
{
  [RCTJavaScriptAppEngine resetCacheForBundleAtURL:_scriptURL];
  [self loadBundle];
}

+ (void)reloadAll
{
  [[NSNotificationCenter defaultCenter] postNotificationName:RCTRootViewReloadNotification object:nil];
}

#pragma mark - Key commands

- (NSArray *)keyCommands
{
  return @[
           
    // Reload
    [UIKeyCommand keyCommandWithInput:@"r"
                       modifierFlags:UIKeyModifierCommand
                              action:@selector(reload)]
    ];
}

- (BOOL)canBecomeFirstResponder
{
  return YES;
}

@end
