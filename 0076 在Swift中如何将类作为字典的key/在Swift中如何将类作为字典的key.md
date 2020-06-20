需满足`Equatable` 和 `Hashable`并重写下列方法

```swift
extension Endpoint: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        guard let request = try? urlRequest() else {
            hasher.combine(url)
            return
        }
        hasher.combine(request)
    }
    
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        let lhsRequest = try? lhs.urlRequest()
        let rhsRequest = try? rhs.urlRequest()
        
        if lhsRequest != nil, rhsRequest == nil { return false }
        if lhsRequest == nil, rhsRequest != nil { return false }
        if lhsRequest == nil, rhsRequest == nil { return lhsRequest.hashValue == rhsRequest.hashValue }
        return lhsRequest == rhsRequest
    }
}
```

使用：

```swift
open internal(set) var inflightRequests: [Endpoint: [JJMoya.Completion]] = [:]

// 添加
var inflightCompletionBlocks = self.inflightRequests[endpoint]
inflightCompletionBlocks?.append(pluginsWithCompletion)
self.inflightRequests[endpoint] = inflightCompletionBlocks

// 移除
self.inflightRequests.removeValue(forKey: endpoint)
```

更多细节请参考工程中代码