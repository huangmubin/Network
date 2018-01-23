//
//  Network.swift
//  Network
//
//  Created by Myron on 2018/1/11.
//  Copyright © 2018年 Myron. All rights reserved.
//

import Foundation

public class iNetwork: CustomStringConvertible {
    
    // MARK: - Network Sesssion Info
    
    public var identifier: String = "Myron"
    
    public var description: String {
        return "Network \(identifier)"
    }
    
    public func log(_ value: String) {
        print("Network \(identifier): \(value)")
    }
    
    // MARK: - URL Session
    
    public var session: URLSession?
    public var current: iNetwork.Task!
    private let session_delegate: iNetworkSession = iNetworkSession()
    
    // MARK: - Queue
    
    private let queue: OperationQueue = OperationQueue()
    
    // MARK: - Init
    
    init(id: String = "") {
        queue.maxConcurrentOperationCount = 1
        session_delegate.network = self
        self.identifier = id
        self.session = URLSession(configuration: .default, delegate: session_delegate, delegateQueue: queue)
    }
    
    /** clear the session */
    deinit {
        session?.invalidateAndCancel()
        session_delegate.network = nil
        log("deinit.")
    }
    
    // MARK: - Tasks
    
    public var tasks: [iNetwork.Task] = []
    
    /** The tasks loop */
    fileprivate func loop() {
        queue.addOperation {
            // check current task is end
            if self.current != nil { return }
            
            // check tasks
            if self.tasks.count <= 0 { return }
            
            // next
            self.current = self.tasks.removeFirst()
            self.log("loop surplus \(self.tasks.count); current is \(self.current.api)")
            
            // request
            if let request = self.current.create_request() {
                self.current.task = self.session?.dataTask(with: request)
                self.log("\(self.current.method) \(self.current.api), url: \(String(describing: self.current.url?.absoluteString)), header = \(String(describing: self.current.request?.allHTTPHeaderFields))")
                self.current.task?.resume()
            } else {
                self.log("\(self.current.api) is create request error.")
                self.loop()
            }
        }
    }
    
    /** push a task into network tasks, at is the index, default nil, in the last. */
    public func push(task: iNetwork.Task, at: Int? = nil) {
        queue.addOperation {
            if let index = at {
                if index < self.tasks.count {
                    self.tasks.insert(task, at: index)
                } else {
                    self.tasks.append(task)
                }
            } else {
                self.tasks.append(task)
            }
            self.loop()
        }
    }
    
    // MARK: - Task Control
    
    public func suspend() {
        self.current?.task?.suspend()
        self.log("suspend \(String(describing: self.current?.api))")
    }
    
    public func resume() {
        if let task = self.current.task {
            switch task.state {
            case .suspended:
                self.current?.task?.resume()
                self.log("resume \(String(describing: self.current?.api))")
            default: break
            }
        }
    }
    
    /** if api = nil, cancel current task */
    public func cancel(api: String? = nil) {
        queue.addOperation {
            self.log("cancel \(String(describing: api))")
            guard let api = api else {
                self.current?.task?.cancel()
                return
            }
            if api == self.current.api {
                self.current?.task?.cancel()
            } else {
                if let index = self.tasks.index(where: { $0.api == api }) {
                    self.tasks.remove(at: index)
                }
            }
        }
    }
    
    public func clear(current: Bool = true) {
        queue.addOperation {
            self.log("clear \(self.tasks.count) and \(String(describing: current ? self.current?.api : "null"))")
            self.tasks.removeAll()
            if current {
                self.current?.task?.cancel()
            }
        }
    }
    
}

// MARK: - URL Session Delegate

fileprivate class iNetworkSession: NSObject {
    weak var network: iNetwork?
}

extension iNetworkSession: URLSessionTaskDelegate {
    
    /** Recevie complete */
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            network?.current = nil
            network?.loop()
        }
        if let task = network?.current {
            network?.log("complete \(task.api), error = \(String(describing: error)), using \(Date().timeIntervalSince1970 - task.time_start) second.")
        }
        network?.current.urlSession_receive_complete(error: error)
    }
    
}
extension iNetworkSession: URLSessionDataDelegate {
    
    /** Receive the response */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        if let http = response as? HTTPURLResponse {
            if let length = http.allHeaderFields["Content-Length"] as? String {
                network?.current.size_task = Int(length) ?? 0
            }
        }
        if let task = network?.current {
            network?.log("start \(task.api) at \(Date())")
        }
        network?.current.time_start = Date().timeIntervalSince1970
        network?.current.urlSession_receive_response()
        completionHandler(.allow)
    }
    
    /** Receive the data */
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if network?.current.data_receive == nil {
            network?.current.data_receive = data
        } else {
            network?.current.data_receive?.append(data)
        }
        network?.current.urlSession_receive_data()
    }
    
}
