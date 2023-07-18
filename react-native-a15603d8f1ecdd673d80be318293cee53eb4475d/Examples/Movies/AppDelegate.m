// Copyright 2004-present Facebook. All Rights Reserved.

#import "AppDelegate.h"

#import "RCTRootView.h"

@implementation AppDelegate

// 在 iOS 应用启动完成后会触发 application didFinishLaunchingWithOptions 回调
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;
  // React Native 应用根视图的初始化
  RCTRootView *rootView = [[RCTRootView alloc] init];

  // Loading JavaScript code - uncomment the one you want.

  // OPTION 1
  // Load from development server. Start the server from the repository root:
  //
  // $ npm start
  //
  // To run on device, change `localhost` to the IP address of your computer, and make sure your computer and
  // iOS device are on the same Wi-Fi network.
  // React Native 应用的 JavaScript 代码地址
  jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/Examples/Movies/MoviesApp.includeRequire.runModule.bundle"];

  // OPTION 2
  // Load from pre-bundled file on disk. To re-generate the static bundle, run
  //
  // $ curl http://localhost:8081/Examples/Movies/MoviesApp.includeRequire.runModule.bundle -o main.jsbundle
  //
  // and uncomment the next following line
  // jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];

  // 将 JavaScript 代码挂到根视图上
  rootView.scriptURL = jsCodeLocation;
  rootView.moduleName = @"MoviesApp";

  // iOS 应用 UIWindow 主窗口初始化
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [[UIViewController alloc] init];

  // 将 React Native 应用根视图挂到 UIWindow 上，此时 React Native 视图展示在手机上了
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end

@end
