//
//  Json.swift
//  Network
//
//  Created by Myron on 2018/1/11.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

/** Json data analysis tool. */
public class Json: CustomStringConvertible {
    
    // MARK: - Json Data
    
    /** complete json data */
    private var json: Any?
    /** temp json data when the user visiting. */
    private var temp: Any?
    
    /** Set the json data */
    public func set(_ json: Any?) {
        self.json = json
        self.temp = json
    }
    
    /** Reset the temp data */
    public func reset() {
        self.temp = self.json
    }
    
    // MARK: - Description: CustomStringConvertible
    
    /** description string */
    public var description: String {
        return "\n==== Json Start ====\n\(String(describing: self.json))\n==== Json End   ====\n"
    }
    
    /** scan temp */
    public func scan_temp() {
        print("\n==== Json Temp Start ====\n\(String(describing: self.temp))\n==== Json Temp End   ====\n")
    }
    
    // MARK: - Init
    
    public init(json: Any?) {
        self.json = json
        self.temp = json
    }
    
    public init?(data: Data?) {
        if let data = data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
                self.json = json
                self.temp = json
                return
            }
        }
        return nil
    }
    
    // MARK: - Subscript Visit
    
    /** use the keys [String, Int] to update the temp */
    private func update_temp(keys: [Any]) {
        var temp = self.temp
        for key in keys {
            if let json = temp as? [String: Any], let key = key as? String {
                temp = json[key]
            }
            else if let json = temp as? [Any], let key = key as? Int {
                temp = json[key]
            }
        }
        self.temp = temp
    }
    
    /** use the keys [String, Int] to update the temp json and return self. */
    public subscript(keys: Any...) -> Json {
        update_temp(keys: keys)
        return self
    }
    
    // MARK: - Method Visit
    
    public func get<T>(_ keys: Any...) -> T? {
        defer { self.temp = self.json }
        update_temp(keys: keys)
        return temp as? T
    }
    
    public func get<T>(_ keys: Any..., null: T) -> T {
        defer { self.temp = self.json }
        update_temp(keys: keys)
        return (temp as? T) ?? null
    }
    
    // MARK: - Type
    
    public var string: String? {
        defer { temp = json }
        return temp as? String
    }
    
    public var int: Int? {
        defer { temp = json }
        if let value = temp as? Int {
            return value
        }
        if let value = temp as? String {
            if let int = Int(value) {
                return int
            } else if let double = Double(value) {
                return Int(double)
            }
        }
        if let value = temp as? Double {
            return Int(value)
        }
        return nil
    }
    
    public var double: Double? {
        defer { temp = json }
        if let value = temp as? Double {
            return value
        }
        if let value = temp as? String {
            return Double(value)
        }
        return nil
    }
    
    public var float: Float? {
        defer { temp = json }
        if let value = temp as? Float {
            return value
        }
        if let value = temp as? String {
            return Float(value)
        }
        return nil
    }
    
    public var bool: Bool? {
        defer { temp = json }
        if let value = temp as? Bool {
            return value
        }
        if let value = temp as? Int {
            return value == 1
        }
        if let value = temp as? String {
            switch value.lowercased() {
            case "", "0", "false", "no", "off":
                return false
            case "1", "true", "yes", "on":
                return true
            default:
                break
            }
        }
        return nil
    }
    
    public var array: [Json] {
        defer { temp = json }
        if let datas = temp as? [Any] {
            var jsons = [Json]()
            for json in datas {
                jsons.append(Json(json: json))
            }
            return jsons
        }
        return []
    }
    
    
}

// MARK: - Json Tools

extension Json {
    
    /** Transform a dictionary or array to the json string. */
    public class func toString(_ json: Any) -> String {
        var result = ""
        if let dic = json as? [String: Any] {
            result += "{"
            for (k, v) in dic {
                switch v {
                case is Int, is Double, is Float:
                    result += "\"\(k)\":\(v),"
                case is String:
                    result += "\"\(k)\":\"\(v)\","
                case is Bool:
                    let b = v as! Bool
                    result += "\"\(k)\":" + (b ? "true," : "false,")
                default:
                    result += "\"\(k)\":\(toString(v)),"
                }
            }
            result.remove(at: result.index(before: result.endIndex))
            result += "}"
        } else if let arr = json as? [Any] {
            result += "["
            for v in arr {
                switch v {
                case is Int, is Double, is Float:
                    result += "\(v),"
                case is String:
                    result += "\"\(v)\","
                case is Bool:
                    let b = v as! Bool
                    result += (b ? "true," : "false,")
                default:
                    result += "\(toString(v)),"
                }
            }
            result.remove(at: result.index(before: result.endIndex))
            result += "]"
        }
        return result
    }
    
    /** Transform a Dictionary or Array to the json format Data. */
    public class func data(_ json: Any) -> Data? {
        if let data = json as? Data {
            return data
        }
        if let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
            return data
        }
        return nil
    }
    
}
