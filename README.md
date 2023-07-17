# rn-note

记录一些学习RN源码的笔记

## 0.0.1 版本

目录结构

```bash
── Examples
│ ├── Movies
│ ├── TicTacToe
│ └── UIExplorer
├── Libraries
│ ├── BatchedBridge
│ ├── Bundler
│ ├── Components
│ ├── Device
│ ├── Fetch
│ ├── Interaction
│ ├── JavaScriptAppEngine
│ ├── RKBackendNode
│ ├── ReactIOS
│ ├── StyleSheet
│ ├── Utilities
│ ├── XMLHttpRequest
│ ├── react-native
│ └── vendor
├── ReactKit
│ ├── Base
│ ├── Executors
│ ├── Layout
│ ├── Modules
│ ├── ReactKit.xcodeproj
│ └── Views
├── jestSupport
└── packager
```

React Native 架构整体上分为三层， Example 是业务、Libraries 是封装的库、ReactKit是原生实现。

在 TicTacToe、Movies、UIExplorer 这三个项目中其实包含了一个线头，也就是它们的 main函数：

```swift
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
  @autoreleasepool {
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
```

Libraries 目录中的线头是 Libraries/react-native/react-native.js 文件

ReactKit 目录，它放置的全部都是 iOS 的代码。

ReactKit 的命名风格，很明显模仿的是 iOS UIKit 的命名风格，它的意思是里面放的是为React 编写的代码套件。其中，Executors目录负责执行上层的JavaScript 代码，Base 目录负责实现 JavaScript 和 iOS 通信的 Native 部分，Views、Modules、Layout 目录负责将iOS 组件、接口暴露给 JavaScript，并实现了布局功能。

原生应用入口在main函数，UIApplicationMain 函数创建一个应用程序对象，完成应用启动。通过创建AppDelegate对象，此时调用它的生命周期函数didFinishLaunchingWithOptions。

```swift
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
```

进入框架运行部分
![Alt text](/assets/img/1689590107746.png)
