// Copyright 2004-present Facebook. All Rights Reserved.
/**
 * @brief
 *
 * 这段代码是一个 iOS 开发中用于实现 JavaScript 执行器的类，实现了 RCTJavaScriptExecutor 协议。
 * 该类使用 JavaScriptCore 框架提供的上下文作为执行引擎，可以在 iOS 应用程序中执行 JavaScript 代码。
 * 具体来说，这个类是 RCTContextExecutor，其中包含一个 initWithJavaScriptThread:globalContextRef: 构造函数，
 * 用于配置执行器以在自定义执行线程上运行 JavaScript。
 * 它使用一个 JSGlobalContextRef 类型的参数来指定 JavaScriptCore 上下文，这个上下文包含了 JavaScript 运行时的全局对象，变量和函数等信息。
 * 该类的主要作用是对 JavaScriptCore 进行封装，提供了一个更高层次的接口，方便应用程序开发者使用 JavaScript 代码来实现某些功能，
 * 例如实现 React Native 中的组件、模块等。
 */
#import <JavaScriptCore/JavaScriptCore.h>

#import "RCTJavaScriptExecutor.h"

// TODO (#5906496): Might RCTJSCoreExecutor be a better name for this?

/**
 * Uses a JavaScriptCore context as the execution engine.
 */
@interface RCTContextExecutor : NSObject <RCTJavaScriptExecutor>

/**
 * Configures the executor to run JavaScript on a custom performer.
 * You probably don't want to use this; use -init instead.
 */
- (instancetype)initWithJavaScriptThread:(NSThread *)javaScriptThread
                        globalContextRef:(JSGlobalContextRef)context;

@end
