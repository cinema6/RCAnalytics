//
//  RCAnalytics.swift
//  RCAnalytics
//
//  Created by Josh Minzner on 4/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Quick;
import Nimble;
@testable import RCAnalytics;

private class MockPixelManager: PixelManager {
    var fireArgs = [Array<Any>]();
    
    override func fire(type: String, params: [String : String]) {
        fireArgs.append([type, params]);
    }
    
    override class func create(pixelURI: String) -> MockPixelManager {
        pixelManager = MockPixelManager(pixelURI: pixelURI, URIRequestClass: URIRequest.self, bundle: NSBundle());
        
        return pixelManager;
    }
}

private var pixelManager: MockPixelManager!;

class RCAnalyticsSpec: QuickSpec {
    override func spec() {
        describe("RCAnalytics(apiRoot)") {
            var rc: RCAnalytics!;
            var apiRoot: String!, product: String!;
            var PixelManagerClass: PixelManager.Type!;
            
            beforeEach {
                apiRoot = "https://audit-staging.reelcontent.com/";
                product = "cam-0GK0Wx03p17-qs1f";
                PixelManagerClass = MockPixelManager.self;
                
                rc = RCAnalytics(apiRoot: apiRoot, product: product, PixelManagerClass: PixelManagerClass);
            }
            
            it("should exist") {
                expect(rc).toNot(beNil());
            }
            
            it("should create a PixelManager") {
                expect(pixelManager).notTo(beNil());
                expect(pixelManager.pixelURI).to(equal("https://audit-staging.reelcontent.com/pixel.gif"));
            }
            
            describe("properties:") {
                describe("product") {
                    it("should be the product id") {
                        expect(rc.product).to(equal(product));
                    }
                }
                
                describe("apiRoot") {
                    it("should be the provided apiRoot") {
                        expect(rc.apiRoot).to(equal(apiRoot));
                    }
                    
                    describe("if none is provided") {
                        beforeEach {
                            rc = RCAnalytics(product: product, PixelManagerClass: PixelManagerClass);
                        }
                        
                        it("should be https://audit.reelcontent.com/") {
                            expect(rc.apiRoot).to(equal("https://audit.reelcontent.com/"));
                        }
                    }
                }
            }
            
            describe("methods:") {
                describe("track()") {
                    var event: String!;
                    
                    beforeEach {
                        event = "appLaunch";
                        
                        rc.track(event);
                    }
                    
                    it("should fire a pixel") {
                        let type = pixelManager.fireArgs.last?.first as! String;
                        let params = pixelManager.fireArgs.last?.last as! Dictionary<String, String>;
                        
                        expect(pixelManager.fireArgs.count).to(equal(1));
                        expect(type).to(equal(event));
                        expect(params).to(equal([
                            "campaign": product
                        ]));
                    }
                }
                
                describe("launch()") {
                    var rc: MockRCAnalytics!;
                    
                    class MockRCAnalytics: RCAnalytics {
                        var _trackArgs = [Array<Any>]();
                        
                        override func track(event: String) {
                            _trackArgs.append([event]);
                        }
                    }
                    
                    beforeEach {
                        rc = MockRCAnalytics(product: product, PixelManagerClass: MockPixelManager.self);
                        
                        rc.launch();
                    }
                    
                    it("should track an appLaunch event") {
                        let event = rc._trackArgs.last?.last as! String;
                        
                        expect(rc._trackArgs.count).to(equal(1));
                        expect(event).to(equal("appLaunch"));
                    }
                }
            }
            
            describe("create()") {
                var apiRoot: String!, product: String!;
                var result: RCAnalytics!;
                
                beforeEach {
                    apiRoot = "https://audit-staging.reelcontent.com/";
                    product = "cam-0GK0Wx03p17-qs1f";
                    
                    result = RCAnalytics.create(product, apiRoot: apiRoot);
                }
                
                it("should return a RCAnalytics instance") {
                    expect(result.apiRoot).to(equal(apiRoot));
                    expect(result.product).to(equal(product));
                }
                
                it("should make sure apiRoot is optional") {
                    expect(RCAnalytics.create(product).apiRoot).to(equal(RCAnalytics(product: product, PixelManagerClass: PixelManager.self).apiRoot));
                }
            }
        }
    }
}