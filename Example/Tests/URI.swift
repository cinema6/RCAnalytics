//
//  URI.swift
//  RCAnalytics
//
//  Created by Josh Minzner on 4/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick;
import Nimble;
import Foundation;
@testable import RCAnalytics;

class URISpec: QuickSpec {
    override func spec() {
        describe("URI") {
            it("should handle an href") {
                let url = URI(href: "http://user:pass@host.com:8080/p/a/t/h?query=string&funny=ha%20ha#hash");
                
                expect(url.href).to(equal("http://user:pass@host.com:8080/p/a/t/h?query=string&funny=ha%20ha#hash"));
                expect(url.protoc).to(equal("http:"));
                expect(url.host).to(equal("host.com:8080"));
                expect(url.auth).to(equal("user:pass"));
                expect(url.hostname).to(equal("host.com"));
                expect(url.port).to(equal("8080"));
                expect(url.pathname).to(equal("/p/a/t/h"));
                expect(url.search).to(equal("?query=string&funny=ha%20ha"));
                expect(url.path).to(equal("/p/a/t/h?query=string&funny=ha%20ha"));
                expect(url.query).to(equal([
                    "query": "string",
                    "funny": "ha ha"
                ]));
                expect(url.hash).to(equal("#hash"));
            }
            
            it("should handle a minimal URL") {
                let url = URI(href: "https://www.reelcontent.com");
                
                expect(url.href).to(equal("https://www.reelcontent.com"));
                expect(url.protoc).to(equal("https:"));
                expect(url.host).to(equal("www.reelcontent.com"));
                expect(url.auth).to(beNil());
                expect(url.hostname).to(equal("www.reelcontent.com"));
                expect(url.port).to(beNil());
                expect(url.pathname).to(equal("/"));
                expect(url.search).to(equal(""));
                expect(url.path).to(equal("/"));
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(beNil());
            }
            
            it("should treat a non-url as a path") {
                let url = URI(href: "foo.com");
                
                expect(url.href).to(equal("foo.com"));
                expect(url.protoc).to(beNil());
                expect(url.host).to(beNil());
                expect(url.auth).to(beNil());
                expect(url.hostname).to(beNil());
                expect(url.port).to(beNil());
                expect(url.pathname).to(equal("foo.com"));
                expect(url.search).to(equal(""));
                expect(url.path).to(equal("foo.com"));
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(beNil());
            }
            
            it("should handle just a protocol") {
                let url = URI(href: "ftp://");
                
                expect(url.href).to(equal("ftp://"));
                expect(url.protoc).to(equal("ftp:"));
                expect(url.host).to(beNil());
                expect(url.auth).to(beNil());
                expect(url.hostname).to(beNil());
                expect(url.port).to(beNil());
                expect(url.pathname).to(beNil());
                expect(url.search).to(equal(""));
                expect(url.path).to(beNil());
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(beNil());
            }
            
            it("should handle the seperate parts of a url") {
                let url = URI(
                    protoc: "http",
                    hostname: "reelcontent.com",
                    auth: "josh:password",
                    port: "80",
                    pathname: "hey/there",
                    query: [
                        "what": "is up?",
                        "its": "all good!"
                    ],
                    hash: "good-stuff"
                );
                
                expect(url.href).to(equal("http://josh:password@reelcontent.com:80/hey/there?its=all%20good%21&what=is%20up%3F#good-stuff"));
                expect(url.protoc).to(equal("http:"));
                expect(url.host).to(equal("reelcontent.com:80"));
                expect(url.auth).to(equal("josh:password"));
                expect(url.hostname).to(equal("reelcontent.com"));
                expect(url.port).to(equal("80"));
                expect(url.pathname).to(equal("/hey/there"));
                expect(url.search).to(equal("?its=all%20good%21&what=is%20up%3F"));
                expect(url.path).to(equal("/hey/there?its=all%20good%21&what=is%20up%3F"));
                expect(url.query).to(equal([
                    "what": "is up?",
                    "its": "all good!"
                ]));
                expect(url.hash).to(equal("#good-stuff"));
            }
            
            it("should handle minimal parts of a URL") {
                let url = URI(
                    protoc: "https",
                    hostname: "reelcontent.com"
                );
                
                expect(url.href).to(equal("https://reelcontent.com/"));
                expect(url.protoc).to(equal("https:"));
                expect(url.host).to(equal("reelcontent.com"));
                expect(url.auth).to(beNil());
                expect(url.hostname).to(equal("reelcontent.com"));
                expect(url.port).to(beNil());
                expect(url.pathname).to(equal("/"));
                expect(url.search).to(equal(""));
                expect(url.path).to(equal("/"));
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(beNil());
            }
            
            it("should handle just a protocol") {
                let url = URI(protoc: "ftp");
                
                expect(url.href).to(equal("ftp:"));
                expect(url.protoc).to(equal("ftp:"));
                expect(url.host).to(beNil());
                expect(url.auth).to(beNil());
                expect(url.hostname).to(beNil());
                expect(url.port).to(beNil());
                expect(url.pathname).to(beNil());
                expect(url.search).to(equal(""));
                expect(url.path).to(beNil());
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(beNil());
            }
            
            it("should handle just a hostname") {
                let url = URI(hostname: "platform.reelcontent.com");
                
                expect(url.href).to(equal("//platform.reelcontent.com/"));
                expect(url.protoc).to(beNil());
                expect(url.host).to(equal("platform.reelcontent.com"));
                expect(url.auth).to(beNil());
                expect(url.hostname).to(equal("platform.reelcontent.com"));
                expect(url.port).to(beNil());
                expect(url.pathname).to(equal("/"));
                expect(url.search).to(equal(""));
                expect(url.path).to(equal("/"));
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(beNil());
            }
            
            it("should handle just a pathname") {
                let url = URI(pathname: "foo/bar");
                
                expect(url.href).to(equal("/foo/bar"));
                expect(url.protoc).to(beNil());
                expect(url.host).to(beNil());
                expect(url.auth).to(beNil());
                expect(url.hostname).to(beNil());
                expect(url.port).to(beNil());
                expect(url.pathname).to(equal("/foo/bar"));
                expect(url.search).to(equal(""));
                expect(url.path).to(equal("/foo/bar"));
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(beNil());
            }
            
            it("should handle just a query") {
                let url = URI(query: [
                    "hello": "its me!"
                ]);
                
                expect(url.href).to(equal("?hello=its%20me%21"));
                expect(url.protoc).to(beNil());
                expect(url.host).to(beNil());
                expect(url.auth).to(beNil());
                expect(url.hostname).to(beNil());
                expect(url.port).to(beNil());
                expect(url.pathname).to(beNil());
                expect(url.search).to(equal("?hello=its%20me%21"));
                expect(url.path).to(equal("?hello=its%20me%21"));
                expect(url.query).to(equal([
                    "hello": "its me!"
                ]));
                expect(url.hash).to(beNil());
            }
            
            it("should handle just a hash") {
                let url = URI(hash: "cool");
                
                expect(url.href).to(equal("#cool"));
                expect(url.protoc).to(beNil());
                expect(url.host).to(beNil());
                expect(url.auth).to(beNil());
                expect(url.hostname).to(beNil());
                expect(url.port).to(beNil());
                expect(url.pathname).to(beNil());
                expect(url.search).to(equal(""));
                expect(url.path).to(beNil());
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(equal("#cool"));
            }
            
            it("should handle protocols with colons, pathnames with leading /, and hashs with leading #") {
                let url = URI(protoc: "https:", hostname: "foo.com", pathname: "/foo/bar", hash: "#winning");
                
                expect(url.href).to(equal("https://foo.com/foo/bar#winning"));
                expect(url.protoc).to(equal("https:"));
                expect(url.host).to(equal("foo.com"));
                expect(url.auth).to(beNil());
                expect(url.hostname).to(equal("foo.com"));
                expect(url.port).to(beNil());
                expect(url.pathname).to(equal("/foo/bar"));
                expect(url.search).to(equal(""));
                expect(url.path).to(equal("/foo/bar"));
                expect(url.query).to(equal([String: String]()));
                expect(url.hash).to(equal("#winning"));
            }
            
            it("should be equitible") {
                expect(URI(href: "http://www.foo.com")).to(equal(URI(href: "http://www.foo.com")));
                expect(URI(href: "http://www.foo.com")).notTo(equal(URI(href: "https://www.foo.com")));
            }
            
            describe("instance") {
                var url: URI!;
                
                beforeEach {
                    url = URI(protoc: "https", hostname: "platform.reelcontent.com", port: "443", pathname: "/api/root/foo");
                }
                
                describe("methods:") {
                    describe("toNSURL()") {
                        var result: NSURL!;
                        
                        beforeEach {
                            result = url.toNSURL();
                        }
                        
                        it("should return an NSURL representing the URI") {
                            expect(result).to(equal(NSURL(string: url.href)));
                        }
                    }
                }
            }
            
            describe("static") {
                describe("methods:") {
                    describe("encode()") {
                        var string: String!;
                        
                        beforeEach {
                            string = "This is a test string; all the correct chars' are encoded: This fn is #1! (Hell yes.) ! # $ & ' ( ) * + , / : ; = ? @ % [ ]\n" +
                                "\n" +
                                "\" < > \\ ^ ` { } | ~";
                        }
                        
                        it("should escape all URI-incompatible characters") {
                            expect(URI.encode(string)).to(equal("This%20is%20a%20test%20string%3B%20all%20the%20correct%20chars%27%20are%20encoded%3A%20This%20fn%20is%20%231%21%20%28Hell%20yes.%29%20%21%20%23%20%24%20%26%20%27%20%28%20%29%20%2A%20%2B%20%2C%20%2F%20%3A%20%3B%20%3D%20%3F%20%40%20%25%20%5B%20%5D%0A%0A%22%20%3C%20%3E%20%5C%20%5E%20%60%20%7B%20%7D%20%7C%20~"));
                        }
                    }
                    
                    describe("decode()") {
                        var string: String!;
                        
                        beforeEach {
                            string = "This is a test string; all the correct chars' are encoded: This fn is #1! (Hell yes.) ! # $ & ' ( ) * + , / : ; = ? @ % [ ]\n" +
                                "\n" +
                                "\" < > \\ ^ ` { } | ~";
                        }
                        
                        it("should convert the string back to normal") {
                            expect(URI.decode(URI.encode(string))).to(equal(string));
                        }
                    }
                }
            }
        }
    }
}
