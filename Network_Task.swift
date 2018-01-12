//
//  Network_Task.swift
//  Network
//
//  Created by Myron on 2018/1/11.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

extension Network {
    
    public class Task {
        
        // MARK: - Override: Api
        
        /** Override: The task api. */
        public var api: String { return "" }
        /** Override: The task url */
        public var url: URL? { return URL(string: api) }
        
        // MARK: - Override: Request
        
        /** Override: URL Request Method */
        public var method: String { return "GET" }
        /** Override: URL Request Header */
        public var header: [String: String]? { return nil }
        /** Override: URL Request Body */
        public var body: Data? { return nil }
        /** Override: URL Request TimeOut */
        public var time_out: TimeInterval { return 8 }
        /** Override: URL Request Cache Policy */
        public var cache_policy: URLRequest.CachePolicy { return URLRequest.CachePolicy.reloadIgnoringLocalCacheData }
        
        // MARK: - Override: Network Call
        
        public func urlSession_receive_response() {}
        public func urlSession_receive_data() {}
        public func urlSession_receive_complete(error: Error?) {}
        
        // MARK: - Log
        
        /** print the value */
        public func log(_ value: String) {
            print("Task \(api): \(value)")
        }
        
        // MARK: - Init
        
        init() { log("init.") }
        deinit { log("deinit.") }
        
        // MARK: - Request
        
        public var request: URLRequest? = nil
        public func create_request() -> URLRequest? {
            guard let url = self.url else {
                log("url error.")
                return nil
            }
            request = URLRequest(url: url, cachePolicy: cache_policy, timeoutInterval: time_out)
            request?.httpMethod = method
            request?.httpBody = body
            request?.allHTTPHeaderFields = header
            if let data = data_breaking {
                request?.allHTTPHeaderFields?.updateValue("bytes=\(data.count)-", forKey: "Range")
            }
            return request
        }
        
        // MARK: - Sesssion Task
        
        public var task: URLSessionDataTask? {
            didSet { task?.taskDescription = api }
        }
        
        // MARK: - URL Session
        
        public var response: URLResponse? { return task?.response }
        
        // MARK: Data
        
        /** Receive data */
        public var data_receive: Data?
        /** Breaking data */
        public var data_breaking: Data?
        /** Total Data */
        public var data: Data { return (data_breaking ?? Data()) + (data_receive ?? Data()) }
        
        // MARK: Size
        
        /** Receive data's size */
        public var size_receive: Int { return data_receive?.count ?? 0 }
        /** Task total data's size */
        public var size_task: Int = 0
        /** Current total data's size */
        public var size_current: Int { return data.count }
        /** Total data's size */
        public var size_total: Int = 0
        
        // MARK: Time
        
        /** Start download time */
        public var time_start: TimeInterval = 0
        public var time_speed: TimeInterval {
            return Double(size_receive) / (Date().timeIntervalSince1970 - time_start)
        }
        
        // MARK: - Data read
        
        // MARK: Data
        
        private var _json: Json?
        /** Get the data use json type, if data is nil will be a empty json. */
        public var json: Json {
            if _json == nil {
                if let json = Json(data: data) {
                    _json = json
                    return json
                }
            }
            return Json(json: nil)
        }
        
        /** Get data use utf8 String */
        public var utf8: String? {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        
        // MARK: URL Session
        
        /** Http response status code */
        public var code: Int {
            return (response as? HTTPURLResponse)?.statusCode ?? -1
        }
        
        /** Http response header fields value */
        public func header<T>(_ key: String) -> T? {
            if let headers = (response as? HTTPURLResponse)?.allHeaderFields {
                return (headers[key] as? T)
            }
            return nil
        }
        
        /** Http response header fields value */
        public func header<T>(_ key: String, null: T) -> T {
            return header(key) ?? null
        }
        
    }
    
}
