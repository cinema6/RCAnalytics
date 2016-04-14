//
//  RCAnalytics.swift
//  Pods
//
//  Created by Josh Minzner on 4/11/16.
//
//

import Foundation;

private let API_ROOT = "https://audit.reelcontent.com/";

public class RCAnalytics: NSObject {
    public let apiRoot: String;
    public let product: String;
    private let pixels: PixelManager;
    
    internal init(
        apiRoot _apiRoot: String = API_ROOT,
        product _product: String,
        PixelManagerClass: PixelManager.Type
    ) {
        let root = URI(href: _apiRoot);
        
        apiRoot = _apiRoot;
        product = _product;
        
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
        return track("appLaunch");
    }
    
    public static func create(
        product: String,
        apiRoot: String
    ) -> RCAnalytics {
        return RCAnalytics(apiRoot: apiRoot, product: product, PixelManagerClass: PixelManager.self);
    }
    
    public static func create(product: String) -> RCAnalytics {
        return create(product, apiRoot: API_ROOT);
    }
}