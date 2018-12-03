//
//  ImageSizeFetcherOperation.swift
//  ImageSizeFetcher
//
//  Created by David on 15/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation

internal class ImageSizeFetcherOperation: Operation {
    
    let callback: ImageSizeFetcher.Callback?
    
    let request: URLSessionTask
    
    private(set) var recievedData = Data()
    
    var url: URL? {
        return self.request.currentRequest?.url
    }
    
    /// Initialize a new operation for a given url.
    ///
    /// - Parameters:
    ///   - request: request to perform.
    ///   - callback: callback to call at the end of the operation.
    init(_ request: URLSessionDataTask, callback: ImageSizeFetcher.Callback?) {
        self.request = request
        self.callback = callback
    }
    
    override func start() {
        guard !self.isCancelled else { return }
        self.request.resume()
    }
    
    override func cancel() {
        self.request.cancel()
        super.cancel()
    }
    
    func onReceiveData(_ data: Data) {
        guard !self.isCancelled else { return }
        self.recievedData.append(data)
        
        // not enough data collected for anything
        guard data.count >= 2 else { return }
        
        do {
            if let result = try ImageSizeFetcherParser(sourceURL: self.url!, data) {
                self.callback?(nil, result)
                self.cancel()
            }
            // nothing recieved data, if enough we can stop download
        } catch let error {
            // parse has failed
            self.callback?(error, nil)
            self.cancel()
        }
    }
    
    func onEndWithError(_ error: Error?) {
        self.callback?(ImageParserErrors.network(error), nil)
        self.cancel()
    }
}
