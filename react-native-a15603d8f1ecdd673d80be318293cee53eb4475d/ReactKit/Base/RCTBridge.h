// Copyright 2004-present Facebook. All Rights Reserved.

/**
 * @brief
 *
 * 这是 React Native 中 RCTBridge 类的头文件。
 * RCTBridge 负责与 JavaScript 运行时通信，并管理 JavaScript 和本地代码之间的交互。
 * 该类提供了将 JavaScript 方法调用加入执行队列的方法，以及加载和执行 JavaScript 文件的方法。
 * 它还包括对 RCTUIManager 的引用，后者负责管理应用程序中视图的层次结构，以及 RCTJavaScriptEventDispatcher 的引用，后者负责在 JavaScript 和本地代码之间分发事件。
 * 该类还包括一个全局日志函数，可用于将消息打印到 Xcode 和 JS 调试器控制台。
 * 该类遵循 RCTInvalidating 协议，后者提供了一种在不再需要时使桥接无效的方法。
 * 请注意，文件中的注释提到存储回调可能会导致引用循环，并建议使用 JSManagedValue 来避免此问题。
 * 但是，注释还指出，该类目前仍存在泄漏问题，直到问题得到解决为止。
 */

#import "RCTExport.h"
#import "RCTInvalidating.h"
#import "RCTJavaScriptExecutor.h"

@protocol RCTNativeModule;

@class RCTUIManager;
@class RCTJavaScriptEventDispatcher;

/**
 * Functions are the one thing that aren't automatically converted to OBJC
 * blocks, according to this revert: http://trac.webkit.org/changeset/144489
 * They must be expressed as `JSValue`s.
 *
 * But storing callbacks causes reference cycles!
 * http://stackoverflow.com/questions/19202248/how-can-i-use-jsmanagedvalue-to-avoid-a-reference-cycle-without-the-jsvalue-gett
 * We'll live with the leak for now, but need to clean this up asap:
 * Passing a reference to the `context` to the bridge would make it easy to
 * execute JS. We can add `JSManagedValue`s to protect against this. The same
 * needs to be done in `RCTTiming` and friends.
 */

/**
 * Must be kept in sync with `MessageQueue.js`.
 */
typedef NS_ENUM(NSUInteger, RCTBridgeFields) {
  RCTBridgeFieldRequestModuleIDs = 0,
  RCTBridgeFieldMethodIDs,
  RCTBridgeFieldParamss,
  RCTBridgeFieldResponseCBIDs,
  RCTBridgeFieldResponseReturnValues,
  RCTBridgeFieldFlushDateMillis
};

/**
 * Utilities for constructing common response objects. When sending a
 * systemError back to JS, it's important to describe whether or not it was a
 * system error, or API usage error. System errors should never happen and are
 * therefore logged using `RCTLogError()`. API usage errors are expected if the
 * API is misused and will therefore not be logged using `RCTLogError()`. The JS
 * application code is expected to handle them. Regardless of type, each error
 * should be logged at most once.
 */
static inline NSDictionary *RCTSystemErrorObject(NSString *msg)
{
  return @{@"systemError" : msg ?: @""};
}

static inline NSDictionary *RCTAPIErrorObject(NSString *msg)
{
  return @{@"apiError" : msg ?: @""};
}

/**
 * Async batched bridge used to communicate with `RCTJavaScriptAppEngine`.
 */
@interface RCTBridge : NSObject <RCTInvalidating>

- (instancetype)initWithJavaScriptExecutor:(id<RCTJavaScriptExecutor>)javaScriptExecutor
                               shadowQueue:(dispatch_queue_t)shadowQueue
                   javaScriptModulesConfig:(NSDictionary *)javaScriptModulesConfig;

- (void)enqueueJSCall:(NSUInteger)moduleID methodID:(NSUInteger)methodID args:(NSArray *)args;
- (void)enqueueApplicationScript:(NSString *)script url:(NSURL *)url onComplete:(RCTJavaScriptCompleteBlock)onComplete;
- (void)enqueueUpdateTimers;

@property(nonatomic, readonly) RCTUIManager *uiManager;
@property(nonatomic, readonly) RCTJavaScriptEventDispatcher *eventDispatcher;

// For use in implementing delegates, which may need to queue responses.
- (RCTResponseSenderBlock)createResponseSenderBlock:(NSInteger)callbackID;

/**
 * Global logging function will print to both xcode and js debugger consoles.
 *
 * NOTE: Use via RCTLog* macros defined in RCTLog.h
 * TODO (#5906496): should log function be exposed here, or could it be a module?
 */
+ (void)log:(NSArray *)objects level:(NSString *)level;

+ (BOOL)hasValidJSExecutor;

@end
