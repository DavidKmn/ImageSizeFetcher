//
//  ImageSizeFetcher.swift
//  ImageSizeFetcher
//
//  Created by David on 15/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation

public class ImageSizeFetcher: NSObject, URLSessionDataDelegate {
    
    public typealias Callback = ((Error?, ImageSizeFetcherParser?) -> Void)
    
    private var session: URLSession!
    
    private var queue = OperationQueue()
    
    private var cache = NSCache<NSURL, ImageSizeFetcherParser>()
    
    public var timeout: TimeInterval
    
    public init(config: URLSessionConfiguration = .ephemeral, timeout: TimeInterval = 5) {
        self.timeout = timeout
        super.init()
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    /// Request for image info at given url.
    ///
    /// - Parameters:
    ///   - url: url of the image you want to analyze.
    ///   - force: true to skip cache and force download.
    ///   - callback: completion callback called to give out the result.
    public func sizeForImage(atURL url: URL, forceDownload: Bool = false, _ callback: @escaping Callback) {
        guard forceDownload == false, let entry = cache.object(forKey: (url as NSURL)) else {
            // dont have a cached result or we want to force download
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            let op = ImageSizeFetcherOperation(self.session.dataTask(with: request), callback: callback)
            queue.addOperation(op)
            return
        }
        callback(nil, entry)
    }
    
    private func operation(forTask task: URLSessionTask?) -> ImageSizeFetcherOperation? {
        return (self.queue.operations as! [ImageSizeFetcherOperation]).first(where: { $0.url == task?.currentRequest?.url})
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        operation(forTask: dataTask)?.onReceiveData(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        operation(forTask: task)?.onEndWithError(error)
    }
}
