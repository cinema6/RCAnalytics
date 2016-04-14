//
//  URI.swift
//  Pods
//
//  Created by Josh Minzner on 4/12/16.
//
//

import Foundation;

private let RESERVED_CHARS: Set<Character> = [
    "!", "*", "'", "(", ")", ";", ":", "@", "&", "=", "+", "$", ",", "/", "?", "#", "[", "]",
    "\n", " ", "\"", "%", "<", ">", "\\", "^", "`", "{", "|", "}"
];

private func percentEncode(char: Character) -> String {
    let value = String(char).utf8.first!.hashValue;
    let hex = String(value, radix: 16, uppercase: true);
    
    return "%" + (hex.characters.count == 1 ? "0" : "") + hex;
}

private func percentDecode(value: String) -> Character {
    let hex = value.substringWithRange(value.characters.startIndex.advancedBy(1)..<value.characters.endIndex);
    
    return Character(UnicodeScalar(Int(hex, radix: 16)!));
}

private func match(regex: String, string: String) -> Array<String> {
    let regex = try! NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions());
    let matches = regex.matchesInString(string, options: [], range: NSMakeRange(0, string.characters.count));
    let nsString = string as NSString;
    
    return matches.map({
        return nsString.substringWithRange($0.range);
    });
}

private func trim(string: NSString, first _first: Int = 0, last: Int = 0) -> String {
    let length = string.length;
    let first = min(length, _first);
    
    return string.substringWithRange(NSMakeRange(first, string.length - first - last));
}

private func parseSearch(search: String) -> Dictionary<String, String> {
    if (search == "") { return [String: String](); }
    
    return trim(search, first: 1).componentsSeparatedByString("&").reduce([String: String]()) { _result, pair in
        var result = _result;
        let parts = pair.componentsSeparatedByString("=");
        
        result[parts.first!] = URI.decode(parts.last!);
        
        return result;
    };
}

private func stringifySearch(search: Dictionary<String, String>) -> String {
    if (search.count == 0) { return ""; }
    
    return "?" + search.map { key, value in
        return key + "=" + URI.encode(value);
    }.joinWithSeparator("&");
}

private func createHref(protoc protoc: String?, auth: String?, host: String?, path: String?, hash: String?) -> String {
    let authPart = (auth != nil) ? (auth! + "@") : "";
    let protocolPart = protoc ?? "";
    let hashPart = hash ?? "";
    let hostPart = (host != nil) ? ("//" + authPart + host!) : "";
    let pathPart = path ?? "";
    
    return protocolPart + hostPart + pathPart + hashPart;
}

internal func ==(left: URI, right: URI) -> Bool {
    return left.href == right.href;
}

internal class URI: Equatable {
    let href: String;
    let protoc, host, auth, hostname, port, pathname, search, path, hash: String?;
    let query: [String: String];
    
    init(
        href _href: String?
    ) {
        href = _href!;
        protoc = match("^\\w+:", string: href).first;
        auth = href.characters.contains("@") ?
            trim(match("/[^@]+", string: href).first!, first: 2) : nil;
        host = { href, protoc, auth in
            let result = (auth != nil) ?
                trim(match("@[^/]+", string: href).first!, first: 1) :
                trim(match("//[^/]+", string: href).first ?? "", first: 2);
            
            if (result == "") { return nil; }
            
            return result;
        }(href, protoc, auth);
        hostname = match("[^:]+", string: host ?? "").first;
        port = (host ?? "").characters.contains(":") ?
            match("\\d+$", string: host!).first! : nil;
        pathname = { href, protoc, auth, host in
            if (protoc == nil) {
                return href;
            }
            
            if (host == nil) {
                return nil;
            }
            
            let startLength = (
                protoc! + "//" +
                (auth != nil ? (auth! + "@") : "") +
                host!
            ).characters.count;
            
            return match("[^?]+", string: trim(href, first: startLength)).first ?? "/";
        }(href, protoc, auth, host);
        search = match("\\?[^#]+", string: href).first ?? "";
        path = { pathname, search in
            if (pathname == nil) { return nil; }
            
            return pathname! + (search ?? "");
        }(pathname, search);
        hash = match("#.+", string: href).first;
        query = parseSearch(search!);
    }
    
    init(
        protoc _protoc: String? = nil,
        hostname _hostname: String? = nil,
        auth _auth: String? = nil,
        port _port: String? = nil,
        pathname _pathname: String? = nil,
        query _query: Dictionary<String, String>? = nil,
        hash _hash: String? = nil
    ) {
        protoc = {
            if (_protoc == nil) { return nil; }
            
            return _protoc! + (_protoc?.characters.last == ":" ? "" : ":");
        }();
        hostname = _hostname;
        auth = _auth;
        port = _port;
        query = _query ?? [String: String]();
        hash = {
            if (_hash == nil) { return nil; }
            
            return _hash!.characters.first == "#" ? _hash : ("#" + _hash!);
        }();
        pathname = { protoc, hostname, query, hash in
            if ((protoc != nil || query.count > 0 || hash != nil) && hostname == nil) { return nil; }
            
            return ((_pathname ?? "").characters.first == "/") ? _pathname : ("/" + (_pathname ?? ""));
        }(protoc, hostname, query, hash);
        host = { hostname, port in
            if (hostname == nil) { return nil; }
            
            return hostname! + ((port != nil) ? (":" + port!) : "");
        }(hostname, port);
        search = stringifySearch(query);
        path = { pathname, search in
            if (pathname == nil && search == "") { return nil; }
            
            return (pathname ?? "") + search!;
        }(pathname, search);
        
        href = createHref(protoc: protoc, auth: auth, host: host, path: path, hash: hash);
    }
    
    func toNSURL() -> NSURL {
        return NSURL(string: href)!;
    }
    
    static func encode(part: String) -> String {
        var result: String = "";
        
        for char in part.characters {
            if (RESERVED_CHARS.contains(char)) {
                result.appendContentsOf(percentEncode(char));
            } else {
                result.append(char);
            }
        }
        
        return result;
    }
    
    static func decode(string: String) -> String {
        var encoded: String = "";
        var result: String = "";
        
        for char in string.characters {
            if (char != "%" && encoded.characters.count == 0) {
                result.append(char);
            } else {
                encoded.append(char);
                
                if (encoded.characters.count == 3) {
                    result.append(percentDecode(encoded));
                    encoded = "";
                }
            }
        }
        
        return result;
    }
}