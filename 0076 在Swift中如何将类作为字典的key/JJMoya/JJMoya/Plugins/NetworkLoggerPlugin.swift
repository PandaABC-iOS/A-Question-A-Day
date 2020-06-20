//
//  NetworkLoggerPlugin.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/19.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public final class NetworkLoggerPlugin {
    
    // 初始化参数增多，可以变成一个Configutation类来管理
    public var configuration: Configuration
    
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
}

extension NetworkLoggerPlugin: PluginType {
    public func willSend(_ request: RequestType, target: TargetType) {
        logNetworkRequest(request, target: target) { [weak self] output in
            self?.configuration.output(target, output)
        }
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            configuration.output(target, logNetworkResponse(response, target: target, isFromError: false))
        case let .failure(error):
            configuration.output(target, logNetworkError(error, target: target))
        }
    }
}

private extension NetworkLoggerPlugin {
    func logNetworkRequest(_ request: RequestType, target: TargetType, completion: @escaping ([String]) -> Void) {
        if configuration.logOptions.contains(.formatRequestAscURL) {
            _ = request.cURLDescription { [weak self] output in
                guard let self = self else { return }
                completion([self.configuration.formatter.entry("Request", output, target)])
            }
            return
        }
        guard let httpRequest = request.request else {
            completion([configuration.formatter.entry("Request", "(invalid request)", target)])
            return
        }
        
        var output = [String]()
        output.append(configuration.formatter.entry("Request", httpRequest.description, target))
        
        if configuration.logOptions.contains(.requestHeaders) {
            var allHeaders = request.sessionHeaders
            if let httpRequestHeaders = httpRequest.allHTTPHeaderFields {
                allHeaders.merge(httpRequestHeaders) { $1 }
            }
            output.append(configuration.formatter.entry("Request Headers", allHeaders.description, target))
        }
        
        if configuration.logOptions.contains(.requestBody) {
            if let bodyStream = httpRequest.httpBodyStream {
                output.append(configuration.formatter.entry("Request Body Stream", bodyStream.description, target))
            }
            if let body = httpRequest.httpBody {
                let stringOutput = configuration.formatter.requestData(body)
                output.append(configuration.formatter.entry("Request Body", stringOutput, target))
            }
        }
        
        if configuration.logOptions.contains(.requestMethod), let httpMethod = httpRequest.httpMethod {
            output.append(configuration.formatter.entry("HTTP Request Method", httpMethod, target))
        }
        completion(output)
    }
    
    func logNetworkResponse(_ response: Response, target: TargetType, isFromError: Bool) -> [String] {
        var output = [String]()
        
        if let httpResponse = response.response {
            output.append(configuration.formatter.entry("Response", httpResponse.description, target))
        } else {
            output.append(configuration.formatter.entry("Response", "Received emtpy network response for \(target).", target))
        }
        
        if (isFromError && configuration.logOptions.contains(.errorResponseBody))
            || configuration.logOptions.contains(.successResponseBody) {
            let stringOutput = configuration.formatter.requestData(response.data)
            output.append(configuration.formatter.entry("Response Body", stringOutput, target))
        }
        return output
    }
    
    func logNetworkError(_ error: MoyaError, target: TargetType) -> [String] {
        if let moyaResponse = error.response {
            return logNetworkResponse(moyaResponse, target: target, isFromError: true)
        }
        return [configuration.formatter.entry("Error", "Error calling \(target) : \(error)", target)]
    }
}

public extension NetworkLoggerPlugin {
    struct Configuration {
        
        public typealias OutputType = (_ target: TargetType, _ items: [String]) -> Void
        
        public var formatter: Formatter
        public var output: OutputType
        public var logOptions: LogOptions
        
        public init(formatter: Formatter = Formatter(),
                    output: @escaping OutputType = defaultOutput, 
                    logOptions: LogOptions = .default) {
            self.formatter = formatter
            self.output = output
            self.logOptions = logOptions
        }
        
        public static func defaultOutput(target: TargetType, items: [String]) {
            for item in items {
                print(item, separator: ",", terminator: "\n")
            }
        }
    }
}

public extension NetworkLoggerPlugin.Configuration {
    struct LogOptions: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let requestMethod: LogOptions = LogOptions(rawValue: 1 << 0)
        
        public static let requestBody: LogOptions = LogOptions(rawValue: 1 << 1)
        
        public static let requestHeaders: LogOptions = LogOptions(rawValue: 1 << 2)
        
        public static let formatRequestAscURL: LogOptions = LogOptions(rawValue: 1 << 3)
        
        public static let successResponseBody: LogOptions = LogOptions(rawValue: 1 << 4)
        
        public static let errorResponseBody: LogOptions = LogOptions(rawValue: 1 << 5)
        
        public static let `default`: LogOptions = [requestMethod, requestHeaders]
        
        public static let verbose: LogOptions = [requestMethod, requestHeaders, requestBody, successResponseBody, errorResponseBody]
    }
}

public extension NetworkLoggerPlugin.Configuration {
    struct Formatter {
        public typealias DataFormatterType = (Data) -> (String)
        public typealias EntryFormatterType = (_ identifier: String, _ message: String, _ target: TargetType) -> String
        
        public var entry: EntryFormatterType
        public var requestData: DataFormatterType
        public var responseData: DataFormatterType
        
        public init(entry: @escaping EntryFormatterType = defaultEntryFormatter, 
                    requestData: @escaping DataFormatterType = defaultDataFormatter, 
                    responseData: @escaping DataFormatterType = defaultDataFormatter) {
            self.entry = entry
            self.requestData = requestData
            self.responseData = responseData
        }
        
        public static func defaultDataFormatter(_ data: Data) -> String {
            return String(data: data, encoding: .utf8) ?? "## Cannnot map data to String ##"
        }
        
        public static func defaultEntryFormatter(identifier: String, message: String, target: TargetType) -> String {
            let date = defaultEntryDateFormatter.string(from: Date())
            return "Moya_Logger: [\(date)] \(identifier): \(message)"
        }
        
        static var defaultEntryDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            return formatter
        }()
    }
}
