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
    return args.reduce([String: String]()) { (var result, let entry) in
        return entry.reduce(result) { (var result, let entry) in
            let (key, value) = entry;
            
            result[key] = value;
            
            return result;
        }
    }
}

internal class PixelManager {
    let pixelURI: String;
    let URIRequestClass: URIRequest.Type;
    private let baseURI: URI;
    
    init(pixelURI _pixelURI: String, URIRequestClass _URIRequestClass: URIRequest.Type) {
        pixelURI = _pixelURI;
        URIRequestClass = _URIRequestClass;
        
        baseURI = URI(href: pixelURI);
    }
    
    public func fire(type: String, params: [String: String]) {
        let request = URIRequestClass.create(URI(
            protoc: baseURI.protoc,
            hostname: baseURI.hostname,
            pathname: baseURI.pathname,
            query: extend([
                "type": type,
                "deviceId": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
            ], params)
        ));
        
        request.send();
    }
    
    public class func create(pixelURI: String) -> PixelManager {
        return PixelManager(pixelURI: pixelURI, URIRequestClass: URIRequest.self);
    }
}