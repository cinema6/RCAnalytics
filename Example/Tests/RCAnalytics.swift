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

private class MockUserDefaults: NSUserDefaults {
    var synchronized = false;
    var keys = [String: Bool]();

    override func boolForKey(defaultName: String) -> Bool {
        return keys[defaultName] ?? false;
    }

    override func setBool(value: Bool, forKey defaultName: String) {
        keys[defaultName] = value;
    }

    override func synchronize() -> Bool {
        synchronized = true;
        return true;
    }
}

private var pixelManager: MockPixelManager!;

class RCAnalyticsSpec: QuickSpec {
    override func spec() {
        describe("RCAnalytics(apiRoot)") {
            var rc: RCAnalytics!;
            var apiRoot: String!, product: String!;
            var PixelManagerClass: PixelManager.Type!;
            var userDefaults: MockUserDefaults!;
            
            beforeEach {
                apiRoot = "https://audit-staging.reelcontent.com/";
                product = "cam-0GK0Wx03p17-qs1f";
                PixelManagerClass = MockPixelManager.self;
                userDefaults = MockUserDefaults();
                
                rc = RCAnalytics(apiRoot: apiRoot, product: product, PixelManagerClass: PixelManagerClass, userDefaults: userDefaults);
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
                            rc = RCAnalytics(product: product, PixelManagerClass: PixelManagerClass, userDefaults: userDefaults);
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
                        rc = MockRCAnalytics(product: product, PixelManagerClass: MockPixelManager.self, userDefaults: userDefaults);
                        
                        rc.launch();
                    }

                    it("should track an appInstall event") {
                        let event = rc._trackArgs.first?.last as! String;

                        expect(rc._trackArgs.count).to(equal(2));
                        expect(event).to(equal("appInstall"));
                    }

                    it("should track an appLaunch event") {
                        let event = rc._trackArgs.last?.last as! String;

                        expect(rc._trackArgs.count).to(equal(2));
                        expect(event).to(equal("appLaunch"));
                    }

                    it("should set 'RCAnalytics::HasLaunched' to true in the user defaults") {
                        expect(userDefaults.keys["RCAnalytics::HasLaunched"]).to(equal(true));
                    }

                    it("should synchronize the defaults") {
                        expect(userDefaults.synchronized).to(equal(true));
                    }

                    describe("if the app has been launched before") {
                        beforeEach {
                            userDefaults.keys["RCAnalytics::HasLaunched"] = true;
                            rc._trackArgs.removeAll();
                            userDefaults.synchronized = false;

                            rc.launch();
                        }

                        it("should only track 'appLaunch'") {
                            let event = rc._trackArgs.last?.last as! String;

                            expect(rc._trackArgs.count).to(equal(1));
                            expect(event).to(equal("appLaunch"));
                        }
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
                    expect(RCAnalytics.create(product).apiRoot).to(equal(RCAnalytics(product: product, PixelManagerClass: PixelManager.self, userDefaults: NSUserDefaults.standardUserDefaults()).apiRoot));
                }
            }
        }
    }
}