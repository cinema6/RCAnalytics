//
//  URIRequest.swift
//  RCAnalytics
//
//  Created by Josh Minzner on 4/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick;
import Nimble;
import Foundation;
@testable import RCAnalytics;

private class MockNSURLSessionDataTask: NSURLSessionDataTask {
    var resumeCalled = false;
    
    override private func resume() {
        resumeCalled = true;
    }
}

private class MockNSURLSession: NSURLSession {
    var dataTaskWithURLArgs = [Array<Any>]();
    var dataTasks = [MockNSURLSessionDataTask]();
    
    override func dataTaskWithURL(url: NSURL, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> MockNSURLSessionDataTask {
        let task = MockNSURLSessionDataTask();
        
        dataTaskWithURLArgs.append([url, completionHandler]);
        dataTasks.append(task);
        
        return task;
    }
}

class URIRequestSpec: QuickSpec {
    override func spec() {
        describe("URIRequest") {
            var uri: URI!;
            var urlSession: MockNSURLSession!;
            var request: URIRequest!;
            
            beforeEach {
                uri = URI(href: "https://platform.reelcontent.com");
                urlSession = MockNSURLSession();
                
                request = URIRequest(uri: uri, session: urlSession);
            }
            
            describe("create()") {
                var uri: URI!;
                var request: URIRequest!;
                
                beforeEach {
                    uri = URI(href: "http://reelcontent.com/");
                    
                    request = URIRequest.create(uri);
                }
                
                it("should create a URIRequest using the shared NSURLSession") {
                    expect(request.uri).to(beIdenticalTo(uri));
                    expect(request.session).to(beIdenticalTo(NSURLSession.sharedSession()));
                }
            }
            
            describe("methods:") {
                describe("send()") {
                    var handler: ((NSError?, String?) -> Void)!;
                    var error: NSError!; var data: String!;
                    var handlerCalled = false;
                    
                    beforeEach {
                        handler = { _error, _data in
                            handlerCalled = true;
                            
                            error = _error;
                            data = _data;
                        }
                        
                        request.send(handler);
                    }
                    
                    it("should create a NSURLSessionDataTask") {
                        let nsURL = urlSession.dataTaskWithURLArgs.first?.first as! NSURL;
                        
                        expect(urlSession.dataTaskWithURLArgs.count).to(equal(1));
                        expect(nsURL).to(equal(uri.toNSURL()));
                    }
                    
                    it("should resume the data task") {
                        expect(urlSession.dataTasks.first!.resumeCalled).to(equal(true));
                    }
                    
                    describe("when the request") {
                        var dataTaskHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)!;
                        
                        beforeEach {
                            dataTaskHandler = urlSession.dataTaskWithURLArgs.first?.last as! ((NSData?, NSURLResponse?, NSError?) -> Void);
                        }
                        
                        describe("succeeds") {
                            var contents: NSString!;
                            
                            beforeEach {
                                contents = "This is my awesome data!";
                                
                                dataTaskHandler(contents.dataUsingEncoding(NSUTF8StringEncoding), NSURLResponse(), nil);
                            }
                            
                            it("should call the handler") {
                                expect(handlerCalled).to(equal(true));
                                expect(data).to(equal(contents));
                                expect(error).to(beNil());
                            }
                            
                            describe("if there is no handler") {
                                beforeEach {
                                    urlSession.dataTaskWithURLArgs.removeAll();
                                    handlerCalled = false;
                                    request.send();
                                    
                                    dataTaskHandler = urlSession.dataTaskWithURLArgs.first?.last as! ((NSData?, NSURLResponse?, NSError?) -> Void);
                                    dataTaskHandler(contents.dataUsingEncoding(NSUTF8StringEncoding), NSURLResponse(), nil);
                                }
                                
                                it("should do nothing") {
                                    expect(handlerCalled).to(equal(false));
                                }
                            }
                        }
                        
                        describe("fails") {
                            var reason: NSError!;
                            
                            beforeEach {
                                reason = NSError(domain: "Something", code: 3, userInfo: [:]);
                                
                                dataTaskHandler(nil, NSURLResponse(), reason);
                            }
                            
                            it("should call the handler") {
                                expect(handlerCalled).to(equal(true));
                                expect(data).to(beNil());
                                expect(error).to(beIdenticalTo(reason));
                            }
                            
                            describe("if there is no handler") {
                                beforeEach {
                                    urlSession.dataTaskWithURLArgs.removeAll();
                                    handlerCalled = false;
                                    request.send();
                                    
                                    dataTaskHandler = urlSession.dataTaskWithURLArgs.first?.last as! ((NSData?, NSURLResponse?, NSError?) -> Void);
                                    dataTaskHandler(nil, NSURLResponse(), reason);
                                }
                                
                                it("should do nothing") {
                                    expect(handlerCalled).to(equal(false));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}