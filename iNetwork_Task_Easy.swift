//
//  Network_Task_Easy.swift
//  Network
//
//  Created by Myron on 2018/1/12.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

extension iNetwork {
    
    public class EasyTask: iNetwork.Task {
        
        // MARK: - Override: Api
        
        private var _api: String = ""
        /** Override: The task api. */
        public override var api: String {
            set { _api = newValue }
            get { return _api }
        }
        
        private var _url: URL?
        /** Override: The task url */
        public override var url: URL? {
            set { _url = newValue }
            get { return _url }
        }
        
        // MARK: - Override: Request
        
        private var _method: String = "GET"
        /** Override: URL Request Method */
        public override var method: String {
            get { return _method }
            set { _method = newValue }
        }
        
        private var _header: [String: String]?
        /** Override: URL Request Header */
        public override var header: [String: String]? {
            get { return _header }
            set { _header = newValue }
        }
        
        private var _body: Data?
        /** Override: URL Request Body */
        public override var body: Data? {
            get { return _body }
            set { _body = newValue }
        }
        
        private var _time_out: TimeInterval = 8
        /** Override: URL Request TimeOut */
        public override var time_out: TimeInterval {
            get { return _time_out }
            set { _time_out = newValue }
        }
        
        private var _cache_policy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
        /** Override: URL Request Cache Policy */
        public override var cache_policy: URLRequest.CachePolicy {
            get { return _cache_policy }
            set { _cache_policy = newValue }
        }
        
        // MARK: - Override: Network Call
        
        var black_queue: DispatchQueue?
        
        var urlSession_receive_response_block: ((iNetwork.EasyTask) -> Void)?
        var urlSession_receive_data_block: ((iNetwork.EasyTask) -> Void)?
        var urlSession_receive_complete_block: ((iNetwork.EasyTask, Error?) -> Void)?
        
        public override func urlSession_receive_response() {
            if urlSession_receive_response_block != nil {
                if black_queue == nil {
                    self.urlSession_receive_response_block?(self)
                } else {
                    black_queue?.async {
                        self.urlSession_receive_response_block?(self)
                    }
                }
            }
        }
        public override func urlSession_receive_data() {
            if urlSession_receive_data_block != nil {
                if black_queue == nil {
                    self.urlSession_receive_data_block?(self)
                } else {
                    black_queue?.async {
                        self.urlSession_receive_data_block?(self)
                    }
                }
            }
        }
        public override func urlSession_receive_complete(error: Error?) {
            if urlSession_receive_complete_block != nil {
                if black_queue == nil {
                    self.urlSession_receive_complete_block?(self, error)
                } else {
                    black_queue?.async {
                        self.urlSession_receive_complete_block?(self, error)
                    }
                }
            }
        }
        
        // MARK: - Init
        
        override init() {
            super.init()
        }
        
        init(api: String,
             url: URL?,
             method: String,
             header: [String: String]?,
             body: Data?,
             time_out: TimeInterval,
             cache_policy: URLRequest.CachePolicy,
             response: ((iNetwork.EasyTask) -> Void)?,
             data: ((iNetwork.EasyTask) -> Void)?,
             complete: ((iNetwork.EasyTask, Error?) -> Void)?
            ) {
            super.init()
            self.api = api
            self.url = url
            self.header = header
            self.body = body
            self.time_out = time_out
            self.cache_policy = cache_policy
            
            self.urlSession_receive_response_block = response
            self.urlSession_receive_data_block = data
            self.urlSession_receive_complete_block = complete
        }
        
        convenience init(url: URL?, complete: ((iNetwork.EasyTask, Error?) -> Void)?) {
            self.init(api: url?.absoluteString ?? "", url: url, method: "GET", header: nil, body: nil, time_out: 8, cache_policy: .reloadIgnoringLocalCacheData, response: nil, data: nil, complete: complete)
        }
        
        public class func get(url: URL?, header: [String: String]? = nil, complete: ((iNetwork.EasyTask, Error?) -> Void)?) -> iNetwork.EasyTask {
            return iNetwork.EasyTask(api: url?.absoluteString ?? "", url: url, method: "GET", header: header, body: nil, time_out: 8, cache_policy: .reloadIgnoringLocalCacheData, response: nil, data: nil, complete: complete)
        }
        
        public class func post(url: URL?, header: [String: String]? = nil, body: Data?, complete: ((iNetwork.EasyTask, Error?) -> Void)?) -> iNetwork.EasyTask {
            return iNetwork.EasyTask(api: url?.absoluteString ?? "", url: url, method: "POST", header: header, body: body, time_out: 8, cache_policy: .reloadIgnoringLocalCacheData, response: nil, data: nil, complete: complete)
        }
        
        
    }
    
}

extension iNetwork {
    
    @discardableResult
    func get(url: URL?, header: [String: String]? = nil, complete: ((iNetwork.EasyTask, Error?) -> Void)?) -> iNetwork.EasyTask {
        let task = iNetwork.EasyTask.get(url: url, header: header, complete: complete)
        self.push(task: task)
        return task
    }
    
    @discardableResult
    func post(url: URL?, header: [String: String]? = nil, body: Data?, complete: ((iNetwork.EasyTask, Error?) -> Void)?) -> iNetwork.EasyTask {
        let task = iNetwork.EasyTask.post(url: url, header: header, body: body, complete: complete)
        self.push(task: task)
        return task
    }
    
}
