# RCAnalytics

[![Version](https://img.shields.io/cocoapods/v/RCAnalytics.svg?style=flat)](http://cocoapods.org/pods/RCAnalytics)
[![License](https://img.shields.io/cocoapods/l/RCAnalytics.svg?style=flat)](http://cocoapods.org/pods/RCAnalytics)
[![Platform](https://img.shields.io/cocoapods/p/RCAnalytics.svg?style=flat)](http://cocoapods.org/pods/RCAnalytics)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation

### Set Up Your App for Use With Cocoapods
1. Install [CocoaPods](http://cocoapods.org)

    ```bash
    $> sudo gem install cocoapods
    ```
2. Create a `Podfile` in your app product directory:

    ```ruby
    target 'MyAppTargetHere' do
        use_frameworks!
    end
    ```

### Install RCAnalytics with CocoaPods
1. Add RCAnalytics as a dependency

    ```ruby
    target 'MyAppTargetHere' do
        use_frameworks!
        
        pod "RCAnalytics", "~> 0.1.0"
    end
    ```
2. Install Dependencies

    ```bash
    $> pod install
    ```

## Usage
1. Get your *product ID* from the Reelcontent Showcase platform
2. Initialize `RCAnalytics` when your app launches:

    **In Swift:**
    
    ```swift
    import UIKit;
    import RCAnalytics;
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        // called after your app launches
        func application(
            application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?
        ) -> Bool {
            RCAnalytics.create("your-product-id-here").launch(); // Launch RCAnalytics
            return true;
        }
    }
    ```
    
    **In Objective-C:**
    
    ```objective-c
    #import "AppDelegate.h"
    #import <Foundation/Foundation.h>
    @import RCAnalytics;
    
    @implementation AppDelegate
        // called after your app launches
        -(BOOL)
            application:(UIApplication *)application
            didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
        {
            [[RCAnalytics create:@"your-product-id-here"] launch]; // Launch RCAnalytics
            return YES;
        }
    @end
    ```

## Author

Reelcontent, Inc., [info@reelcontent.com](mailto:info@reelcontent.com?subject=RCAnalytics)

## License

RCAnalytics is available under the MIT license. See the LICENSE file for more info.
