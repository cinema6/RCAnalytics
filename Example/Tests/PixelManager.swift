// https://github.com/Quick/Quick

import Quick
import Nimble
import Foundation;
import AdSupport;
@testable import RCAnalytics;

private class MockURIRequest: URIRequest {
    var sent = false;
    
    override func send() {
        sent = true;
    }
    
    override class func create(uri: URI) -> URIRequest {
        let request = MockURIRequest(uri: uri, session: NSURLSession.sharedSession());
        
        requests.append(request);
        
        return request;
    }
}

private var requests = [MockURIRequest]();

class PixelManagerSpec: QuickSpec {
    override func spec() {
        describe("PixelManager") {
            var pixelManager: PixelManager!;
            var pixelURI: String!;
            var URIRequestClass: URIRequest.Type!;
            var bundle: NSBundle!;
            
            beforeEach {
                pixelURI = "https://audit-staging.reelcontent.com/pixel.gif";
                URIRequestClass = MockURIRequest.self;
                bundle = NSBundle(forClass: PixelManagerSpec.self);

                pixelManager = PixelManager(pixelURI: pixelURI, URIRequestClass: URIRequestClass, bundle: bundle);
            }
            
            it("should exist") {
                expect(pixelManager).toNot(beNil());
            }
            
            describe("properties") {
                describe("pixelURI") {
                    it("should be the provided pixelURI") {
                        expect(pixelManager.pixelURI).to(equal(pixelURI));
                    }
                }
            }
            
            describe("methods") {
                describe("fire()") {
                    var type: String!;
                    var params: [String: String]!;
                    
                    beforeEach {
                        type = "appLaunch";
                        params = [
                            "this": "is",
                            "a": "test"
                        ];
                        
                        pixelManager.fire(type, params: params);
                    }
                    
                    it("should create a request for the pixel") {
                        expect(requests.count).to(equal(1));
                    }
                    
                    it("should configure the request to fire the pixel") {
                        let uri = requests.first?.uri;
                        
                        expect(uri!.href).to(equal(URI(
                            protoc: "https",
                            hostname: "audit-staging.reelcontent.com",
                            pathname: "/pixel.gif",
                            query: [
                                "hostApp": bundle.infoDictionary?["CFBundleIdentifier"] as! String,
                                "a": "test",
                                "extSessionId": ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString,
                                "this": "is",
                                "event": type
                            ]
                        ).href));
                    }
                    
                    it("should send the request for the pixel") {
                        expect(requests.first!.sent).to(equal(true));
                    }
                }
            }
            
            describe("create()") {
                var pixelURI: String!;
                var result: PixelManager!;
                
                beforeEach {
                    pixelURI = "https://audit-staging.reelcontent.com/pixel.gif";
                    
                    result = PixelManager.create(pixelURI);
                }
                
                it("should create a PixelManager") {
                    expect(result.pixelURI).to(equal(pixelURI));
                    expect(result.URIRequestClass).to(beIdenticalTo(URIRequest.self));
                    expect(result.bundle).to(beIdenticalTo(NSBundle.mainBundle()));
                }
            }
        }
    }
}