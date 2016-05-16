//
//  RCAnalytics.swift
//  Pods
//
//  Created by Josh Minzner on 4/11/16.
//
//

import Foundation;

private let API_ROOT = "https://audit.reelcontent.com/";
private let HAS_LAUNCHED_KEY = "RCAnalytics::HasLaunched";

public class RCAnalytics: NSObject {
    public let apiRoot: String;
    public let product: String;
    private let pixels: PixelManager;
    private let userDefaults: NSUserDefaults;
    
    internal init(
        apiRoot _apiRoot: String = API_ROOT,
        product _product: String,
        PixelManagerClass: PixelManager.Type,
        userDefaults _userDefaults: NSUserDefaults
    ) {
        let root = URI(href: _apiRoot);
        
        apiRoot = _apiRoot;
        product = _product;
        userDefaults = _userDefaults;
        
        pixels = PixelManagerClass.create(URI(
            protoc: root.protoc,
            hostname: root.hostname,
            pathname: "/pixel.gif"
        ).href);
    }
    
    public func track(event: String) {
        return pixels.fire(event, params: [
            "campaign": product
        ]);
    }
    
    public func launch() {
        if (userDefaults.boolForKey(HAS_LAUNCHED_KEY) == false) {
            track("appInstall");
        }

        track("appLaunch");

        userDefaults.setBool(true, forKey: HAS_LAUNCHED_KEY);
        userDefaults.synchronize();
    }
    
    public static func create(
        product: String,
        apiRoot: String
    ) -> RCAnalytics {
        return RCAnalytics(
            apiRoot: apiRoot,
            product: product,
            PixelManagerClass: PixelManager.self,
            userDefaults: NSUserDefaults.standardUserDefaults()
        );
    }
    
    public static func create(product: String) -> RCAnalytics {
        return create(product, apiRoot: API_ROOT);
    }
}