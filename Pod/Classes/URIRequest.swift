//
//  URIRequest.swift
//  Pods
//
//  Created by Josh Minzner on 4/13/16.
//
//

import Foundation;

internal class URIRequest {
    let uri: URI;
    let session: NSURLSession;
    
    init(uri _uri: URI, session _session: NSURLSession) {
        uri = _uri;
        session = _session;
    }
    
    func send(handler: ((NSError?, String?) -> Void)?) {
        session.dataTaskWithURL(uri.toNSURL()) { data, _, error in
            if (handler != nil) {
                let callback = handler!;
                
                if (error == nil) {
                    callback(nil, (NSString(data: data!, encoding: NSUTF8StringEncoding) as! String));
                } else {
                    callback(error, nil);
                }
            }
        }.resume();
    }
    
    func send() {
        return send(nil);
    }
    
    class func create(uri: URI) -> URIRequest {
        return URIRequest(uri: uri, session: NSURLSession.sharedSession());
    }
}