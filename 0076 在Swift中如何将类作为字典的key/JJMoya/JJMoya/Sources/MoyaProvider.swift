//
//  MoyaProvider.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

// JJ: 闭包中增加名字，更容易理解，对于常用的闭包可设为全局性质的typealias
public typealias ProgressBlock = (_ progress: ProgressResponse) -> Void

public typealias Completion = (_ result: Result<JJMoya.Response, MoyaError>) -> Void

public struct ProgressResponse {
    
    public let response: Response?
    
    public let progressObject: Progress?
    
    public init(progress: Progress? = nil, response: Response? = nil) {
        self.progressObject = progress
        self.response = response
    }
    
    public var progress: Double {
        if completed {
            return 1.0
        } else if let progressObject = progressObject, progressObject.totalUnitCount > 0 {
            return progressObject.fractionCompleted
        } else {
            return 0.0
        }
    }
    
    public var completed: Bool {
        return response != nil
    }
}

// JJ4: 注意这里的protocol的命名
public protocol MoyaProviderType: AnyObject {
    // JJ4: associatedtype的用法
    associatedtype Target: TargetType
    
    func request(_ target: Target, callbackQueue: DispatchQueue?, progress: JJMoya.ProgressBlock?, completion: @escaping JJMoya.Completion) -> Cancellable
    
}

open class MoyaProvider<Target: TargetType>: MoyaProviderType {
    
    public typealias EndpointClosure = (Target) -> Endpoint
    
    public typealias RequestResultClosure = (Result<URLRequest, MoyaError>) -> Void
    
    public typealias RequestClosure = (Endpoint, @escaping RequestResultClosure) -> Void
    
    public typealias StubClosure = (Target) -> JJMoya.StubBehavior
    
    public let endpointClosure: EndpointClosure
    
    public let requestClosure: RequestClosure
    
    public let stubClosure: StubClosure
    
    public let session: Session
    
    public let plugins: [PluginType]
    
    public let trackInflights: Bool
    
    // JJ4: 用Endpoint 当做key时需要遵循Equatable, Hashable 
    open internal(set) var inflightRequests: [Endpoint: [JJMoya.Completion]] = [:]
    
    public let callbackQueue: DispatchQueue?
    
    let lock: NSRecursiveLock = NSRecursiveLock()
    
    public init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping, 
                requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping, 
                stubClosure: @escaping StubClosure = MoyaProvider.neverStub, 
                callbackQueue: DispatchQueue? = nil, 
                session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
                plugins: [PluginType] = [], 
                trackInflights: Bool = false) {
        self.endpointClosure = endpointClosure
        self.requestClosure = requestClosure
        self.stubClosure = stubClosure
        self.session = session
        self.plugins = plugins
        self.trackInflights = trackInflights
        self.callbackQueue = callbackQueue
    }
    
    open func endpoint(_ token: Target) -> Endpoint {
        return endpointClosure(token)
    }
    
    @discardableResult
    public func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        let callbackQueue = callbackQueue ?? self.callbackQueue
        return requestNormal(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    @discardableResult
    open func stubRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue? = .none, completion: @escaping JJMoya.Completion, endpoint: Endpoint, stubBehavior: JJMoya.StubBehavior) -> CancellableToken {
        let callbackQueue = callbackQueue ?? self.callbackQueue
        let cancellableToken = CancellableToken {}
        let preparedRequest = notifyPluginsOfImpendingStub(for: request, target: target)
        let plugins = self.plugins
        let stub: () -> Void = createStubFunction(cancellableToken, forTarget: target, withCompletion: completion, endpoint: endpoint, plugins: plugins, request: preparedRequest)
        
        switch stubBehavior {
        case .immediate:
            switch callbackQueue {
            case .none:
                stub()
            case .some(let callbackQueue):
                callbackQueue.async(execute: stub)
            }
        case .delayed(let delay):
            let killTimeOffset = Int64(CDouble(delay) * CDouble(NSEC_PER_SEC))
            let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
            (callbackQueue ?? DispatchQueue.main).asyncAfter(deadline: killTime) { 
                stub()
            }
        case .never:
            fatalError("Method called to stub request when stubbing is disabled.")
        }
        return cancellableToken
    }
}

public enum StubBehavior {
    case never
    case immediate
    case delayed(seconds: TimeInterval)
}


public extension MoyaProvider {
    final class func neverStub(_: Target) -> JJMoya.StubBehavior {
        return .never
    }
    
    final class func immediatelyStub(_: Target) -> JJMoya.StubBehavior {
        return .immediate
    }
    
    final class func delayedStub(_ seconds: TimeInterval) -> (Target) -> JJMoya.StubBehavior {
        return { _ in return .delayed(seconds: seconds) }
    }
}

public func convertResponseToResult(_ response: HTTPURLResponse?, request: URLRequest?, data: Data?, error: Swift.Error?) -> Result<JJMoya.Response, MoyaError> {
    // JJ: 元祖也可以玩switch
    switch (response, data, error) {
    case let (.some(response), data, .none):
        let response = JJMoya.Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
        return .success(response)
    case let (.some(response), _, .some(error)):
        let response = JJMoya.Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
        let error = MoyaError.underlying(error, response)
        return .failure(error)
    case let (_, _, .some(error)):
        let error = MoyaError.underlying(error, nil)
        return .failure(error)
    default:
        let error = MoyaError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil), nil)
        return .failure(error)
    }
}
