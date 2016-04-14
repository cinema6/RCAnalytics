//
//  PixelManager.swift
//  Pods
//
//  Created by Josh Minzner on 4/11/16.
//
//

import Foundation;
import AdSupport;

private func extend(args:Dictionary<String, String>...) -> Dictionary<String, String> {
    return args.reduce([String: String]()) { result, dict in
        return dict.reduce(result) { _result, entry in
            var result = _result;
            let (key, value) = entry;
            
            result[key] = value;
            
            return result;
        }
    }
}

internal class PixelManager {
    let pixelURI: String;
    let URIRequestClass: URIRequest.Type;
    let bundle: NSBundle;
    private let baseURI: URI;
    
    init(pixelURI _pixelURI: String, URIRequestClass _URIRequestClass: URIRequest.Type, bundle _bundle: NSBundle) {
        pixelURI = _pixelURI;
        URIRequestClass = _URIRequestClass;
        bundle = _bundle;
        
        baseURI = URI(href: pixelURI);
    }
    
    func fire(type: String, params: [String: String]) {
        let request = URIRequestClass.create(URI(
            protoc: baseURI.protoc,
            hostname: baseURI.hostname,
            pathname: baseURI.pathname,
            query: extend([
                "type": type,
                "deviceId": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString,
                "appId": (bundle.infoDictionary?["CFBundleIdentifier"] as? String) ?? ""
            ], params)
        ));
        
        request.send();
    }
    
    class func create(pixelURI: String) -> PixelManager {
        return PixelManager(pixelURI: pixelURI, URIRequestClass: URIRequest.self, bundle: NSBundle.mainBundle());
    }
}