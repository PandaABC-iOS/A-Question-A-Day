# NSURLCache

iOS 系统已经帮你做好了缓存，而且非常完善简单，这个方式叫`NSURLCache`。这种方式只需两个步骤就能缓存网络接口返回内容：

- 第一步：客户端设置缓存大小

```objectivec
AppDelegate.m

NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:100*1024*1024 diskPath:nil];
NSURLCache.sharedURLCache = urlCache;
```

- 第二步：客户端发出 `GET`请求
- 第三步：Done，通过`NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];` 可以获取接口缓存

这两个步骤之后，GET请求的内容会被系统自动缓存了，无需自己去实现内容缓存。



注意：如果数据改动不大的接口 可以直接缓存中取数据 刷新界面 然后再请求接口 效果体验会更好